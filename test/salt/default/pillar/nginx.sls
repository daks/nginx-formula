
# ========
# nginx.ng
# ========

#nginx:
#  ng:
#    snippets:
#      letsencrypt:
#        - location ^~ /.well-known/acme-challenge/:
#          - proxy_pass: http://localhost:9999
#
#    server:
#      opts: {}
#
#      config:
#        include: 'snippets/letsencrypt.conf'
#        source_path: salt://path_to_nginx_conf_file/nginx.conf # IMPORTANT: This option is mutually exclusive with the rest of the
#                                                          # options; if it is found other options (worker_processes: 4 and so
#                                                          # on) are not processed and just upload the file from source
#        worker_processes: 4
#        load_module: modules/ngx_http_lua_module.so  # pass as very first in configuration; otherwise nginx will fail to start
#        #pid: /var/run/nginx.pid                     # Directory location must exist (i.e. it's  /run/nginx.pid on EL7)
#        events:
#          worker_connections: 1024
#        http:
#          sendfile: 'on'
#          include:
#            #### Note: Syntax issues in these files generate nginx [emerg] errors on startup.  ####
#            - /etc/nginx/mime.types
#
#          ### module ngx_http_log_module example
#          log_format: |-
#            main '...';
#              access_log /var/log/nginx/access_log main
#          access_log: []       #suppress default access_log option from being added
#
#        ### module nngx_stream_core_module
#        ### https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/#example
#        stream:
#          upstream lb-1000:
#            - server:
#              - hostname1.example.com:1000
#              - hostname2.example.com:1000
#          upstream stream_backend:
#            least_conn: ''
#            'server backend1.example.com:12345 weight=5':
#            'server backend2.example.com:12345 max_fails=2 fail_timeout=30s':
#            'server backend3.example.com:12345 max_conns=3':
#          upstream dns_servers:
#            least_conn:
#            'server 192.168.136.130:53':
#            'server 192.168.136.131:53':
#            'server 192.168.136.132:53':
#          server:
#            listen: 1000
#            proxy_pass: lb-1000
#          'server ':
#            listen: '53 udp'
#            proxy_pass: dns_servers
#          'server   ':
#            listen: 12346
#            proxy_pass: backend4.example.com:12346
#
#
#    servers:
#      disabled_postfix: .disabled # a postfix appended to files when doing non-symlink disabling
#      symlink_opts: {} # partially exposes file.symlink params when symlinking enabled sites
#      rename_opts: {} # partially exposes file.rename params when not symlinking disabled/enabled sites
#      managed_opts: {} # partially exposes file.managed params for managed server files
#      dir_opts: {} # partially exposes file.directory params for site available/enabled and snippets dirs
#
#
#      #####################
#      # server declarations; placed by default in server "available" directory
#      #####################
#      managed:
#
#        mysite:  # relative filename of server file  (defaults to '/etc/nginx/sites-available/mysite')
#          # may be True, False, or None where True is enabled, False, disabled, and None indicates no action
#          enabled: True
#
#          # Remove the site config file shipped by nginx (i.e. '/etc/nginx/sites-available/default' by default)
#          # It also remove the symlink (if it is exists).
#          # The site MUST be disabled before delete it (if not the nginx is not reloaded).
#          #deleted: True
#
#          #available_dir: /etc/nginx/sites-available-custom   # custom directory (not sites-available) for server filename
#          #enabled_dir: /etc/nginx/sites-enabled-custom       # custom directory (not sites-enabled) for server filename
#          disabled_name: mysite.aint_on                       # an alternative disabled name to be use when not symlinking
#          overwrite: True                                     # overwrite an existing server file or not
#
#          # May be a list of config options or None, if None, no server file will be managed/templated
#          # Take server directives as lists of dictionaries. If the dictionary value is another list of
#          # dictionaries a block {} will be started with the dictionary key name
#          config:
#            - server:
#              - server_name: localhost
#              - listen:
#                - '80 default_server'
#              - listen:
#                - '443 ssl'
#              - index: 'index.html index.htm'
#              - location ~ .htm:
#                - try_files: '$uri $uri/ =404'
#                - test: something else
#              - include: 'snippets/letsencrypt.conf'
#
#          # Or a slightly more compact alternative syntax:
#
#            - server:
#              - server_name: localhost
#              - listen:
#                - '80 default_server'
#                - '443 ssl'
#              - index: 'index.html index.htm'
#              - location ~ .htm:
#                - try_files: '$uri $uri/ =404'
#                - test: something else
#              - include: 'snippets/letsencrypt.conf'
#
#          # both of those output:
#          # server {
#          #    server_name localhost;
#          #    listen 80 default_server;
#          #    listen 443 ssl;
#          #    index index.html index.htm;
#          #    location ~ .htm {
#          #        try_files $uri $uri/ =404;
#          #        test something else;
#          #    }
#          # }
#
#        mysite2: # Using source_path options to upload the file instead of templating all the file
#          enabled: True
#          available_dir: /etc/nginx/sites-available
#          enabled_dir: /etc/nginx/sites-enabled
#          config:
#            source_path: salt://path-to-site-file/mysite2
#
#        # Below configuration becomes handy if you want to create custom configuration files
#        # for example if you want to create /usr/local/etc/nginx/http_options.conf with
#        # the following content:
#
#        # sendfile on;
#        # tcp_nopush on;
#        # tcp_nodelay on;
#        # send_iowait 12000;
#
#        http_options.conf:
#          enabled: True
#          available_dir: /usr/local/etc/nginx
#          enabled_dir: /usr/local/etc/nginx
#          config:
#            - sendfile: 'on'
#            - tcp_nopush: 'on'
#            - tcp_nodelay: 'on'
#            - send_iowait: 12000
#
#    certificates_path: '/etc/nginx/ssl'  # Use this if you need to deploy below certificates in a custom path.
#    # If you're doing SSL termination, you can deploy certificates this way.
#    # The private one(s) should go in a separate pillar file not in version
#    # control (or use encrypted pillar data).
#    certificates:
#      'www.example.com':
#
#        # choose one of: deploying this cert by pillar (e.g. in combination with ext_pillar and file_tree)
#        # public_cert_pillar: certs:example.com:fullchain.pem
#        # private_key_pillar: certs:example.com:privkey.pem
#        # or directly pasting the cert
#        public_cert: |
#          -----BEGIN CERTIFICATE-----
#          (Your Primary SSL certificate: www.example.com.crt)
#          -----END CERTIFICATE-----
#          -----BEGIN CERTIFICATE-----
#          (Your Intermediate certificate: ExampleCA.crt)
#          -----END CERTIFICATE-----
#          -----BEGIN CERTIFICATE-----
#          (Your Root certificate: TrustedRoot.crt)
#          -----END CERTIFICATE-----
#        private_key: |
#          -----BEGIN RSA PRIVATE KEY-----
#          (Your Private Key: www.example.com.key)
#          -----END RSA PRIVATE KEY-----
#
#    dh_param:
#      'mydhparam1.pem': |
#        -----BEGIN DH PARAMETERS-----
#        (Your custom DH prime)
#        -----END DH PARAMETERS-----
#      # or to generate one on-the-fly
#      'mydhparam2.pem':
#        keysize: 2048
#
#    # Passenger configuration
#    # Default passenger configuration is provided, and will be deployed in
#    # /etc/nginx/conf.d/passenger.conf
#    passenger:
#      passenger_root: /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini
#      passenger_ruby: /usr/bin/ruby
#      passenger_instance_registry_dir: /var/run/passenger-instreg
