import json
from elasticsearch import Elasticsearch
from elasticsearch.helpers import bulk

client = Elasticsearch(hosts=['localhost'])


def read_lines(f, count):
    lines = []
    while len(lines) < count:
        part = f.readlines(count - len(lines))
        if len(part) == 0:
            break
        lines += part
    return lines


cnt = 0
with open('data.json', 'r') as f:
    while True:
        lines = f.readlines(1000000)
        if len(lines) == 0:
            break
        print('Read %i' % len(lines))
        cnt += len(lines)

        lines = [json.loads(l) for l in lines]

        data = ({
            '_index': "books-index",
            '_type': 'book',
            '_source':
                {
                    'name': l.get('attr1', '').strip(),
                    'annotation': l.get('attr0', '').strip(),
                    'id': int(l['itemid']),
                    'parent_id': int(l.get('parent_id', 0)),
                }} for l in lines)
        bulk(client, data)

print('Total: %i' % cnt)
