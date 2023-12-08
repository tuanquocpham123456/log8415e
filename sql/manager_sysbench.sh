# Install sakila
sudo wget https://downloads.mysql.com/docs/sakila-db.tar.gz
sudo tar -xvzf sakila-db.tar.gz
sudo cp -r sakila-db /home/

# Populate database structure
sudo mysql -u root -e "SOURCE /home/sakila-db/sakila-schema.sql;"
sudo mysql -u root -e "SOURCE /home/sakila-db/sakila-data.sql;"

# Run sysbench read and write tests
sudo sysbench oltp_read_write --table-size=100000 --mysql_storage_engine=ndbcluster --mysql-user=root --mysql-db=sakila --db-driver=mysql prepare
sudo sysbench oltp_read_write --table-size=100000 --mysql_storage_engine=ndbcluster --mysql-user=root --mysql-db=sakila --db-driver=mysql --threads=6 --time=60 --max-requests=0 run | sudo tee -a /home/manager_benchmarks.txt
sudo sysbench oltp_read_write --table-size=100000 --mysql_storage_engine=ndbcluster --mysql-user=root --mysql-db=sakila --db-driver=mysql cleanup