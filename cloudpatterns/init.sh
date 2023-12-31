# Update the package lists for upgrades and new package installations
sudo apt-get update

# Install Python3 and pip3
sudo apt-get install -y python3 python3-pip

# Install the Flask framework for Python3
sudo apt install -y python3-flask

# Install the Python3 virtual environment package
sudo apt install -y python3.10-venv

# Install the virtualenv package
pip3 install virtualenv

# Create a virtual environment named 'venv'
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install Flask, requests, pymysql, pythonping, and sshtunnel Python libraries
sudo pip3 install flask requests pymysql pythonping sshtunnel