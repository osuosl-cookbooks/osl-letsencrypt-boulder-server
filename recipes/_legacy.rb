package %w(screen initscripts logrotate tar wget libtool-ltdl-devel)

node.default['mariadb']['use_default_repository'] = true
node.default['mariadb']['install']['version'] = '10.1'
node.default['go']['version'] = '1.8'

include_recipe 'mariadb::server'
include_recipe 'rabbitmq'
include_recipe 'golang'

start_cmd = ''
python_runtime '2.7'
start_cmd = 'scl enable python27'

boulderdir = node['boulder']['dir']

cookbook_file "#{boulderdir}/test/setup.sh" do
  mode 0755
end

ruby_block 'boulder_config' do
  block do
    node['boulder']['config'].keys.each do |filename|
      config = ::JSON.parse ::File.read "#{boulderdir}/test/#{filename}.json"
      ::File.write("#{boulderdir}/test/#{filename}.json.bak", ::JSON.pretty_generate(config))
      config = Chef::Mixin::DeepMerge.deep_merge(node['boulder']['config'][filename].to_hash, config)
      ::File.write("#{boulderdir}/test/#{filename}.json", ::JSON.pretty_generate(config))
    end
  end
end

ruby_block 'boulder_limit' do
  block do
    limit = ::YAML.load ::File.read "#{boulderdir}/test/rate-limit-policies.yml"
    limit['certificatesPerName']['threshold'] = 999
    limit['pendingAuthorizationsPerAccount']['threshold'] = 99
    ::File.write("#{boulderdir}/test/rate-limit-policies.yml", limit.to_yaml)
  end
end

bash 'boulder_setup' do
  live_stream true
  cwd boulderdir
  code 'source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 ./test/setup.sh 2>&1 && touch setup.done'
  creates "#{boulderdir}/setup.done"
end

bash 'run_boulder' do
  live_stream true
  cwd boulderdir
  code "source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 screen -LdmS boulder #{start_cmd} ./start.py"
  not_if 'screen -list boulder | /bin/grep 1\ Socket\ in'
end

ruby_block 'wait_for_bootstrap' do
  block do
    require 'rest-client'
    times = 0
    loop do
      times += 1
      begin
        client = RestClient.get 'http://127.0.0.1:4000/directory'
      rescue
        sleep 10
        puts ::File.read "#{boulderdir}/screenlog.0"
      end
      Chef::Application.fatal!('Failed to run boulder server') if times > 30
      break if client && client.code == 200
    end
  end
end
