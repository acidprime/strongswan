Puppet::Type.newtype(:ipsec_secret) do
  ensurable
  newparam(:name, :namevar => true) do
    desc 'setting:type to manage from ipsec.secrets'
    # namevar should be of the form section/setting
    newvalues(/\S+?:\S+/)
  end
  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |v|
      v.to_s.strip
    end
  end
end
