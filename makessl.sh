#!/bin/sh
# Auto create vhost and ssl certificate for each folder in www by mhmd1983@gmail.com
tld=".loc"  # change to your custom ltd ex: .test .local or .dev
list='localhost 127.0.0.1 ::1'

cd www
for entry in $(ls -d */);
do
    dir=${entry%%/}
    servn=$dir$tld
    list=$list" "$servn
    FILE=../config/vhosts/$servn.conf
    # check if configuration files exists to prevent overwrite custom edits
    if [ -f "$FILE" ]; then
        echo "$FILE exists."
    else         
        echo "#### $servn ###
        <VirtualHost *:80>
        ServerName $servn
        DocumentRoot \${APACHE_DOCUMENT_ROOT}/$dir
            <Directory \${APACHE_DOCUMENT_ROOT}/$dir>
        AllowOverride all
            </Directory>
        </VirtualHost> 
        <VirtualHost *:443>
        ServerName $servn
        DocumentRoot \${APACHE_DOCUMENT_ROOT}/$dir
            <Directory \${APACHE_DOCUMENT_ROOT}/$dir>
                AllowOverride all
            </Directory>
        SSLEngine on
        SSLCertificateFile /etc/apache2/ssl/cert.pem
        SSLCertificateKeyFile /etc/apache2/ssl/cert-key.pem
        </VirtualHost>" > $FILE
        
        echo "$servn Virtual host created !"
    fi
done
cd ..
# create ssl certificate
mkcert -key-file config/ssl/cert-key.pem -cert-file config/ssl/cert.pem $list;
mkcert -install
# restarting docker
docker-compose restart