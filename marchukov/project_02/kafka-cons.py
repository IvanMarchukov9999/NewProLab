import io
import re
from pprint import pprint

import avro.schema
import avro.io
from kafka import KafkaConsumer

import psycopg2


def connect_db():
    try:
        return psycopg2.connect("host='192.168.99.100' dbname='metrics' user='dataeng' password='12345678'")
    except:
        print("I am unable to connect to the database")
        exit(1)


def save(message):
    sess = message['sessionId']
    time = message['timestamp']
    loc = message['location']
    print(sess, time, loc)

    if loc.endswith('/korzina/'):  # Покупка
        ref = message['referer']
        m = re.search('/item/(.*)/', ref)
        item_id = m.group(1)
        print(item_id)

    conn = connect_db()
    cur = conn.cursor()
    cur.execute('INSERT INTO users(sess, time, url) VALUES (%s, %s, %s)', (sess, time, loc))
    conn.commit()
    cur.close()
    conn.close()


GROUP = 'my-group'
TOPIC = 'ivan.marchukov'

schema = avro.schema.Parse(open("eventrecord.avsc", "rb").read())
reader = avro.io.DatumReader(schema)

consumer = KafkaConsumer(TOPIC,
                         group_id=GROUP,
                         bootstrap_servers=['35.187.111.78:6667'])

def read_listen():
    for message in consumer:
        # print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
        #                                      message.offset, message.key,
        #                                      message.value))

        try:
            decoder = avro.io.BinaryDecoder(io.BytesIO(message.value))
            data = reader.read(decoder)
            #pprint(data)
            # print(data['location'])
            save(data)
        except:
            print(message.key, message.value)

def poll_and_save():
    polled = consumer.poll(timeout_ms=6000)
    for part in polled:
        for message in polled[part]:
            decoder = avro.io.BinaryDecoder(io.BytesIO(message.value))
            data = reader.read(decoder)
            #print(data)
            save(data)

    print("Complete")

if __name__ == '__main__':
    read_listen()
    #poll_and_save()
