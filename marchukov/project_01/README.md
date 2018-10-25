# Импорт данных через Spark

### Шаг 1

Поместить исходный файл в hdfs по пути `/user/deadman2000/data.json`

```
# Заходим из под пользователя hdfs
sudo su hdfs
hdfs dfs -mkdir /user/deadman2000
hadoop fs -put data.json /user/deadman2000/data.json
# Идем пить чай
exit
```

### Шаг 2

Заходим в pyspark

```
./shell.sh
```

Выполняем

```
spark = SparkSession.builder.master('local').appName('Data import').getOrCreate()

df = spark.read.json('data.json')

# Пьем чай

df.write.format("org.elasticsearch.spark.sql") \
  .option("es.resource", "myindex/type") \
  .save()
  
# Пьем чай 2
spark.stop()
```

### Шаг 3. Тюнинг

Проверяем число шард: http://35.187.111.78:9200/myindex/_settings?pretty

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

Задаем число реплик
```
PUT /myindex/_settings
{ "number_of_replicas": 2 }
```

Проверяем производительность
```
GET myindex/_search
{
  "size": 10,
  "timeout": "20ms", 
  "query": {
    "bool": {
      "must": {
        "multi_match": {
          "query": "книги для детей 100 способов",
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

К сожалению среднее время ответа в районе 1.5s, несмотря на 5 шард и 2 реплики