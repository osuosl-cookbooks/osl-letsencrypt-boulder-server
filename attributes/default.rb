node['boulder']['config']['boulder-config']['va']['portConfig']['httpPort'] = 80
node['boulder']['config']['boulder-config']['va']['portConfig']['httpsPort'] = 443
node['boulder']['config']['boulder-config']['va']['portConfig']['tlsPort'] = 443
node['boulder']['config']['boulder-config']['syslog']['network'] = 'udp'
node['boulder']['config']['boulder-config']['syslog']['server'] = 'localhost:514'

node['boulder']['config']['issuer-ocsp-responder']['syslog']['network'] = 'udp'
node['boulder']['config']['issuer-ocsp-responder']['syslog']['server'] = 'localhost:514'
