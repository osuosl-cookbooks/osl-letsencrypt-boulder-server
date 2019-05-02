describe http('http://localhost:4000/directory', enable_remote_worker: true) do
  its('body') { should match(%r{"new-cert": "http://(localhost|127.0.0.1):4000/acme/new-cert"}) }
end

describe http('https://foo.org', enable_remote_worker: true, ssl_verify: false) do
  its('status') { should cmp 403 }
end
