class apt {
  File {
    owner => root,
    group => root
  }

  $apt_provider = $apt_provider ? {
    "" => "apt-get",
    /^apt(-get)?$/ => "apt-get",
    /^aptitude$/ => "aptitude"
  }

# -*- coding: utf-8 -*-
#
# © 2010 Digg, Inc.
# © 2011-2012 Paul Lathrop
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

  exec {
    "apt::update-index":
      command => "/usr/bin/${apt_provider} update",
      logoutput => on_failure,
      user => root;
  }

  file {
    "/etc/apt":
      mode => 0755,
      ensure => directory;
  }

  @file {
    "/etc/apt/sources.list.d":
      mode => 0755,
      ensure => directory;
  }
}
