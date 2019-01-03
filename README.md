# certhousekeeping
script to autoupdate letsencrypt certificates for lighttpd

Script to deal with letsencrypt certificates and a lighttpd webserver which is called twice a day. Running and tested under Ubuntu 18.04.1 LTS

## File locations:
    certhousekeeping.sh => /root/certhousekeeping.sh
    certbot.cron        => /etc/cron.d/certbot

## lighttpd configuration example:
```


root@x:~# cat /etc/lighttpd/lighttpd.conf
server.modules = (
	"mod_access",
	"mod_alias",
	"mod_compress",
 	"mod_redirect",
	"mod_fastcgi",
)

server.document-root        = "/var/www/html"
server.upload-dirs          = ( "/var/cache/lighttpd/uploads" )
server.errorlog             = "/var/log/lighttpd/error.log"
server.pid-file             = "/var/run/lighttpd.pid"
server.username             = "www-data"
server.groupname            = "www-data"
server.port                 = 80


index-file.names            = ( "index.php", "index.html", "index.lighttpd.html" )
url.access-deny             = ( "~", ".inc" )
static-file.exclude-extensions = ( ".php", ".pl", ".fcgi" )

compress.cache-dir          = "/var/cache/lighttpd/compress/"
compress.filetype           = ( "application/javascript", "text/css", "text/html", "text/plain" )

#
# force redirect to https site:
#
$HTTP["scheme"] == "http" {
	$HTTP["host"] == "fi.m.net" { # HTTP URL
		url.redirect = ("/.*" => "https://fi.m.net$0") # Redirection HTTPS URL
	}
	$HTTP["host"] == "wiki.m.net" { # HTTP URL
		url.redirect = ("/.*" => "https://wiki.m.net$0") # Redirection HTTPS URL
	}

root@x:~# cat /etc/lighttpd/conf-enabled/10-ssl.conf
# /usr/share/doc/lighttpd/ssl.txt

$SERVER["socket"] == ":443" {
	ssl.engine  = "enable"
	ssl.pemfile = "/etc/letsencrypt/live/fi.m.net/web.pem"
        ssl.ca-file = "/etc/letsencrypt/live/fi.m.net/chain.pem"
	$HTTP["host"] == "wiki.m.net" {
		ssl.engine  = "enable"
		ssl.pemfile = "/etc/letsencrypt/live/wiki.m.net/web.pem"
		ssl.ca-file = "/etc/letsencrypt/live/wiki.m.net/chain.pem"
		# ssl.cipher-list = "ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH:!AESGCM"
		# ssl.honor-cipher-order = "enable"
	}
}
}

root@x:~# cat /etc/lighttpd/conf-enabled/00-wiki.m.net.conf
$HTTP["host"] == "wiki.m.net" { #FDQN

server.document-root = "/var/www/wiki.m.net/" # Document-root of the webserver
accesslog.filename = "/var/log/lighttpd/wiki.m.net_access.log" # Web server Access log file
# deprecated: there is only on errorlog with lighttpd: server.errorlog = "/var/log/lighttpd/wiki.m.net_error.log" # Web server Error log file
$HTTP["url"] =~ "^/dokuwiki" {
  server.follow-symlink = "enable"
}

$HTTP["url"] =~ "/(\.|_)ht" {
  url.access-deny = ( "" )
}
$HTTP["url"] =~ "^/dokuwiki/(bin|data|inc|conf)" {
  url.access-deny = ( "" )
}
}
```
