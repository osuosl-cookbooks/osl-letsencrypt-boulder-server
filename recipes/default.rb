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
#

package 'git'
package 'screen'
package 'initscripts'
package 'logrotate'
package 'tar'
package 'wget'

case node['platform']
when 'ubuntu'
  package 'libtool'
else
  package 'libtool-ltdl-devel'
end

node.default['mariadb']['use_default_repository'] = true
node.default['mariadb']['install']['version'] = '10.1'

include_recipe 'build-essential'
include_recipe 'mariadb::server'
include_recipe 'rabbitmq'
include_recipe 'golang'

chef_gem 'rest-client' do
  action :install
  compile_time false
end

hostsfile_entry '127.0.0.1' do
  hostname 'localhost'
  aliases ['boulder', 'boulder-rabbitmq', 'boulder-mysql']
  action :create
end

boulderdir = "#{node['go']['gopath']}/src/github.com/letsencrypt/boulder"

directory ::File.dirname boulderdir do
  recursive true
end

git boulderdir do
  repository 'https://github.com/letsencrypt/boulder'
  revision node['boulder']['revision']
  action :checkout
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
  code 'source /etc/profile.d/golang.sh && GO15VENDOREXPERIMENT=1 screen -LdmS boulder ./start.py'
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
