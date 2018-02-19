node.default['acme']['endpoint'] = 'http://127.0.0.1:4000'
include_recipe 'osl-acme'
include_recipe 'osl-apache'
include_recipe 'apache2::mod_ssl'

apache_app 'foo.org' do
  directory '/var/www/foo.org/htdocs'
  ssl_enable true
  cert_file '/etc/pki/tls/foo.org.crt'
  cert_key '/etc/pki/tls/foo.org.key'
  cert_chain '/etc/pki/tls/foo.org-chain.crt'
end

acme_selfsigned 'foo.org' do
  crt '/etc/pki/tls/foo.org.crt'
  chain '/etc/pki/tls/foo.org-chain.crt'
  key '/etc/pki/tls/foo.org.key'
  notifies :restart, 'service[apache2]', :immediately
end

acme_certificate 'foo.org' do
  crt '/etc/pki/tls/foo.org.crt'
  chain '/etc/pki/tls/foo.org-chain.crt'
  key '/etc/pki/tls/foo.org.key'
  wwwroot '/var/www/foo.org/htdocs'
  notifies :restart, 'service[apache2]'
end
