# -*- coding: utf-8 -*-
#
# © 2011,2012 Paul Lathrop
# © 2010 Digg, Inc.
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

# apt
# @contact: paul@tertiusfamily.net
#
# == Description
#    Module to configure apt sources and their associated keys.
#
# == Sample Usage
#    $puppetlabs_apt_key_id = '4BD6EC30'
#    apt::key { $::puppetlabs_apt_key_id: ensure => present; }
#    apt::source { 'puppetlabs':
#      url      => 'http://apt.puppetlabs.com',
#      dists    => [$lsbistcodename],
#      sections => 'main',
#      require  => Apt::Key[$puppetlabs_apt_key_id],
#    }

class apt {
    exec { 'apt::update-index':
        command   => "/usr/bin/apt-get update",
        logoutput => on_failure,
        user      => 'root',
    }

    @file { '/etc/apt/sources.list.d':
        owner => 'root',
        group => 'root',
        mode => '0755',
        ensure => directory,
    }

    @file { '/etc/apt/preferences.d':
        owner => 'root',
        group => 'root',
        mode => '0755',
        ensure => directory,
    }
}
