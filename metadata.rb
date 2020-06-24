name             'osl-letsencrypt-boulder-server'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 14'
description      "Installs/Configures Boulder, the ACME-based CA server by Let's Encrypt."
issues_url       'https://github.com/osuosl-cookbooks/osl-letsencrypt-boulder-server/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-letsencrypt-boulder-server'
version          '3.2.0'

supports         'centos', '~> 7.0'
depends          'git'
depends          'osl-docker'
depends          'resolver'
