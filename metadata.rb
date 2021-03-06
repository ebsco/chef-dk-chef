# Encoding: UTF-8

name             'chef-dk'
maintainer       'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license          'Apache v2.0'
description      'Installs/configures the Chef-DK'
long_description 'Installs/configures the Chef-DK'
version          '3.0.1'

depends          'dmg', '~> 2.2'

supports         'ubuntu', '>= 12.04'
supports         'debian', '>= 6.0'
%w(redhat centos scientific amazon).each do |os|
  supports       os, '>= 6.0'
end
supports         'mac_os_x', '>= 10.8'
supports         'windows'
