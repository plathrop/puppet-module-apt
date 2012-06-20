# -*- coding: utf-8 -*-
#
# © 2011,2012 Paul Lathrop
# © 2010 Digg, Inc.
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

define apt::source (
    $url,
    $enable=true,
    $deb_src=true,
    $dists=['stable'],
    $sections=['main', 'contrib', 'non-free'])
{
    include apt

    if ! ("$enable" in [ 'true', 'false' ]) {
        fail('Valid values for enable: true, false')
    }

    $list = template('apt/source.list.erb')

    file {
        "/etc/apt/sources.list.d/${name}.list":
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => $enable ? {
                true => "${list}",
                default => undef,
            },
            ensure => $enable ? {
                false => absent,
                default => present,
            },
            notify => Exec["apt::update-index"];
    }
}
