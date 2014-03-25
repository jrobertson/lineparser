Gem::Specification.new do |s|
  s.name = 'lineparser'
  s.version = '0.1.13'
  s.summary = 'Lineparser is suited to parsing configuration files, however it can parse any type of text file which has repeating patterns identified by a heading etc.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('line-tree')
  s.signing_key = '../privatekeys/lineparser.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/lineparser'
end
