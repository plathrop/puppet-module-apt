# -*- coding: utf-8 -*-
#
# © 2011,2012 Paul Lathrop
# © 2010 Digg, Inc.
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

define apt::key(
    $ensure=present,
    $id=false,
    $keyserver='keyserver.ubuntu.com')
{
    if ! ($ensure in [ present, absent ]) {
        fail('Valid values for ensure: present or absent')
    }

    $id_real = $id ? {
        false   => $name,
        default => $id
    }

    if $ensure == present {
        exec { "apt::key::${name}":
            command => "/usr/bin/apt-key adv --recv-keys --keyserver ${keyserver} ${id_real}",
            unless  => "/usr/bin/apt-key list | /bin/grep ${id_real}"
        }
    }

    if $ensure == absent {
        exec { "apt::key::${name}":
            command => "/usr/bin/apt-key del ${id_real}",
            onlyif  => "/usr/bin/apt-key list | /bin/grep ${id_real}"
        }
    }
}
