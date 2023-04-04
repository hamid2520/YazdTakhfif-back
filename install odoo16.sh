install odoo16
#  Installing Required Packages
sudo apt update && sudo apt upgrade 
sudo apt install git wget nodejs npm python3 build-essential libzip-dev python3-dev libxslt1-dev python3-pip libldap2-dev python3-wheel libsasl2-dev python3-venv python3-setuptools node-less libjpeg-dev xfonts-75dpi xfonts-base libpq-dev libffi-dev fontconfig 
sudo npm install -g rtlcss 
# Install wkhtmltopdf
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo apt install -f
# create odoo user
sudo adduser --system --group --home=/opt/odoo16d --shell=/bin/bash odoo16d 
sudo adduser --system --group --home=/opt/odoo16m --shell=/bin/bash odoo16m

# Installing PostgreSQL
sudo apt install postgresql -y
sudo su - postgres -c "createuser -s odoo16d" 
sudo su - postgres -c "createuser -s odoo16m"
sudo su - postgres -c "createuser -s odoo13" 

# Installing Odoo 16 on Ubuntu
cd /opt/odoo16d 
cd /opt/odoo16m
cd /opt/odoo13

scp odoo_16.0+e.latest.tar.gz root@188.209.153.241:/opt/odoo16d
scp /opt/odoo16d/odoo_16.0+e.latest.tar.gz /opt/odoo16m/odoo_16.0+e.latest.tar.gz
tar -xvf  /opt/odoo16d/odoo_16.0+e.latest.tar.gz -C /opt/odoo16d/odoo-server
tar -xvf  /opt/odoo16m/odoo_16.0+e.latest.tar.gz -C /opt/odoo16m/odoo-server

sudo chown -R odoo16d:odoo16d /opt/odoo16d/odoo-server 
sudo chown -R odoo16m:odoo16m /opt/odoo16m/odoo-server 
sudo chown -R odoo13:odoo13 /opt/odoo13/odoo-server 

python3 -m venv venv  
source venv/bin/activate  

pip3 install wheel 
pip3 install -r requirements.txt
deactivate

sudo mkdir /var/log/odoo16m 
sudo chown odoo16m:odoo16m /var/log/odoo16m 
sudo chmod 777 /var/log/odoo16m 

sudo mkdir /var/log/odoo16d
sudo chown odoo16d:odoo16d /var/log/odoo16d
sudo chmod 777 /var/log/odoo16d

sudo mkdir /var/log/odoo13
sudo chown odoo13:odoo13 /var/log/odoo13
sudo chmod 777 /var/log/odoo13

sudo nano /etc/odoo16m-server.conf 
sudo nano /etc/odoo16d-server.conf 
sudo nano /etc/odoo13-server.conf 

[options]
admin_passwd = 1234
db_user = odoo16d
addons_path = /opt/odoo16d/odoo-server/addons
logfile = /var/log/odoo16d/odoo-server.log
log_level  = debug
xmlrpc_port = 8070
longpolling_port = 8078



sudo chown odoo16m:odoo16m /etc/odoo16m-server.conf 
sudo chown odoo16d:odoo16d /etc/odoo16d-server.conf 
sudo chown odoo13:odoo13 /etc/odoo13-server.conf 

sudo nano /etc/systemd/system/odoo16m.service 
sudo nano /etc/systemd/system/odoo16d.service 
sudo nano /etc/systemd/system/odoo13.service 

[Unit]
Description=Odoo 16.0 Main Service 
Requires=postgresql.service
After=network.target postgresql.service
 
[Service]
Type=simple
SyslogIdentifier=odoo16m
PermissionsStartOnly=true
User=odoo16m
Group=odoo16m
ExecStart=/opt/odoo16m/odoo-server/venv/bin/python3 /opt/odoo16m/odoo-server/odoo-bin -c /etc/odoo16m-server.conf
StandardOutput=journal+console
 
[Install]
WantedBy=multi-user.target
########################
[Unit]
Description=Odoo 16.0 Demo Service
Requires=postgresql.service
After=network.target postgresql.service
 
[Service]
Type=simple
SyslogIdentifier=odoo16d
PermissionsStartOnly=true
User=odoo16d
Group=odoo16d
ExecStart=/opt/odoo16d/odoo-server/venv/bin/python3 /opt/odoo16d/odoo-server/odoo-bin -c /etc/odoo16d-server.conf
StandardOutput=journal+console
 
[Install]
WantedBy=multi-user.target
################
[Unit]
Description=Odoo 13.0 Demo Service
Requires=postgresql.service
After=network.target postgresql.service
 
[Service]
Type=simple
SyslogIdentifier=odoo13
PermissionsStartOnly=true
User=odoo13
Group=odoo13
ExecStart=/opt/odoo13/odoo-server/venv/bin/python3 /opt/odoo13/odoo-server/odoo-bin -c /etc/odoo13-server.conf
StandardOutput=journal+console
 
[Install]
WantedBy=multi-user.target
################

sudo systemctl daemon-reload

sudo systemctl enable --now odoo16m.service 
sudo systemctl enable --now odoo16d.service 
sudo systemctl enable --now odoo13.service 

sudo systemctl status odoo16m.service 
sudo systemctl status odoo16d.service 
sudo systemctl status odoo13.service 

sudo apt-get install nginx
cd /etc/nginx/sites-available/
nano odoo16d
nano odoo16m
    nano odoo13




upstream odooerp {
    server 127.0.0.1:8069;
    #server ip2:8069;
    #server ip3:8069;
}
upstream odooerp-im {
    server 127.0.0.1:8072 weight=1 fail_timeout=0;
    #server ip2:8072 weight=1 fail_timeout=0;
    #server ip3:8072 weight=1 fail_timeout=0;
}

##https site##
server {
    listen      443 default_server;
    server_name 16.fadoo.ir;
    root        /usr/share/nginx/html;
    index       index.html index.htm;

    # log files
    access_log  /var/log/nginx/odoo16m.access.log;
    error_log   /var/log/nginx/odoo16m.error.log;

    # ssl files
    ssl on;
    ssl_ciphers                 ALL:!ADH:!MD5:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM;
    ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers   on;
    ssl_certificate             /etc/nginx/ssl/odoo.crt;
    ssl_certificate_key         /etc/nginx/ssl/odoo.key;

    # proxy buffers
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    # timeouts
    proxy_read_timeout 720s;
    proxy_connect_timeout 720s;
    proxy_send_timeout 720s;
    
    ## odoo proxypass with https ##
    location / {
        proxy_pass  http://odooerp;
        # force timeouts if the backend dies
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        # set headers
        proxy_set_header    Host            $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }
    
    location /longpolling/ {
        proxy_pass  http://odooerp-im;
        
        # force timeouts if the backend dies
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
        
        # set headers
        proxy_set_header    Host            $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }    


    # cache some static data in memory for 60mins
    location ~* /web/static/ {
        proxy_cache_valid 200 60m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://odooerp;
    }
    # gzip    
    gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
    gzip on;
    
}

##http redirects to https ##
server {
    listen      80;
    server_name 16.fadoo.ir;

    # Strict Transport Security
    add_header Strict-Transport-Security max-age=2592000;
    rewrite ^/.*$ https://$host$request_uri? permanent;
}




upstream odoo {
    server 127.0.0.1:8070;
}
upstream odoochat {
    server 127.0.0.1:8073 weight=1 fail_timeout=0;
}
## https site##
server {
    listen      443 default;
    server_name www.demo.fadoo.ir demo.fadoo.ir;
    proxy_read_timeout 1000s;
    proxy_connect_timeout 1000s;
    proxy_send_timeout 1000s;
    #root        /usr/share/nginx/html;
    #index       index.html index.htm;
    client_max_body_size 0m;
    # log files
    access_log  /var/log/nginx/odoo.access.log;
    error_log   /var/log/nginx/odoo.error.log;
    # ssl files
    ssl_certificate /etc/letsencrypt/live/demo.fadoo.ir/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/demo.fadoo.ir/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    keepalive_timeout   120;
    # limit ciphers
    # proxy buffers
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    ## default location ##
    location / {
        proxy_pass  http://odoo;
        # force timeouts if the backend dies
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
        # set headers
        proxy_set_header    X-Forwarded-Host $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }
    location /longpolling/ {
        proxy_pass  http://odoochat;
        # force timeouts if the backend dies
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
        # set headers
        proxy_set_header    Host            $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;

    }
    # cache some static data in memory for 60mins
    location ~* /web/static/ {
        proxy_cache_valid 200 60m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://odoo;
    }
    # Gzip
    gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
    gzip on;
}
## http redirects to https ##
server {
    listen      80;
    server_name  www.demo.fadoo.ir demo.fadoo.ir;
    # Strict Transport Security
    add_header Strict-Transport-Security max-age=2592000;
    rewrite ^/.*$ https://$host$request_uri? permanent;
}



certbot certonly --agree-tos --email purhasanih@gmail.com --webroot -w /var/lib/letsencrypt/ -d entodoo.com
/etc/letsencrypt/live/entodoo.com/fullchain.pem
    ssl_certificate_key /etc/letsencrypt/live/entodoo.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/entodoo.com/chain.pem;




createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo16
useradd -m -d /opt/odoo16 -U -r -s /bin/bash odoo16

su - odo