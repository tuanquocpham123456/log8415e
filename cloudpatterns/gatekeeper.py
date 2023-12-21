from flask import Flask, request
import requests

app = Flask(__name__)
proxy_node = "52.90.97.174"


@app.route('/endpoint', methods=['GET', 'POST'])
def handle_request():
    # Extract the body from the incoming request
    body = request.form.get('query')

    # Validate the request
    if request.method == 'POST':
        strategy = "write"
        # Forward the request to the Proxy
        response = requests.post(f"https://{proxy_node}/endpoint", params={"strategy": strategy}, data=body)
    else:
        strategy = "read"
        # Forward the request to the Proxy
        response = requests.get(f"https://{proxy_node}/endpoint", params={"strategy": strategy}, data=body)

    return response.content


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
