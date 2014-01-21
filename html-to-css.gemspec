Gem::Specification.new do |s|
  s.name = 'html-to-css'
  s.version = '0.1.7'
  s.summary = 'html-to-css'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('rexle')
  s.signing_key = '../privatekeys/html-to-css.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/html-to-css'
end
