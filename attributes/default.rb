#
# Author:: Thijs Houtenbos <thoutenbos@schubergphilis.com>
# Cookbook:: chef-letsencrypt-boulder-server
# Attribute:: default
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
#
default['boulder']['host_aliases'] = []
default['boulder']['dir'] = '/opt/boulder'
default['boulder']['revision'] = 'release-2019-10-28'
default['boulder']['config']['va']['va']['portConfig']['httpPort'] = 80
default['boulder']['config']['va']['va']['portConfig']['httpsPort'] = 443
default['boulder']['config']['va']['va']['portConfig']['tlsPort'] = 443
