#!flask/bin/python
import requests
import json
import time
import datetime
from flask import Flask, abort, jsonify

app = Flask(__name__)
app.config["CLICKHOUSE_API_URL"] = "http://172.18.0.11:8123/"

@app.route('/')
def index():
    return "This is API for checker!"

@app.route("/api/v1.0/users/<int:timestamp>", methods=["GET"])
def get_users(timestamp):
    if timestamp < 940312918:
      abort(404)
    query = (
        open("get_users.sql", "r").read()
        
    )
    res = requests.post(
        url=app.config["CLICKHOUSE_API_URL"],
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    data = {
        "timestamp": timestamp,
        "contents": [json.loads(line) for line in res.text.split("\n")[:-1]],
        "check": True,
    }
    return jsonify(data)

if __name__ == "__main__":
    app.run(host = "0.0.0.0", port=5001)
