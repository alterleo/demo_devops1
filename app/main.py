from flask import Flask, jsonify
import socket

app = Flask(__name__)


@app.route('/')
def hello():
    return '<p>Ver. 1.0. <h1>Hostname: ' + socket.gethostname() + '</h1>'


@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
