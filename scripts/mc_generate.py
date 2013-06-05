#!/usr/bin/python -tt
__author__ = 'Zack Smith @acidprime'
__version__ = '0.1'
import os
import sys
import getopt
import plistlib

global debugEnabled
debugEnabled = True

def main():
  if(debugEnabled): print 'Processing Arguments: ', sys.argv[1:]
  options, remainder = getopt.getopt(sys.argv[1:], 'n:w:u:p:r:i:o:d:D:I:', [
    'username=',
    'password=',
    'write=',
    'remote=',
    'description=',
    'identifier=',
    'identity=',
    'name=',
    'display_name=',
    'organization=',
    ])
  params = {}
  for opt, arg in options:
    if opt in ('-u', '--username'):
      params['XAuthName'] = arg
    if opt in ('-d', '--description'):
      params['PayloadDescription'] = arg
    if opt in ('-I', '--identity'):
      params['p12'] = arg
    if opt in ('-i', '--identifier'):
      params['PayloadIdentifier'] = arg
    if opt in ('-p', '--password'):
      params['Password'] = arg
    if opt in ('-r', '--remote'):
      params['RemoteAddress'] = arg
    if opt in ('-w', '--write'):
      params['saveFile'] = arg
    if opt in ('-o', '--organization'):
      params['PayloadOrganization'] = arg
    if opt in ('-n', '--name'):
      params['UserDefinedName'] = arg
      params['PayloadDisplayName'] = arg
# Generate the profile
  vpnProfile(params)

def vpnProfile(params={}):
  plist = {}

  # PayloadContent
  PayloadContent = []
  _IPSec = {}
  _IPSec['AuthenticationMethod']   = 'Certificate'
  _IPSec['OnDemandEnabled']        = 0
  _IPSec['PayloadCertificateUUID'] = '27BB0CB6-41BF-44B4-A269-D61764038E13'
  _IPSec['PromptForVPNPIN']        = False
  _IPSec['RemoteAddress']          = params['RemoteAddress']
  _IPSec['XAuthEnabled']           = 1
  _IPSec['XAuthName']              = params['XAuthName']

  _IPv4 = {}
  _IPv4['OverridePrimary'] = 0

  _PayloadContent_1 = {}
  _PayloadContent_1['IPSec']  = _IPSec
  _PayloadContent_1['IPv4']   = _IPv4
  _PayloadContent_1['PayloadDescription']  = 'Configures VPN settings'
  _PayloadContent_1['PayloadDisplayName']  = 'VPN (%s)' % params['RemoteAddress']
  _PayloadContent_1['PayloadIdentifier']   = params['PayloadIdentifier']
  _PayloadContent_1['PayloadOrganization'] = params['PayloadOrganization']
  _PayloadContent_1['PayloadType']         = 'com.apple.vpn.managed'
  _PayloadContent_1['PayloadUUID']         = 'AB7DB9F5-4B4F-41EB-A71D-14CCC3FF3B4C'
  _PayloadContent_1['PayloadVersion']      = 1
  _PayloadContent_1['Proxies']             = {}
  _PayloadContent_1['UserDefinedName']     = params['UserDefinedName']
  _PayloadContent_1['VPNType']             = 'IPSec'

  _PayloadContent_2 = {}
  _PayloadContent_2['PayloadCertificateFileName'] = 'ca.pem'

  #openssl x509 -in /etc/puppetlabs/puppet/ssl/certs/ca.pem -inform PEM -outform DER -out /etc/puppetlabs/puppet/ssl/certs/ca.cer
  ca_pem = open('/etc/puppetlabs/puppet/ssl/certs/ca.cer').read()

  _PayloadContent_2['PayloadContent']             = plistlib.Data(ca_pem)
  _PayloadContent_2['PayloadDescription']         = 'Provides device authentication (certificate or identity).'
  _PayloadContent_2['PayloadDisplayName']         = 'Puppet Certificate Authority'
  _PayloadContent_2['PayloadIdentifier']          = '%s.ca' % params['PayloadIdentifier']
  _PayloadContent_2['PayloadOrganization']        = params['PayloadOrganization']
  _PayloadContent_2['PayloadType']                = 'com.apple.security.root'
  _PayloadContent_2['PayloadUUID']                = '3092EC79-CAC0-4E52-B99C-89225296EF06'
  _PayloadContent_2['PayloadVersion']             = 1

  _PayloadContent_3  = {}
  _PayloadContent_3['Password']            = params['Password']

  p12 = open(params['p12']).read()

  _PayloadContent_3['PayloadCertificateFileName']  = os.path.basename(params['p12'])
  _PayloadContent_3['PayloadContent']      = plistlib.Data(p12)
  _PayloadContent_3['PayloadDescription']  = 'Provides device authentication (certificate or identity).'
  _PayloadContent_3['PayloadDisplayName']  = os.path.basename(params['p12'])
  _PayloadContent_3['PayloadIdentifier']   = '%s.credential' % params['PayloadIdentifier']
  _PayloadContent_3['PayloadOrganization'] = params['PayloadOrganization']
  _PayloadContent_3['PayloadType']         = 'com.apple.security.pkcs12'
  _PayloadContent_3['PayloadUUID']         = '27BB0CB6-41BF-44B4-A269-D61764038E13'
  _PayloadContent_3['PayloadVersion']      = 1

  PayloadContent = [ _PayloadContent_1,_PayloadContent_2,_PayloadContent_3 ]

  plist['PayloadContent']           = PayloadContent
  plist['PayloadDescription']       = params['PayloadDescription']
  plist['PayloadDisplayName']       = params['PayloadDisplayName']
  plist['PayloadIdentifier']        = params['PayloadIdentifier']
  plist['PayloadOrganization']      = params['PayloadOrganization']
  plist['PayloadType']              = 'Configuration'
  plist['PayloadUUID']              = 'B8DF8DAD-BEE8-4A13-81BE-C3EEA4607FC0'
  plist['PayloadVersion']           = 1
  plist['PayloadRemovalDisallowed'] = False

  print plist
  exportFile = params['saveFile']
  plistlib.writePlist(plist,exportFile)
  saveFile = plistlib.readPlist(exportFile)
  plistlib.writePlist(saveFile,exportFile)
  return exportFile

if __name__ == "__main__":
  sys.exit(main())
