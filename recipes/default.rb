#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: chef-letsencrypt-boulder-server
# Recipe:: default
#
# Copyright:: 2015-2020, Schuberg Philis
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

raise 'CentOS 6 is not supported!' if platform_family?('rhel') && node['platform_version'].to_i == 6

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

build_essential 'default'

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

template "#{boulderdir}/test/config/va.json" do
  source 'va.json.erb'
  mode '644'
  variables(
    httpPort: node['boulder']['config']['va']['va']['portConfig']['httpPort'],
    httpsPort: node['boulder']['config']['va']['va']['portConfig']['httpsPort'],
    tlsPort: node['boulder']['config']['va']['va']['portConfig']['tlsPort']
  )
end

template "#{boulderdir}/test/rate-limit-policies.yml" do
  source 'rate-limit-policies.yml.erb'
  mode '644'
  variables(
    certsPerName: 999,
    pendingAuthPerAcct: 99
  )
end

template "#{boulderdir}/docker-compose.yml" do
  source 'docker-compose.yml.erb'
  mode '644'
  variables(
    fakedns: node['ipaddress']
  )
end

execute '/usr/local/bin/docker-compose up -d' do
  live_stream true
  cwd boulderdir
  only_if '/usr/local/bin/docker-compose ps -q | wc -l | grep 0'
end

execute 'wait_for_bootstrap' do
  command 'while [[ ! $(curl -s -o /dev/nulll -w "%{http_code}" localhost:4000/directory) -eq "200" ]]; do sleep 10; done' 
  not_if '[[ $(curl -s -o /dev/nulll -w "%{http_code}" localhost:4000/directory) -eq "200" ]]'
  timeout 3000
end
