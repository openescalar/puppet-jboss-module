class jbossas ( 

  $javapath 		= '/usr/jvm/lib/java',
  $javaminheap 		= 128,
  $javamaxheap		= 512

) {

  yumrepo { 

    'jpackage-generic-5.0':
      mirrorlist     => 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0',
      failovermethod => 'priority',
      gpgcheck       => '1',
      gpgkey         => 'http://www.jpackage.org/jpackage.asc',
      enabled        => '1',
  }

  package {

    'jpackage-utils-compat-el5':
      ensure   => 'installed',
      provider => 'rpm',
      source   => 'http://candrews.integralblue.com/wp-content/uploads/2009/07/jpackage-utils-compat-el5-0.0.1-1.noarch.rpm';
 
    'jbossas':
      ensure  => 'installed',
      require => [
        Package['jpackage-utils-compat-el5'],
        Yumrepo['jpackage-generic-5.0'],
      ];
 
    'mysql-connector-java':
      ensure => 'latest';

  }


  file { 

    '/usr/share/java/ecj.jar':
      ensure => link,
      target => '/usr/share/java/eclipse-ecj.jar';

    '/etc/jbossas/jbossas.conf':
      content  => template('jboss/jbossas.conf.erb'),
      owner   => 'jboss',
      group   => 'jboss',
      mode    => '0644',
      require => Package['jbossas'];

    '/etc/jbossas/run.conf':
      content  => template('jboss/run.conf.erb'),
      owner   => 'jboss',
      group   => 'jboss',
      mode    => '0644',
      require => Package['jbossas'];

  }

  service { 

    'jbossas':
      ensure     => running,
      require    => [
        Package['jbossas']
      ],
      subscribe  => [
        Package['jbossas'],
        File['/etc/jbossas/jbossas.conf'],
        File['/etc/jbossas/run.conf'],
      ];

  }

  cron { 

    'jboss-compress':
      ensure  => present,
      command => '/usr/bin/bzip2 /var/log/jbosss/default/server.log.????-??-??',
      user    => jboss,
      hour    => 1,
      minute  => 0,
      require => Package['jbossas'];

  }
}

class jbossas::log4j inherits jbossas {

  package { 

    'jboss-common-logging-log4j':
      ensure => 'installed'r;,

  }

  file { 

    '/etc/jbossas/default/jboss-log4j.xml':
      source  => 'puppet:///modules/jboss/jboss-log4j.xml',
      owner   => 'jboss',
      group   => 'jboss',
      mode    => '0644',
      require => Package['jbossas'],
      notify  => Service['jbossas'],

  }
}
