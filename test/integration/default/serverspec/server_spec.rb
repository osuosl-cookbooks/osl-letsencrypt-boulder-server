require 'serverspec'

set :backend, :exec

describe command('curl http://127.0.0.1:4000/directory') do
  its(:stdout) { should match(%r{"new-cert": "http://127.0.0.1:4000/acme/new-cert"}) }
end
