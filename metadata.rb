name             'osl-letsencrypt-boulder-server'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
description      "Installs/Configures Boulder, the ACME-based CA server by Let's Encrypt."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url       'https://github.com/osuosl-cookbooks/osl-letsencrypt-boulder-server/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-letsencrypt-boulder-server'
version          '2.0.1'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'

depends          'poise-python'
depends          'yum'
depends          'build-essential'
depends          'git'
depends          'osl-docker'
depends          'resolver'
