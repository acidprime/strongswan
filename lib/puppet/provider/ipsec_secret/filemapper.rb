require 'puppetx/filemapper'

Puppet::Type.type(:ipsec_secret).provide(:filemapper) do
  include PuppetX::FileMapper

  def self.target_files
    '/etc/ipsec.secrets'
  end

  def self.parse_file(filename, file_contents)
    lines = file_contents.split("\n")
    #ipsec_secret_regex = %r/^(?<selector>.*|)\s?:\s?(?<type>\S+)\s?(?<secret>\S+)/
    ipsec_secret_regex = %r/^(.*|)\s?:\s?(\S+)\s?(\S+)/
    lines.collect { |line| line.match(ipsec_secret_regex) }.compact.collect do |m|
      hash = Hash.new
      hash[:name]   = m[1]
      hash[:type]   = m[2]
      hash[:secret] = m[3]
      hash
    end
  end

  def select_file
    '/etc/ipsec.secrets'
  end

  def self.format_file(filename, providers)
    providers.collect do |provider|
      line = ""
      if provider.secret  =~ /.*\.pem/
        line += ": #{provider.type} #{provider.secret}"
      else
        line += "#{provider.name} : #{provider.type} #{provider.secret}"
      end
      line += "\n"
    end.join
  end
end
