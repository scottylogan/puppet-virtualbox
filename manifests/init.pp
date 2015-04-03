# Installs VirtualBox
#
# Usage:
#
#   include virtualbox


class virtualbox (
  $version = '4.3.26',
  $patch_level = '98988',
) {

  include wget

  $download = "http://download.virtualbox.org/virtualbox/${version}"
  $verpl    = "${version}-${patch_level}"
  $extpath  = "/tmp/extpack-${verpl}.box-extpack"

  exec { 'Kill Virtual Box Processes':
    command     => 'pkill "VBoxXPCOMIPCD" || true && pkill "VBoxSVC" || true && pkill "VBoxHeadless" || true',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
  }

  package { "VirtualBox-${verpl}":
    ensure   => installed,
    provider => 'pkgdmg',
    source   => "${download}/VirtualBox-${verpl}-OSX.dmg",
    require  => Exec['Kill Virtual Box Processes'],
  }

  wget::fetch { 'Download ExtPack':
    source      => "${download}/Oracle_VM_VirtualBox_Extension_Pack-${verpl}.vbox-extpack",
    destination => $extpath,
    timeout     => 0,
    verbose     => false,
    notify      => Exec['Install ExtPack'],
  }

  exec { 'Install ExtPack':
    require     => Package["VirtualBox-${verpl}"],
    command     => "/usr/bin/VBoxManage extpack install --replace ${extpath}",
    refreshonly => true,
  }

}
