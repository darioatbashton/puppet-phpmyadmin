# == Class: phpmyadmin
#
# === Parameters
#
# [path] The path to install phpmyadmin to (default: /srv/phpmyadmin).
# [user] The user that should own that directory (default: www-data).
# [revision] The revision  (default: origin/STABLE).
# [servers] An array of servers (default: []).
#
# === Examples
#
#  class { 'phpmyadmin':
#    path     => "/srv/phpmyadmin",
#    user     => "www-data",
#    revision => "origin/RELEASE_4_0_9",
#    servers  => [
#      {
#        desc => "local",
#        host => "127.0.0.1",
#      },
#      {
#        desc => "other",
#        host => "192.168.1.30",
#      }
#    ]
#  }
#
# === Authors
#
# Arthur Leonard Andersen <leoc.git@gmail.com>
#
# === Copyright
#
# See LICENSE file, Arthur Leonard Andersen (c) 2013

# Class:: phpmyadmin
#
#
class phpmyadmin (
  $path         = '/srv/phpmyadmin',
  $user         = 'www-data',
  $downloadurl  = 'https://files.phpmyadmin.net/phpMyAdmin/4.5.5.1/phpMyAdmin-4.5.5.1-all-languages.zip',
  $servers      = [],
) {

  file { $path:
    ensure => directory,
    owner  => $user,
  }

  ->

  exec { "fetch_phpmyadmin":
    command   => "/usr/bin/wget -q ${downloadurl} -O ${path}/phpMyAdmin.zip",
    creates => "${path}/phpMyAdmin.zip",
  }->

  package { "unzip":
    ensure => 'present',
  }->
  exec { "unzip_phpmyadmin":
    cwd     => "${path}",
    command => "/usr/bin/unzip phpMyAdmin.zip && cd phpMyAdmin-* && mv * ../ && cd - && rmdir phpMyAdmin-*",
    creates => "${path}/build.xml",
  }->
  exec { "chown_phpmyadmin":
    command   => "/bin/chown -R ${user} ${path}",
  }->

  file { 'phpmyadmin-conf':
    path    => "${path}/config.inc.php",
    content => template('phpmyadmin/config.inc.php.erb'),
    owner   => $user,
  }

} # Class:: phpmyadmin
