# Installs VirtualBox
#
# Usage:
#
#   include virtualbox

class virtualbox (
  $version = '5.0.16',
  $patch_level = '105871',
) {

  include wget

  $download     = "http://download.virtualbox.org/virtualbox/${version}"
  $verpl        = "${version}-${patch_level}"
  $extpath      = "/tmp/extpack-${verpl}.box-extpack"
  $extpack_name = 'Oracle_VM_VirtualBox_Extension_Pack'
  $vboxmanage   = '/Applications/VirtualBox.app/Contents/MacOS/VBoxManage'
  $killcmds     = [
    'pkill "VBoxXPCOMIPCD" || true',
    'pkill "VBoxSVC" || true',
    'pkill "VBoxHeadless" || true'
  ]
  $killcmd      = join($killcmds, ' && ')

  exec { 'Kill Virtual Box Processes':
    command     => $killcmd,
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
    source      => "${download}/${extpack_name}-${verpl}.vbox-extpack",
    destination => $extpath,
    timeout     => 0,
    verbose     => false,
    notify      => Exec['Install ExtPack'],
  }

  exec { 'Install ExtPack':
    require     => Package["VirtualBox-${verpl}"],
    command     => "${vboxmanage} extpack install --replace ${extpath}",
    refreshonly => true,
  }

}
