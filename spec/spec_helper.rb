require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-letsencrypt-boulder-server' }

CENTOS_6 = {
  platform: 'centos',
  version: '6.9',
}.freeze

CENTOS_7 = {
  platform: 'centos',
  version: '7.4.1708',
}.freeze

ALL_PLATFORMS = [
  CENTOS_7,
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end
