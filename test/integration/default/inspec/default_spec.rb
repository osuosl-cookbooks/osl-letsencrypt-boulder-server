describe http('http://localhost:4000/directory', enable_remote_worker: true) do
  its('body') { should match(%r{"new-cert": "http://(localhost|127.0.0.1):4000/acme/new-cert"}) }
end

describe command('curl https://foo.org -k -v') do
  its('stderr') { should match(/issuer: CN=h[2a]ppy h[2a]cker fake CA/) }
  its('stderr') { should match(/common name: foo.org/) }
end

#describe http(
#  'https://localhost',
#  headers: { 'Hose' => 'foo.org' },
#  enable_remote_worker: true, 
#  ssl_verify: false
#) do
#  its('status') { should cmp 403 }
#end
