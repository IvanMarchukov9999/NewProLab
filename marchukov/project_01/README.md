# ������ ������ ����� Spark

### ��� 1

��������� �������� ���� � hdfs �� ���� `/user/deadman2000/data.json`

```
# ������� �� ��� ������������ hdfs
sudo su hdfs
hdfs dfs -mkdir /user/deadman2000
hadoop fs -put data.json /user/deadman2000/data.json
# ���� ���� ���
exit
```

### ��� 2

������� � pyspark

```
./shell.sh
```

���������

```
spark = SparkSession.builder.master('local').appName('Data import').getOrCreate()

df = spark.read.json('data.json')

# ���� ���

df.write.format("org.elasticsearch.spark.sql") \
  .option("es.resource", "myindex/type") \
  .save()
  
# ���� ��� 2
spark.stop()
```

### ��� 3. ������

��������� ����� ����: http://35.187.111.78:9200/myindex/_settings?pretty

```json
{
  "myindex" : {
    "settings" : {
      "index" : {
        "creation_date" : "1540483784275",
        "number_of_shards" : "5",
        "number_of_replicas" : "1",
        "uuid" : "8iYfCykSS3CVWOzVMgwLNQ",
        "version" : {
          "created" : "6040299"
        },
        "provided_name" : "myindex"
      }
    }
  }
}
```

������ ����� ������
```
PUT /myindex/_settings
{ "number_of_replicas": 2 }
```

��������� ������������������
```
GET myindex/_search
{
  "size": 10,
  "timeout": "20ms", 
  "query": {
    "bool": {
      "must": {
        "multi_match": {
          "query": "����� ��� ����� 100 ��������",
          "fields": [
            "attr0",
            "attr1"
          ]
        }
      }
    }
  }
}
```

� ��������� ������� ����� ������ � ������ 1.5s, �������� �� 5 ���� � 2 �������