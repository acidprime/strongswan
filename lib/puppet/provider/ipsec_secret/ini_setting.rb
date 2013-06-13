Puppet::Type.type(:ipsec_secret).provide(
  :ini_setting,
  # set ini_subetting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do
  def section
    ''
  end

  def separator
      ':'
  end

  def setting
    resource[:name]
  end

  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/ipsec.secrets'
  end
  def self.instances
    # this code is here to support purging and the query-all functionality of the
    # 'puppet resource' command, on a per-file basis.  Users
    # can create a type for a specific config file with a provider that uses
    # this as its parent and implements the method
    # 'self.file_path', and that will provide the value for the path to the
    # ini file (rather than needing to specify it on each ini setting
    # declaration).  This allows 'purging' to be used to clear out
    # all settings from a particular ini file except those included in
    # the catalog.
    if self.respond_to?(:file_path)
      # figure out what to do about the seperator
      ini_file  = Puppet::Util::IniFile.new(file_path, ':')
      resources = []
      ini_file.section_names.each do |section_name|
        ini_file.get_settings(section_name).each do |setting, value|
          resources.push(
            new(
              :name   => "#{setting}",
              :value  => value,
              :ensure => :present
            )
          )
        end
      end
      resources
    else
      raise(Puppet::Error, 'Ini_settings only support collecting instances when a file path is hard coded')
    end
  end

end
