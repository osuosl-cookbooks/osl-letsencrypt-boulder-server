require 'serverspec'

set :backend, :exec

describe command('curl http://localhost:4000/directory') do
  its(:stdout) { should match(%r{"new-cert": "http://(localhost|127.0.0.1):4000/acme/new-cert"}) }
end

describe command('curl https://foo.org -k -v') do
  its(:stderr) { should match(/issuer: CN=h[2a]ppy h[2a]cker fake CA/) }
  its(:stderr) { should match(/common name: foo.org/) }
end
