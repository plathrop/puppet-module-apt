### -*- coding: utf-8 -*-
###
### © 2012 Krux Digital, Inc. See LICENSE.md for details.
### Author: Paul Lathrop <paul@krux.com>
###
###

module Puppet::Parser::Functions
  newfunction(:apt_archive_pool_dirs, :type => :rvalue) do |args|
    base_dir = args[0] + 'pool/'
    sections = args[1]
    sections.map {|section|
      [base_dir, section].join(File::SEPARATOR)
    }
  end
end
