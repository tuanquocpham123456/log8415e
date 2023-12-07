#Install apps
sudo apt-get update
sudo apt-get install -y mysql-server sysbench

#Install sakila
wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -xvzf sakila-db.tar.gz
cp -r sakila-db /home/

#Populate database structure
mysql -u root -e "SOURCE /home/sakila-db/sakila-schema.sql;"
mysql -u root -e "SOURCE /home/sakila-db/sakila-data.sql;"

#Run sysbench read and write tests
sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql prepare
sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql --num-threads=6 --max-time=60 --max-requests=0 run >> /home/standalone_benchmarks.txt
sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql cleanup