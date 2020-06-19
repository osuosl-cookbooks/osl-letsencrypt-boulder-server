require_relative '../../spec_helper'

describe 'osl-letsencrypt-boulder-server::default' do
  context "#{CENTOS_6[:platform]} #{CENTOS_6[:version]}" do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(CENTOS_6).converge(described_recipe)
    end
    it 'raises an error' do
      expect { chef_run }.to raise_error(RuntimeError)
    end
  end
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p) do |node|
          node.normal['boulder']['host_aliases'] = %w(example.com foo.org)
        end.converge(described_recipe)
      end
      before do
        stub_command('/usr/local/bin/docker-compose ps -q | wc -l | grep 0').and_return(true)
        stub_command('screen -list boulder | /bin/grep 1\ Socket\ in')
        stub_command('[[ $(curl -s -o /dev/null -w "%{http_code}" localhost:4000/directory) -eq "200" ]]').and_return(true)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to install_package('dnsmasq')
      end
      it do
        expect(chef_run).to create_template('/etc/dnsmasq.conf').with(source: 'dnsmasq.erb')
      end
      %w(example.com foo.org).each do |host|
        it do
          expect(chef_run).to render_file('/etc/dnsmasq.conf').with_content(%r{^address=/#{host}/10.0.0.2$})
        end
      end
      it do
        expect(chef_run.template('/etc/dnsmasq.conf')).to notify('service[dnsmasq]').to(:restart).immediately
      end
      it do
        expect(chef_run).to start_service('dnsmasq')
      end
      it do
        expect(chef_run).to enable_service('dnsmasq')
      end
      it do
        expect(chef_run).to install_chef_gem('rest-client').with(compile_time: false)
      end
      [
        /^domain example.org$/,
        /^search example.org$/,
        /^nameserver 127.0.0.1$/,
      ].each do |line|
        it do
          expect(chef_run).to render_file('/etc/resolv.conf').with_content(line)
        end
      end
      %w(boulder boulder-rabbitmq boulder-mysql).each do |host|
        it do
          expect(chef_run).to_not render_file('/etc/dnsmasq.conf').with_content(%r{^address=/#{host}/127.0.0.1$})
        end
      end
      it do
        expect(chef_run).to create_directory('/opt/boulder')
      end
      it do
        expect(chef_run).to checkout_git('/opt/boulder')
          .with(
            repository: 'https://github.com/letsencrypt/boulder',
            revision: 'release-2019-10-28'
          )
      end
      it do
        expect(chef_run).to create_docker_service('default').with(misc_opts: '--live-restore')
      end

      [ /"httpPort": 80/,
        /"httpsPort": 443/,
        /"tlsPort": 443/,
      ].each do |line|
        it do
          expect(chef_run).to render_file('/opt/boulder/test/config/va.json').with_content(line)
        end
      end

      [
        /certificatesPerName:\n.+\n\s+threshold: 999/,
        /pendingAuthorizationsPerAccount:\n.+\n\s+threshold: 99/,
      ].each do |line|
        it do
          expect(chef_run).to render_file('/opt/boulder/test/rate-limit-policies.yml').with_content(line)
        end
      end

      it do
        expect(chef_run).to render_file('/opt/boulder/docker-compose.yml').with_content(
          /FAKE_DNS: 10.0.0.2/
        )
      end

      it do
        expect(chef_run).to run_execute('/usr/local/bin/docker-compose up -d')
          .with(
            live_stream: true,
            cwd: '/opt/boulder'
          )
      end
    end
  end
end
