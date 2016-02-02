default['boulder']['config']['boulder-config']['va']['portConfig']['httpPort'] = 80
default['boulder']['config']['boulder-config']['va']['portConfig']['httpsPort'] = 443
default['boulder']['config']['boulder-config']['va']['portConfig']['tlsPort'] = 443
default['boulder']['config']['boulder-config']['syslog']['network'] = 'udp'
default['boulder']['config']['boulder-config']['syslog']['server'] = 'localhost:514'
# Default 8000 port is needed by Atlassian apps.
default['boulder']['config']['boulder-config']['wfe']['debugAddr'] = 'localhost:7999'

default['boulder']['config']['issuer-ocsp-responder']['syslog']['network'] = 'udp'
default['boulder']['config']['issuer-ocsp-responder']['syslog']['server'] = 'localhost:514'
