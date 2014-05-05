class phpmyadmin (
	$php_version = "5.4.17",
	$src_dir = "${boxen::config::configdir}/phpmyadmin",
	$source = "https://github.com/phpmyadmin/phpmyadmin.git"
) {
#"
	include boxen::config
	include mysql::config
	include nginx::config
	include nginx

	# Download source code
	repository { $src_dir:
		source => $source
	}

	# Add site to nginx conf folder
	file { "${nginx::config::sitesdir}/phpmyadmin.conf":
		content => template("phpmyadmin/nginx.conf.erb"),
		require => File[$nginx::config::sitesdir],
		notify  => Service['dev.nginx'],
	}
	
	file { "${src_dir}/config.inc.php":
		content => template("phpmyadmin/config.inc.php.erb"),
		require => Repository[$src_dir],
	}

	# Set the local version of PHP
	php::local { $src_dir:
		version => $php_version,
		require => Repository[$src_dir],
	}

	# Spin up a PHP-FPM pool listening on an Nginx socket
	php::fpm::pool { "phpmyadmin":
		version     => $php_version,
		socket_path => "${boxen::config::socketdir}/phpmyadmin",
		require     => File["${nginx::config::sitesdir}/phpmyadmin.conf"],
	}


}