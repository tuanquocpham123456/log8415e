from flask import Flask, request
import requests

app = Flask(__name__)
proxy_node = "3.80.118.157"


@app.route('/endpoint', methods=['GET', 'POST'])
def handle_request():
    # Extract the body from the incoming request
    body = request.form.get('query')
    code = request.form.get('code')

    match code:
        case "1":
            strategy = "direct_hit"
        case "2":
            strategy = "random"
        case "3":
            strategy = "customized"
        case _:
            raise ValueError("Invalid strategy")

    # Validate the request
    if request.method == 'POST':
        # Forward the request to the Proxy
        response = requests.post(f"http://{proxy_node}/endpoint", params={"strategy": strategy}, data=body)
    else:
        # Forward the request to the Proxy
        response = requests.get(f"http://{proxy_node}/endpoint", params={"strategy": strategy}, data=body)

    return response.content


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
