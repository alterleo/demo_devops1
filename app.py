from flask import Flask
import socket


app = Flask(__name__)

@app.route('/')
def hello():
  print(socket)
  return '<p> ver. 1.0 <h1>\n' + 'Hostname: ' + socket.gethostname() + '</h1>'

if __name__ == "__main__":
  app.run(host="0.0.0.0", port=8000, debug=True)