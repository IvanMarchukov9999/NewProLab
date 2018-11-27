#!flask/bin/python
import requests
import json
import time
import datetime
from flask import Flask, abort, jsonify

app = Flask(__name__)
app.config["CLICKHOUSE_API_URL"] = "http://172.18.0.11:8123/"
magic_first_tmstmp = 940312910

def get_unixtime_hour_ago():
    hour_ago = datetime.datetime.now() - datetime.timedelta(hours=1)
    return int( time.mktime(hour_ago.timetuple()) * 1e3 + hour_ago.microsecond / 1e3 )

@app.route('/')
def index():
    query = (
        open("CH_check.sql", "r").read()
        
    )
    print(query)
    res = requests.post(
        url=app.config["CLICKHOUSE_API_URL"],
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    return res.text

@app.route("/api/v1.0/users/<int:timestamp>", methods=["GET"])
def get_users(timestamp):
    if timestamp < magic_first_tmstmp:
      abort(404)
    query = (
        open("users_query.sql", "r").read()
    )
    query = query.replace('${time}',str(timestamp))
    print(query)
    res = requests.post(
        url=app.config["CLICKHOUSE_API_URL"],
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    print(res.text)
    data = {
        "timestamp": timestamp,
        "contents": [json.loads(line) for line in res.text.split("\n")[:-1]],
        "check": True,
    }
    return jsonify(data)

@app.route("/api/v1.0/users/", methods=["GET"])
def get_users_hour():
    timestamp = get_unixtime_hour_ago()
    query = (
        open("users_query.sql", "r").read()
    )
    query = query.replace('${time}',str(timestamp))
    print(query)
    res = requests.post(
        url=app.config["CLICKHOUSE_API_URL"],
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    print(res.text)
    data = {
        "timestamp": timestamp,
        "contents": [json.loads(line) for line in res.text.split("\n")[:-1]],
        "check": True,
    }
    return jsonify(data)

@app.route("/api/v1.0/orders/<int:timestamp>", methods=["GET"])
def get_orders(timestamp):
    if timestamp < magic_first_tmstmp:
      abort(404)
    query = (
        open("orders_query.sql", "r").read()
    )
    query = query.replace('${time}',str(timestamp))
    print(query)
    res = requests.post(
        url=app.config["CLICKHOUSE_API_URL"],
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    print(res.text)
    data = {
        "timestamp": timestamp,
        "contents": [json.loads(line) for line in res.text.split("\n")[:-1]],
        "check": True,
    }
    return jsonify(data)

@app.route("/api/v1.0/orders/", methods=["GET"])
def get_orders_hour():
    timestamp = get_unixtime_hour_ago()
    query = (
        open("orders_query.sql", "r").read()
    )
    query = query.replace('${time}',str(timestamp))
    print(query)
    res = requests.post(
        url=app.config["CLICKHOUSE_API_URL"],
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    print(res.text)
    data = {
        "timestamp": timestamp,
        "contents": [json.loads(line) for line in res.text.split("\n")[:-1]],
        "check": True,
    }
    return jsonify(data)

if __name__ == "__main__":
    app.run(host = "0.0.0.0", port=5001, debug = True)
