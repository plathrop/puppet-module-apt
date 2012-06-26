### -*- coding: utf-8 -*-
###
### © 2012 Krux Digital, Inc. See manifests/archive/LICENSE.md for
### details.
###
### Author: Paul Lathrop <paul@krux.com>
###
###
### = Defined Type: apt::archive::release
###
###   Defined type for release files. Only meant to be used internally
###   by apt::archive.
###
### == Parameters:
###
###  [$name] The name of the dist to generate a Release file for.
###
###  [$repository] The path to the package repository.
###
###  [$sections] Array of 'sections' in the repository. Defaults to
###              ["main"].
###
###  [$architectures] Array of architectures in the
###                   repository. Defaults to ["i385", "amd64", "all",
###                   "source"]
###
###  [$owner] Owner of the package repository directory and
###           contents. Defaults to 'root'.
###
###  [$group] Group of the package repository directory and
###           contents. Defaults to 'root'.
###
###  [$mode] Permissions for the package repository and
###          contents. Defaults to '0644' (remember that Puppet always
###          sets the execute bit on directories.)
###
### == Actions:
###
###   - Create the configuration file for the 'apt-ftparchive release'
###     command.
###
###   - Run 'apt-ftparchive release' to generate the release file.
###
### == Requires:
###
###   - Class['apt::archive::setup']
###
define apt::archive::release (
    $repository,
    $sections      = ["main"],
    $architectures = ["i386", "amd64", "all", "source"],
    $ensure        = present,
    $owner         = 'root',
    $group         = 'root',
    $mode          = '0644'
) {
    ##########################
    ### Internal Variables ###
    ##########################
    $_release_conf = "${repository}/release.conf.${name}"

    #####################################
    ### Create the configuration file ###
    #####################################
    file { $_release_conf:
        ensure  => $ensure,
        content => template('apt/release.conf.erb'),
        owner   => $owner,
        group   => $group,
        mode    => $mode,
    }

    #################################
    ### Generate the release file ###
    #################################
    $_release_dir   = "${repository}/dists/${name}"
    $_release_fname = "${_release_dir}/Release"
    exec { "apt-ftparchive release ${repository}/dists/${name}":
        command => "/usr/bin/apt-ftparchive -c ${_release_conf} release ${_release_dir} | tee ${_release_fname}",
        user    => $owner,
        creates => $_release_fname,
        require => Class['apt::archive::setup'],
    }
}
