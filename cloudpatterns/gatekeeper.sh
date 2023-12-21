# Install Uncomplicated Firewall
sudo apt-get install -y ufw

# Install iptables-persistent
sudo apt install -y iptables-persistent

# Allow only necessary ports
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# Enable the firewall
sudo ufw enable

# This command adds a rule to the INPUT chain of the iptables firewall.
# It allows incoming TCP connections on ports 80 (HTTP) and 443 (HTTPS) that are either new or already established.
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# This command adds a rule to the OUTPUT chain of the iptables firewall.
# It allows outgoing TCP connections from ports 80 (HTTP) and 443 (HTTPS) that are already established.
sudo iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Save IP tables rules
sudo netfilter-persistent save

# Activate the virtual environment
source venv/bin/activate
# Run the gatekeeper.py script
python3 gatekeeper.py