#Install apps
sudo apt-get update
sudo apt-get install -y mysql-server sysbench

#Install sakila
wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -xvzf sakila-db.tar.gz
sudo cp -r sakila-db /home/

#Populate database structure
sudo mysql -u root -e "SOURCE /home/sakila-db/sakila-schema.sql;"
sudo mysql -u root -e "SOURCE /home/sakila-db/sakila-data.sql;"

#Run sysbench read and write tests
sudo sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql prepare
sudo sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql --threads=6 --time=60 --max-requests=0 run | sudo tee -a /home/standalone_benchmarks.txt
sudo sysbench oltp_read_write --table-size=100000 --mysql-user=root --mysql-db=sakila --db-driver=mysql cleanup