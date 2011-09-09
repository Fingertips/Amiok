Gem::Specification.new do |s|
  s.name     = 'amiok'
  s.version  = '0.1'
  s.date     = '2011-09-09'

  s.summary  = 'A small tool to check the status of your Apache vhosts'
  s.authors  = ['Manfred Stienstra']
  s.email    = ['manfred@fngtps.com']
  s.homepage = 'https://github.com/Manfred/amiok'

  s.executables   = ['amiok']
  s.require_paths = ['lib']
  s.files         = Dir.glob('{bin,lib}/**/*')
end