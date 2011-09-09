class Amiok
  POSSIBLE_LOCATIONS = %w(
    /etc/apache2
    /etc/httpd
  )
  GOOD_RESPONSES = %w(200 301 302 401 403)
  
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
    `grep -r -i -e 'server\\(name\\|alias\\)' #{apache_directory} 2> /dev/null`
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
    if status_line = curl(domain).split("\n")[0]
      status = status_line.split(' ', 2)[-1]
      status.split(' ', 2)
    else
      ['', "Can't find server"]
    end
  end
  
  def _failed
    domains.inject([]) do |failed, domain|
      status_code, status_message = status(domain)
      write('.')
      unless GOOD_RESPONSES.include?(status_code)
        failed << { 'domain' => domain, 'status_code' => status_code, 'status_message' => status_message }
      end
      failed
    end
  end
  
  def failed
    @failed ||= _failed
  end
  
  def run
    just = failed.map { |f| f['domain'].length }.max
    write("\n")
    failed.each do |f|
      write("#{f['domain'].ljust(just + 5)}#{f['status_message']}\n")
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