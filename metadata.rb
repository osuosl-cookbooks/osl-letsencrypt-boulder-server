name             'letsencrypt-boulder-server'
maintainer       'Thijs Houtenbos'
maintainer_email 'thoutenbos@schubergphilis.com'
license          'All rights reserved'
description      "Installs/Configures Boulder, the ACME-based CA server by Let's Encrypt."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'golang'
depends          'rabbitmq'
depends          'mariadb'
depends          'build-essential'
depends          'yum'
