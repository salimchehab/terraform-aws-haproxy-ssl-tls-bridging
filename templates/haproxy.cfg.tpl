global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# tune.ssl.default-dh-param is by default set to 1024
	tune.ssl.default-dh-param 2048

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# Default ciphers to use on SSL-enabled listening sockets.
	# For more information, see ciphers(1SSL). This list is from:
	#  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
	# An alternative list with additional directives can be obtained from
	#  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
	ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
	ssl-default-bind-options no-sslv3

defaults
	log	global
    log 127.0.0.1 len 65335 local0
	mode	http
	option	httplog
	option	dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s

frontend ft_myapp
	bind *:443 ssl crt ${crt}
	# redirect from http to https if not made with an SSL connection
	redirect scheme https if !{ ssl_fc }
	# allow access to request body
	option http-buffer-request
	# capture slot with a max length 40000 and reference 0
    declare capture request len 40000
    http-request capture req.body id 0
	# log format for request body
    # log-format {"%[capture.req.hdr(0)]"}
	log-format frontend:%f/%H/%fi:%fp\ client:%ci:%cp\ GMT:%T\ body:%[capture.req.hdr(0)]\ request:%r

	default_backend bk_myapp

backend bk_myapp
    server ${backend-1} ${backend-1}.${domain}:${flask_port} maxconn ${maxconn} check ssl ca-file ${ca-file}
    server ${backend-2} ${backend-2}.${domain}:${flask_port} maxconn ${maxconn} check ssl ca-file ${ca-file}
