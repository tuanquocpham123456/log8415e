# LOG8415e : Final project

## Terraform
In order to lunch the infrastructure with all the instances, you need to run ```terraform apply``` inside the **log8415e/sql** folder.

## MySQL
Inside all the next instances, you will need to clone the repository before doing the rest of the commands :
1. git clone https://github.com/tuanquocpham123456/log8415e.git
2. cd log8415e/sql

### MySQL Standalone
1. bash standalone.sh

It will install Sakila, populate the database structure and run the Sysbench benchmark.
### MySQL Manager
1. bash manager.sh
2. bash manager_sysbench.sh

The first command will setup the MySQL cluster manager.
The second command will install Sakila, populate the database structure and run the Sysbench benchmark.

### On all the MySQL workers
1. bash worker.sh

This will set up each worker and connect it to the MySQL cluster manager.

## Proxy pattern