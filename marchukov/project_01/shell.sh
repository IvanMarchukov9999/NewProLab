#!/bin/bash
PYSPARK_PYTHON=python3.5 pyspark \
    --conf spark.sql.execution.arrow.enabled=true \
    --conf spark.es.nodes=127.0.0.1 \
    --conf spark.es.port=9200 \
    --conf spark.es.nodes.wan.only=true \
    --packages org.elasticsearch:elasticsearch-spark-20_2.11:6.4.2 \
    --master local[*]
