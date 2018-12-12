#!/bin/bash

apt-get update -y

apt-get install -y -q postgresql postgresql-contrib

# sudo su postgres -c "createdb -E UTF8 -T template0 --locale=en_US.utf8 -O vagrant wtm"
cp /etc/postgresql/9.5/main/pg_hba.conf /etc/postgresql/9.5/main/pg_hba.orig.conf
cp /vagrant/pg_hba.conf /etc/postgresql/9.5/main/pg_hba.conf

cp /etc/postgresql/9.5/main/postgresql.conf /etc/postgresql/9.5/main/postgresql.orig.conf
cp /vagrant/postgresql.conf /etc/postgresql/9.5/main/postgresql.conf

sudo systemctl reload postgresql

cp /vagrant/db_setup.sql /tmp/db_setup.sql
sed -i 's/MATTERMOST_PASSWORD/#MATTERMOST_PASSWORD/' /tmp/db_setup.sql
echo "Setting up database"
su postgres -c "psql -f /tmp/db_setup.sql"
rm /tmp/db_setup.sql

rm -rf /opt/mattermost
echo "Downloading Mattermost"
wget --quiet https://releases.mattermost.com/5.5.0/mattermost-5.5.0-linux-amd64.tar.gz
echo "Unzipping Mattermost"
tar -xzf mattermost*.gz

rm mattermost*.gz
mv mattermost /opt

mkdir /opt/mattermost/data
echo "Creating Mattermost User"
useradd --system --user-group mattermost
chown -R mattermost:mattermost /opt/mattermost

chmod -R g+w /opt/mattermost
echo "Copying Config File"
# "mmuser:mostest@tcp(dockerhost:3306)/mattermost_test?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s",
rm /opt/mattermost/config/config.json
ln -s /vagrant/config.json /opt/mattermost/config/config.json
sed -i -e 's/mostest/#MATTERMOST_PASSWORD/g' /opt/mattermost/config/config.json

ln -s /vagrant/mattermost.service /lib/systemd/system/mattermost.service
systemctl daemon-reload

echo '127.0.0.1		internal.bigapplebank.com' >> /etc/hosts

echo "Starting PostgreSQL"
service postgresql start
echo "Starting Mattermost!"
service mattermost start

apt-get -y install nginx

ln -s /vagrant/nginx.conf /etc/nginx/sites-available/mattermost

rm /etc/nginx/sites-enabled/default

ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost

service nginx restart