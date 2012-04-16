# -*- coding: utf-8 -*-
#
# © 2010 Digg, Inc.
# © 2011,2012 Paul Lathrop
# Author: Paul Lathrop <paul@tertiusfamily.net>
#

define apt::source($enable=true, $deb_src=true, $url, $dists=['stable'],
                   $sections=['main', 'contrib', 'non-free']) {
  include apt

  $list=inline_template("deb $url $distribution $sections
<% if deb_src -%>
deb-src $url $distribution $sections
<% end %>")

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

# Local Variables:
# puppet-indent-level: 2
# End:
