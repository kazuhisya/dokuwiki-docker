#!/bin/bash -eu

if [ -f /var/www/localhost/htdocs/index.php ]; then
    echo "/var/www/localhost/htdocs/* is already exist, skip extract."
else
    # extract tgz
    echo "first run."
    tar xf /dokuwiki.tgz --strip 1 -C /var/www/localhost/htdocs/
    rm -f dokuwiki-stable.tgz
    rm -f /var/www/localhost/htdocs/index.html
    mv /var/www/localhost/htdocs/.htaccess.dist /var/www/localhost/htdocs/.htaccess
fi

# Start httpd
httpd -D FOREGROUND
