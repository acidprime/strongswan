Puppet::Type.newtype(:ipsec_secret) do
  ensurable

  newparam(:name, :namevar => true) do
    isrequired
    desc "The selector used for the secret"
  end

  newproperty(:type) do
    desc "The type of secret, defaults to XAUTH"
    newvalues('RSA','ECDSA','PSK','EAP','NTLM','XAUTH','PIN')
    defaultto 'XAUTH'
  end

  newproperty(:secret) do
    isrequired
    desc "The ipsec secret or filename"
  end

end
