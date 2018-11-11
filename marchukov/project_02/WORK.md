```
/usr/hdp/3.0.1.0-187/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 -topic ivan.marchukov --from-beginning
```

```
pip install -r requirements.txt
```


Создаем пользователя:

```
sudo -u postgres psql
CREATE ROLE dataeng LOGIN PASSWORD '12345678';
CREATE DATABASE metrics OWNER dataeng;
\q
```

sudo nano /etc/postgresql/9.5/main/pg_hba.conf

local  all  ambari,mapred,dataeng md5


sudo service postgresql restart


psql -U dataeng -W metrics


CREATE TABLE users(sess VARCHAR NOT NULL, time BIGINT NOT NULL, url VARCHAR NOT NULL);