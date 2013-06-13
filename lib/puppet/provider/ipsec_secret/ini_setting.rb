Puppet::Type.type(:ipsec_secret).provide(
  :ini_setting,
  # set ini_setting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do
  def section
    ''
  end

  def separator
    ' '
  end


  # implement setting as the first part of the namevar
  def setting
    resource[:name].split(':', 2).first
  end

  def subsetting
    resource[:name].split(':', 2).last
  end

  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/strongswan/ipsec.secrets'
  end
end
