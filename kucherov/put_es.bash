#!/usr/bin/env bash

ROOT_PATH=~/nplde3

RATINGS=ratings.json
CATALOG_PATH=catalog_path.json
ITEM_DETAILS_FULL=item_details_full.json

if [ ! -d ${ROOT_PATH} ]; then
	mkdir -p  ${ROOT_PATH}/tmp
else 
	rm -rf ${ROOT_PATH}
	mkdir -p  ${ROOT_PATH}/tmp
fi

# wget --output-document=${ROOT_PATH}/${RATINGS} "http://data.cluster-lab.com/data-newprolab-com/project02/ratings?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181018%2F%2Fs3%2Faws4_request&X-Amz-Date=20181018T152317Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=91511c781965137bc0e1d3a63a50a05ffac13d4e3900e99fd39d38d865434e8a"
# wget --output-document=${ROOT_PATH}/${CATALOG_PATH} "http://data.cluster-lab.com/data-newprolab-com/project02/catalog_path?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181018%2F%2Fs3%2Faws4_request&X-Amz-Date=20181018T152137Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=fcee8ba06e3928db38fbb34e6f9e296a7d92621c5587d53076fa9c7e33fb19fc"
wget --output-document=${ROOT_PATH}/${ITEM_DETAILS_FULL} "http://data.cluster-lab.com/data-newprolab-com/project02/item_details_full?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=HI36GTQZKTLEH30CJ443%2F20181018%2F%2Fs3%2Faws4_request&X-Amz-Date=20181018T152247Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=9708f8bdf5f143d5839e4e1d4816e039a2474e799013cc966d3a541faaac7937"

split -l 500000 ${ROOT_PATH}/${ITEM_DETAILS_FULL} ${ROOT_PATH}/tmp/

rm -rf ${ROOT_PATH}/${ITEM_DETAILS_FULL}

FILES=`ls -p ${ROOT_PATH}/tmp/| grep -v /`

for file in ${FILES}
do
	sed -i 's/"attr1"/"name"/g' ${ROOT_PATH}/tmp/${file}
	sed -i 's/"attr0"/"annotation"/g' ${ROOT_PATH}/tmp/${file}
	sed -i 's/"itemid"/"id"/g' ${ROOT_PATH}/tmp/${file}
	curl -H "Content-Type: application/json" -XPOST "http://localhost:9200/books-index/book/_source" --data-binary @${ROOT_PATH}/tmp/${file}
	rm -rf ${ROOT_PATH}/tmp/${file}
done

rm -rf ${ROOT_PATH}

# show all indexes
# curl 'localhost:9200/_cat/indices?v'

# delete index
# curl -XDELETE localhost:9200/books-index/