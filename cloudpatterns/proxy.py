import pymysql
import random
from pythonping import ping
from sshtunnel import SSHTunnelForwarder
from flask import Flask, request, jsonify

master_node = "3.89.249.57"
slave_nodes = ["52.55.178.144", "34.201.103.27", "35.175.198.219"]

app = Flask(__name__)


@app.route('/endpoint', methods=['GET', 'POST'])
def handle_gatekeeper_request():
    # Extract the strategy from the parameters
    strategy = request.args.get('strategy')

    # Extract the body from the request data
    body = request.get_data(as_text=True)

    if strategy == "write":
        node = direct_hit()
    elif strategy == "read":
        node = random_node()
    elif strategy == "customized":
        node = customized()
    else:
        raise ValueError("Invalid strategy")

    # Forward the request to the chosen node
    result = implement_request(node, body)
    return jsonify(result)


def direct_hit():
    # Directly forward the request to the master node
    return master_node


def random_node():
    # Randomly choose a slave node and forward the request to it
    return random.choice(slave_nodes)


def customized():
    # Measure the ping time of all the servers and forward the request to the one with the least response time
    min_ping = float('inf')
    best_node = None
    for node in slave_nodes:
        avg_ping = ping(node, count=10).rtt_avg_ms
        if avg_ping < min_ping:
            min_ping = avg_ping
            best_node = node
    return best_node


def implement_request(node, query):
    with SSHTunnelForwarder(node, ssh_username='ubuntu', ssh_pkey='final_project.pem',
                            remote_bind_address=(master_node, 3306)):
        conn = pymysql.connect(host=master_node, user='ubuntu', password='admin', db='sakila', port=3306, autocommit=True)
        cursor = conn.cursor()
        operation = query
        cursor.execute(operation)
        result = cursor.fetchall()
        print(result)
        conn.close()
        return result

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
