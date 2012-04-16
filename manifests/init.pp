# -*- coding: utf-8 -*-
#
# © 2010 Digg, Inc.
# © 2011-2012 Paul Lathrop
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

class apt ($provider='apt-get') {
  exec { 'apt::update-index':
      command   => "/usr/bin/${apt_provider} update",
      logoutput => on_failure,
      user      => root,
  }

  file { '/etc/apt':
    owner  => 'root',
    group  => 'root',
    mode   => 0755,
    ensure => directory,
  }

  @file { '/etc/apt/sources.list.d':
    owner => 'root',
    group => 'root',
    mode => 0755,
    ensure => directory,
  }
}

# Local Variables:
# puppet-indent-level: 2
# End:
