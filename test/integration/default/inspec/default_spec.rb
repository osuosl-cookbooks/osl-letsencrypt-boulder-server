describe http('http://localhost:4001/directory', enable_remote_worker: true) do
  its('body') { should match(%r{"newAccount": "http://(localhost|127.0.0.1):4001/acme/new-acct"}) }
end

describe command('curl https://foo.org -k -v') do
  its('stderr') { should match(/issuer: CN=h[2a]ppy h[2a]cker fake CA/) }
  its('stderr') { should match(/common name: foo.org/) }
end
