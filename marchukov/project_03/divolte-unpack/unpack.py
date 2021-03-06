import io
import sys
import json

import avro.schema
import avro.io
from kafka import KafkaConsumer, KafkaProducer

GROUP = 'unpacker'
TOPIC = 'ivan.marchukov'

schema = avro.schema.Parse(open("eventrecord.avsc", "rb").read())
reader = avro.io.DatumReader(schema)

consumer = KafkaConsumer(TOPIC,
                         group_id=GROUP,
                         bootstrap_servers=['35.187.111.78:6667'],
                         enable_auto_commit=True,
                         auto_offset_reset='earliest')

producer = KafkaProducer(bootstrap_servers=['35.187.111.78:6667'], value_serializer=lambda m: json.dumps(m).encode('utf8'))

def read_listen():
    for message in consumer:
        # print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
        #                                      message.offset, message.key,
        #                                      message.value))

        try:
            decoder = avro.io.BinaryDecoder(io.BytesIO(message.value))
            data = reader.read(decoder)
            #data = { k: data[k] for k in ('timestamp', 'sessionId', 'location', 'price')}
            producer.send('json_events', data)
            print(data)
        except Exception as e:
            print('Parse error: ', e, file=sys.stderr)
            print(message.value, file=sys.stderr)

if __name__ == '__main__':
    read_listen()

