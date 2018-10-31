import io
from pprint import pprint

import avro.schema
import avro.io
from kafka import KafkaConsumer

schema = avro.schema.Parse(open("eventrecord.avsc", "rb").read())
reader = avro.io.DatumReader(schema)

consumer = KafkaConsumer('ivan.marchukov',
                         group_id='my-group',
                         bootstrap_servers=['35.187.111.78:6667'])

for message in consumer:
    print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))

    decoder = avro.io.BinaryDecoder(io.BytesIO(message.value))
    data = reader.read(decoder)

