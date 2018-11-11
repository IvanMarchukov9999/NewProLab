#!flask/bin/python
from flask import Flask, abort, jsonify

app = Flask(__name__)


@app.route('/')
def index():
    return "Это API для чекера"


@app.route('/api/v1.0/users/<int:timestamp>', methods=['GET'])
def get_users(timestamp):
    if timestamp < 940312918:
      abort(404)
    return jsonify({'users': 'data'})


@app.route('/api/v1.0/orders/<int:timestamp>', methods=['GET'])
def get_users(timestamp):
    if timestamp < 940312918:
      abort(404)
    return jsonify({'users': 'data'})

if __name__ == '__main__':
    app.run(debug=True,host = "0.0.0.0", port=5001)