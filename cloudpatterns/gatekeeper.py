from flask import Flask, request
import requests

app = Flask(__name__)
proxy_node = "PROXY_IP_ADDRESS"


@app.route('/endpoint', methods=['GET', 'POST'])
def handle_request():
    # Validate the request
    strategy = "write" if request.method == 'POST' else "read"

    # Extract the body from the incoming request
    body = request.get_data(as_text=True)

    # Forward the request to the Proxy
    response = requests.get(f"http://{proxy_node}/endpoint", params={"strategy": strategy}, data=body)

    return response.content


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
