#!/bin/sh
sudo apt install jq

wget "https://github.com/miku/esbulk/releases/download/v0.5.1/esbulk_0.5.1_amd64.deb"
sudo apt install ./esbulk_0.5.1_amd64.deb

wget "http://data.cluster-lab.com/data-newprolab-com/project02/item_details_full?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181013%2F%2Fs3%2Faws4_request&X-Amz-Date=20181013T103635Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=eb8d824e55bd0c50c4ea5adcc5a034f19a6bd1d51a0ada17f8ff3e92885e305f"
wget "http://data.cluster-lab.com/data-newprolab-com/project02/catalogs?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181013%2F%2Fs3%2Faws4_request&X-Amz-Date=20181013T103619Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=a71f86444926896adcb545c9eb18a1417452db9a9587a3aa45d508c43b35ae77"
wget "http://data.cluster-lab.com/data-newprolab-com/project02/catalog_path?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181013%2F%2Fs3%2Faws4_request&X-Amz-Date=20181013T103555Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=1614d2c58972e0e4dcc459be3a548d6f31b21a049c7a72175d01d8208c74a24c"
wget "http://data.cluster-lab.com/data-newprolab-com/project02/ratings?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181013%2F%2Fs3%2Faws4_request&X-Amz-Date=20181013T103652Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=bfa043b8850d639c00764e49d6cd24ed4d0892054ade97552a6061396efe4a35"

curl -X PUT "http://35.240.76.111:9200/item_details" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "filter": {
        "ru_stop": {
          "type": "stop",
          "stopwords": "_russian_"
        },
        "ru_stemmer": {
          "type": "stemmer",
          "language": "russian"
        }
      },
      "analyzer": {
        "my_analyzer": {
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "ru_stop",
            "ru_stemmer"
          ]
        }
      }
    }
  },
  "mappings": {
    "_doc": {
      "properties": {
        "annotation": {
          "type": "text",
          "analyzer": "my_analyzer"
        },
        "name": {
          "type": "keyword",
          "analyzer": "my_analyzer"
        },
        "author": {
          "type": "keyword",
          "analyzer": "my_analyzer"
        },
        "itemid": {
          "type": "long"
        },
        "parent_id": {
          "type": "long"
        }
      }
    }
  }
}
'

cat item_details_full.json | \
  jq  -c '.["annotation"] = .attr0 | .["name"] = .attr1 | .["author"] = .attr2 | {annotation, name, author, itemid, parent_id}' | \
  esbulk -verbose -server http://0.0.0.0:9200 -index item_details -purge -size 10000 -mapping mapping.json

  

