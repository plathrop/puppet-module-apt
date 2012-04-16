# -*- coding: utf-8 -*-
#
# © 2012 Digg, Inc., Paul Lathrop
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

define apt::key($ensure=present, $id=false, $keyserver='keyserver.ubuntu.com') {
  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  } else {
    fail('Valid values for ensure: present or absent')
  }

  $id_real = $id ? {
    false   => $name,
    default => $id
  }

  if $ensure_real == present {
    exec {
      "apt::key::${name}":
        command => "/usr/bin/apt-key adv --recv-keys --keyserver ${keyserver} ${id_real}",
        unless  => "/usr/bin/apt-key list | /bin/grep ${id_real}"
    }
  }

  if $ensure_real == absent {
    exec {
      "apt::key::${name}":
        command => "/usr/bin/apt-key del ${id_real}",
        onlyif  => "/usr/bin/apt-key list | /bin/grep ${id_real}"
    }
  }
}

# Local Variables:
# puppet-indent-level: 2
# End:
