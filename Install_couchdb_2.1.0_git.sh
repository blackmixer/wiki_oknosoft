#!/bin/sh
#set -e

apt-get update
sudo apt-get --no-install-recommends -y install \
    build-essential pkg-config erlang erlang-reltool \
    libicu-dev libmozjs185-dev libcurl4-openssl-dev
sudo apt-get --no-install-recommends -y install \
    python-sphinx
#apt install runit
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs runit
# скачиваем couchdb
git clone https://github.com/apache/couchdb
# перейдём в архив
cd couchdb/
#./configure && make release
# Добавим пользователя couchdb
adduser --system \
        --no-create-home \
        --shell /bin/bash \
        --group --gecos \
        "CouchDB Administrator" couchdb
# права
cp -R rel/couchdb /home/couchdb
chown -R couchdb:couchdb /home/couchdb
find /home/couchdb -type d -exec chmod 0770 {} \;
sh -c 'chmod 0644 /home/couchdb/etc/*'
# логи
mkdir /var/log/couchdb
chown couchdb:couchdb /var/log/couchdb

mkdir /etc/sv/couchdb
mkdir /etc/sv/couchdb/log

cat > run << EOF
#!/bin/sh
export HOME=/home/couchdb
exec 2>&1
exec chpst -u couchdb /home/couchdb/bin/couchdb
EOF

cat > log_run << EOF
#!/bin/sh
exec svlogd -tt /var/log/couchdb
EOF

mv ./run /etc/sv/couchdb/run
mv ./log_run /etc/sv/couchdb/log/run

chmod u+x /etc/sv/couchdb/run
chmod u+x /etc/sv/couchdb/log/run

ln -s /etc/sv/couchdb/ /etc/service/couchdb

sleep 5
sv status couchdb
