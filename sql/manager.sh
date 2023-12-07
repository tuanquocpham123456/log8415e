# Install apps
sudo apt-get update
sudo apt-get install -y libncurses5 sysbench

# Set up MySQL Cluster
sudo mkdir -p /opt/mysqlcluster/home
cd /opt/mysqlcluster/home
sudo wget http://dev.mysql.com/get/Downloads/MySQL-Cluster-7.2/mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz
sudo tar xvf mysql-cluster-gpl-7.2.1-linux2.6-x86_64.tar.gz
sudo ln -s mysql-cluster-gpl-7.2.1-linux2.6-x86_64 mysqlc
echo "export MYSQLC_HOME=/opt/mysqlcluster/home/mysqlc" | sudo tee -a /etc/profile.d/mysqlc.sh
echo "export PATH=\$MYSQLC_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/mysqlc.sh
source /etc/profile.d/mysqlc.sh
sudo mkdir -p /opt/mysqlcluster/deploy
cd /opt/mysqlcluster/deploy
sudo mkdir conf mysqld_data ndb_data
cd conf

echo "
[mysqld]
ndbcluster
datadir=/opt/mysqlcluster/deploy/mysqld_data
basedir=/opt/mysqlcluster/home/mysqlc
[mysql_cluster]
ndb-connectstring=ip-172-31-17-1.ec2.internal" | sudo tee -a my.cnf

echo "
[ndb_mgmd]
hostname=ip-172-31-17-1.ec2.internal
datadir=/opt/mysqlcluster/deploy/ndb_data
nodeid=1
[ndbd default]
noofreplicas=3
datadir=/opt/mysqlcluster/deploy/ndb_data
[ndbd]
hostname=ip-172-31-17-2.ec2.internal
nodeid=2
[ndbd]
hostname=ip-172-31-17-3.ec2.internal
nodeid=3
[ndbd]
hostname=ip-172-31-17-4.ec2.internal
nodeid=4
[mysqld]
nodeid=50" | sudo tee -a config.ini

sudo systemctl restart mysql   # Restart MySQL to pick up the new config
sudo systemctl enable mysql   # Enable MySQL to start on boot

cd /opt/mysqlcluster/home/mysqlc/bin/

sudo ./ndb_mgmd -f /opt/mysqlcluster/deploy/conf/config.ini --initial --configdir=/opt/mysqlcluster/deploy/conf

# Install sakila
sudo wget https://downloads.mysql.com/docs/sakila-db.tar.gz
sudo tar -xvzf sakila-db.tar.gz

# Populate database structure
sudo mysql -u root -e "SOURCE /home/sakila-db/sakila-schema.sql;"
sudo mysql -u root -e "SOURCE /home/sakila-db/sakila-data.sql;"

# Run sysbench read and write tests
sudo sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql prepare
sudo sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql --threads=6 --time=60 --max-requests=0 run | sudo tee -a /home/manager_benchmarks.txt
sudo sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql cleanup
