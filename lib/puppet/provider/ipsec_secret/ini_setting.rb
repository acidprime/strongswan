Puppet::Type.type(:ipsec_secret).provide(
  :ini_setting,
  # set ini_subetting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do
  def section
    ''
  end

  def separator
    if resource[:name] == ''
      ': '
    else
      ' : '
    end
  end

  def setting
    resource[:name]
  end

  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/ipsec.secrets'
  end
end
