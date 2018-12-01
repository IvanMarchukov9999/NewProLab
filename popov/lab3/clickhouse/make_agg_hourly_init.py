#!/usr/bin/env python3
from datetime import datetime, timedelta

import requests

CH_URL = "http://172.18.0.11:8123/"
script_name = "make_aggs.sql"


def get_datetime_range(start, end, delta):
    current = start
    while current < end:
        yield current
        current += delta


def get_hour_by_day_dict(since_date):
    dts = {int(dt.timestamp()): int(dt.replace(minute=0, hour=0, second=0, microsecond=0).timestamp())
           for dt in get_datetime_range(since_date, datetime.today(), timedelta(hours=1))}
    return dts


def run_query(query):
    res = requests.post(
        url=CH_URL,
        data=query,
        headers={"Content-Type": "application/octet-stream"},
    )
    return res.text


def run_script(dt_00, dt_hh):
    query = (
        open("make_aggs.sql", "r").read()
    )
    query = query.replace('${day_00}', str(dt_00)).replace('${day_hh}', str(dt_hh))
    print(query)
    return run_query(query)


if __name__ == "__main__":
    # get dates
    since_date = datetime(2018, 11, 25)
    dates = get_hour_by_day_dict(since_date)

    # insert data hourly
    for dt_hh, dt_00 in dates.items():
        print("{0} : {1}", dt_hh, dt_00)
        print(run_script(dt_00, dt_hh))
    print(run_query("OPTIMIZE table site.repo_agg;"))
