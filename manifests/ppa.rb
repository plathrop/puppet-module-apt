define 'apt::ppa' do
  include 'apt'

  command = "add-apt-repository #{@name}"
  _, team, ppa = @name.split(/[:\/]/,3)

  dist = scope.lookupvar('lsbdistcodename')

  creates = "#{scope.lookupvar('apt::root')}/sources.list.d/#{team}-#{ppa}-#{dist}.list"

  package 'python-software-properties', :ensure => 'present'

  create_resource('exec', command, {
    :creates => creates,
    :require => ['Package[python-software-properties]', 'File[sources.list.d]']
  })
end
