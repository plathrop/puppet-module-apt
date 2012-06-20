### -*- coding: utf-8 -*-
###
### © 2012 Krux Digital, Inc. See manifests/archive/LICENSE.md for
### details.
###
### Author: Paul Lathrop <paul@krux.com>
###
###
### = Class: apt::archive::setup
###
###   Installs basic resources needed to support the apt::archive
###   defined type.
###
### == Parameters:
###
###    [$apt_utils_version] The version of the 'apt-utils' package to
###                         install. Defaults to 'installed'.
###
### == Actions:
###
###   - Install apt-utils
###
### == Requires:
###
###   - None
###
class apt::archive::setup (
    $apt_utils_version = 'installed'
) {
    package { 'apt-utils': ensure => $apt_utils_version }
}
