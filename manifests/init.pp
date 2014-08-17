class logstash {
$kibana_version = "3.0.1"
$logstash_version = "1.4"
$elasticsearch_version = "1.1.1-1"

yumrepo { "logstash":
  baseurl  => "http://packages.elasticsearch.org/logstash/${logstash_version}/centos",
  descr    => "Logstash repository for ${logstash_version}",
  enabled  => 1,
  gpgcheck => 0,
}


  package { 'java-1.7.0-openjdk':
    ensure => installed,
  allow_virtual => true,
  }

  package { 'logstash':
    ensure => installed,
   allow_virtual => true,
  }

class { 'elasticsearch':
  version => "${elasticsearch_version}",
  manage_repo  => true,
  repo_version => '1.1',
}
elasticsearch::instance { 'es-01': }

      file { 'input_log2redis.conf':
        path    => '/etc/logstash/conf.d/input_log2redis.conf',
        ensure  => file,
        require => Package['logstash'],
        content => template("logstash/input_log2redis.conf.erb"),
      }
      file { 'output_log2redis.conf':
        path    => '/etc/logstash/conf.d/output_log2redis.conf',
        ensure  => file,
        require => Package['logstash'],
        content => template("logstash/output_log2redis.conf.erb"),
      }
      file { 'redis2elasticsearch.conf':
        path    => '/etc/logstash/conf.d/redis2elasticsearch.conf',
        ensure  => file,
        require => Package['logstash'],
        content => template("logstash/redis2elasticsearch.conf.erb"),
      }

class { 'rsyslog::server':
        enable_tcp                => true,
        enable_udp                => true,
        enable_onefile            => false,
        server_dir                => '/var/log/hosts',
        custom_config             => 'rsyslog/server-hostname.conf.erb',
        high_precision_timestamps => false,
    }
class { 'nginx': }
nginx::resource::vhost { 'logstash.home.lan':
  www_root => '/var/www/logstash.home.lan',
  listen_port => 8080
}
class { 'kibana': 
  install_destination => '/var/www/', # Default: /opt
}
file { '/var/www/logstash.home.lan':
   ensure => 'link',
   target => '/var/www/kibana',
}

}
