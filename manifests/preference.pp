# -*- coding: utf-8 -*-
#
# © 2012 Paul Lathrop
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

define apt::preference (
    $ensure='present',
    $content=false,
    $source=false)
{
    include apt

    if ! ($ensure in ['present', 'absent'] ) {
        fail("Valid values for ensure: present, absent")
    }

    if $content and $source {
        fail("Cannot specify both content and source!")
    }

    file {
        "/etc/apt/preferences.d/${name}.pref":
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            ensure  => $ensure,
            content => $content ? {
                false   => undef,
                default => $content
            },
            source => $source ? {
                false   => undef,
                default => $source
            },
    }
}
