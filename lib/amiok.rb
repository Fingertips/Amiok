class Amiok
  POSSIBLE_LOCATIONS = %w(
    /etc/apache2
  )
  
  class << self
    attr_accessor :output
  end
  self.output = $stdout
  
  def apache_directory
    POSSIBLE_LOCATIONS.find do |path|
      File.exist?(path)
    end
  end
  
  def grep
    `grep -r -i -e 'server\\(name\\|alias\\)' /etc/apache2`
  end
  
  def domains
    grep.split("\n").inject([]) do |domains, line|
      config = line.split(':', 2)[-1].strip
      domain = config.split(' ')[-1]
      unless config.start_with?('#') or domain.start_with?('_') or domain.include?('example.com')
        domains << domain
      end
      domains
    end
  end
  
  def curl(domain)
    `curl -s -I http://#{domain}`
  end
  
  def status(domain)
    (line = curl(domain).split("\n")[0]) ? line : 'unknown'
  end
  
  def run
    domains.each do |domain|
      write(domain.ljust(20))
      write(" #{status(domain)}\n")
    end
  end
  
  def write(str)
    self.class.output.write(str)
    self.class.output.flush
  end
  
  def self.run(argv)
    new.run
  end
end