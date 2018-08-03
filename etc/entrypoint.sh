#!/bin/sh
echo "Configuring nginx..."
echo "LETSENCRYPT=${LETSENCRYPT:=$LETSENCRYPT}"

if [ ${LETSENCRYPT} != "true" ]; then
    echo "Cerificates is disabled"
    sed -i "s|return 301 https://\$host\$request_uri|index index.html index.htm|g" /etc/nginx/nginx.conf
    nginx -g "daemon off;"
    return 1
fi

mkdir -p /etc/nginx/conf.d

#Generate Diffie-Hellman key
if [ ! -f /etc/nginx/ssl/dh2048.pem ]; then
    mkdir -p /etc/nginx/ssl
    cd /etc/nginx/ssl
    openssl dhparam -out dh2048.pem 2048
    chmod 600 dh2048.pem
    echo "Successful created dh2048.pem"
fi


# Set key paths
echo "your domain=${DOMAIN:=$DOMAIN}"
echo "your email=${EMAIL:=$EMAIL}"
FILE_KEY=/etc/nginx/ssl/certificates/_.${DOMAIN}.key
FILE_CRT=/etc/nginx/ssl/certificates/_.${DOMAIN}.crt
echo "your SSL_KEY=${FILE_KEY}"
echo "your SSL_CRT=${FILE_CRT}"

mv -f /etc/nginx/shamuel.com.conf /etc/nginx/conf.d/shamuel.com.conf
mv -f /etc/nginx/blog.shamuel.com.conf /etc/nginx/conf.d/blog.shamuel.com.conf

(
while :
do
  mv -v /etc/nginx/conf.d /etc/nginx/conf.d.old
  sleep 10
  if [ ! -f /etc/nginx/ssl/certificates/_.${DOMAIN}.key ]; then
    lego -a --path=/etc/nginx/ssl --email="${EMAIL}" --domains="*.${DOMAIN}" --domains="${DOMAIN}" --domains="www.${DOMAIN}" --dns="route53" --http=:81 run #Generate new certificates
  else
    lego -a --path=/etc/nginx/ssl --email="${EMAIL}" --domains="*.${DOMAIN}" --domains="${DOMAIN}" --domains="www.${DOMAIN}" --dns="route53" --http=:81 renew #Update certificates
  fi
  mv -v /etc/nginx/conf.d.old /etc/nginx/conf.d
  echo "Restart nginx..."
  nginx -s reload
  sleep 80d
done
)&

nginx -g "daemon off;"
exit $?
