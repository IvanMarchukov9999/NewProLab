Для решения лабы я решил использовать Ansible и Kubernetes. Процесс разворачивания описан в соответствующих документах.

Пример как развернуть MySQL: https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/

### Docker Registry

Для того, чтобы подготавливать образы и разворачивать их в кластере Kubernetes нужен реестр.

Запускаем в контейнере:

```
docker run -d -p 5000:5000 --restart always --name registry registry:latest

# Выполняем из под sudo
# Создаем конфиг для докера для доступа к реестру без SSL
echo '{"insecure-registries" : ["instance-1.europe-west1-b.c.agile-splicer-218512.internal:5000"]}' > /etc/docker/daemon.json

# Тиражируем конфиг на ноды
ansible-playbook daemon-copy.yaml
```

[Тут](https://medium.com/@jmarhee/in-cluster-docker-registry-with-tls-on-kubernetes-758eecfe8254) инфа, как развернуть Registry в K8s с SSL сертификатами, но на моей практике возня с SSL лишняя, т.к. нужны подписанные сертификаты, а с ними заморочки...

### Clickhouse

Разворачиваем в Kubernetes `clickhouse-deployment.yaml` с помощью Dashboard

В папке `divolte-unpacker` собираем распаковщик avro:

```
make
```

Проверить, что образ залился в Registry можно запросом `http://35.187.111.78:5000/v2/_catalog`

Заходим в шелл clickhouse:

```
kubectl exec -it clickhouse-d56f44759-lttb4 /bin/bash
```

В консоли выполняем:

```
clickhouse client -m

CREATE TABLE event (
    timestamp UInt64,
    sessionId String,
    location String,
	price Nullable(Float32)
) ENGINE= Kafka('35.187.111.78:6667', 'json_events', 'ch-group', 'JSONEachRow');


CREATE TABLE log (
    timestamp UInt64,
    sessionId String,
    location String,
	price Nullable(Float32)
) ENGINE = TinyLog();

CREATE MATERIALIZED VIEW consumer TO log
	AS SELECT * FROM event;

SELECT * FROM log;
```


### TODO

* Flask для сбора метрик

* Конфигурация Prometheus

* Grafana