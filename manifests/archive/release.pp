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
###  [$keyid] ID of a GPG key. This key will be used to sign the
###           release metadata. The key must be installed in the GPG
###           keychain of $owner. The key *must not* be protected by a
###           passphrase. See http://bit.ly/MnisxJ for instructions on
###           how to generate a signing subkey for this purpose. You
###           should strongly consider setting an expiration for this
###           subkey. If this parameter is not provided, the release
###           metadata will not be signed.
###
###  [$gpghome] GnuPG home directory. Defaults to the default for the
###             gpg command (usually ~/.gnupg).
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
    $mode          = '0644',
    $keyid         = false,
    $gpghome       = false
) {
    ##########################
    ### Internal Variables ###
    ##########################
    $_name_components = split($name, '[.]')
    $_my_name         = $_name_components[1]
    $_release_conf = "${repository}/release.conf.${_my_name}"

    $_gpghome = $gpghome ? {
        false   => '',
        default => "--homedir ${gpghome}",
    }

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

    ########################################
    ### Generate & sign the release file ###
    ########################################
    $_release_dir   = "${repository}/dists/${_my_name}"
    $_release_fname = "${_release_dir}/Release"
    exec { "apt-ftparchive release ${repository}/dists/${_my_name}":
        command => "/usr/bin/apt-ftparchive -c ${_release_conf} release ${_release_dir} | tee ${_release_fname}",
        user    => $owner,
        creates => $_release_fname,
        require => Class['apt::archive::setup'],
    }

    if $keyid {
        $_sig_fname = "${_release_fname}.gpg"
        $_gpg_key   = "--default-key ${keyid}"
        exec { "gpg sign release ${name}":
            command     => "/usr/bin/gpg ${_gpghome} ${_gpg_key} --output ${_sig_fname} --detach-sign --armor ${_release_fname}",
            user        => $owner,
            creates     => $_sig_fname,
            subscribe   => Exec["apt-ftparchive release ${repository}/dists/${_my_name}"],
        }
    }
}
