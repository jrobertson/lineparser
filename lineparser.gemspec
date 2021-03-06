Gem::Specification.new do |s|
  s.name = 'lineparser'
  s.version = '0.2.0'
  s.summary = 'Lineparser is suited to parsing configuration files, ' + 
      'however it can parse any type of text file which has repeating ' + 
      'patterns identified by a heading etc.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/lineparser.rb']
  s.add_runtime_dependency('line-tree', '~> 0.9', '>=0.9.1')
  s.signing_key = '../privatekeys/lineparser.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/lineparser'
  s.required_ruby_version = '>= 2.1.2'
end
