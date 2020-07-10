Gem::Specification.new do |s|
  s.name = 'html-to-css'
  s.version = '0.1.10'
  s.summary = 'Generates CSS from HTML passed into it.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/html-to-css.rb']
  s.add_runtime_dependency('rexle', '~> 1.4', '>=1.4.12')
  s.signing_key = '../privatekeys/html-to-css.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/html-to-css'
  s.required_ruby_version = '>= 2.1.2'
end
