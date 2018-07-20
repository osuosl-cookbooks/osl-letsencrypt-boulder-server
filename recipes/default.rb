#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: chef-letsencrypt-boulder-server
# Recipe:: default
#
# Copyright 2015 Schuberg Philis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Keep containers up if the docker daemon is restarted

if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 6
  Chef::Application.fatal!('CentOS 6 is not supported!')
end

package 'dnsmasq'

template '/etc/dnsmasq.conf' do
  source 'dnsmasq.erb'
  variables(
    hosts: node['boulder']['host_aliases']
  )
  notifies :restart, 'service[dnsmasq]', :immediately
end

service 'dnsmasq' do
  action [:start, :enable]
end

node.default['resolver']['domain'] = 'example.org'
node.default['resolver']['search'] = 'example.org'
node.default['resolver']['nameservers'] = %w(127.0.0.1)

include_recipe 'resolver'
include_recipe 'git'
include_recipe 'build-essential'

chef_gem 'rest-client' do
  action :install
  compile_time false
end

boulderdir = node['boulder']['dir']

directory boulderdir do
  recursive true
end

git boulderdir do
  repository 'https://github.com/letsencrypt/boulder'
  revision node['boulder']['revision']
  action :checkout
end

node.override['osl-docker']['service'] = { misc_opts: '--live-restore' }
include_recipe 'osl-docker'
include_recipe 'osl-docker::compose'

ruby_block 'boulder_config' do
  block do
    node['boulder']['config'].keys.each do |filename|
      config = ::JSON.parse ::File.read "#{boulderdir}/test/config/#{filename}.json"
      ::File.write("#{boulderdir}/test/config/#{filename}.json.bak", ::JSON.pretty_generate(config))
      config = Chef::Mixin::DeepMerge.deep_merge(node['boulder']['config'][filename].to_hash, config)
      ::File.write("#{boulderdir}/test/config/#{filename}.json", ::JSON.pretty_generate(config))
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

ruby_block 'boulder_dns' do
  block do
    dns = ::YAML.load ::File.read "#{boulderdir}/docker-compose.yml"
    dns['services']['boulder']['environment']['FAKE_DNS'] = node['ipaddress']
    ::File.write("#{boulderdir}/docker-compose.yml", dns.to_yaml)
  end
end

execute '/usr/local/bin/docker-compose up -d' do
  live_stream true
  cwd boulderdir
  only_if '/usr/local/bin/docker-compose ps -q | wc -l | grep 0'
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
        puts "Still waiting for boulder to start.. #{times * 10} seconds"
      end
      Chef::Application.fatal!('Failed to run boulder server') if times > 30
      break if client && client.code == 200
    end
  end
end
