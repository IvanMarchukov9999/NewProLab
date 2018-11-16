Для решения лабы я решил использовать Ansible и Kubernetes. Процесс разворачивания описан в соответствующих документах.

Пример как развернуть MySQL: https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/

Разворачиваем в Kubernetes clickhouse-deployment.yaml


echo -ne "1, 'some text', '2016-08-14 00:00:00'\n2, 'some more text', '2016-08-14 00:00:01'" | clickhouse-client --database=test --query="INSERT INTO test FORMAT CSV" --host 10.111.128.254;


docker build -t divolte-unpacker .

docker run --rm -it divolte-unpacker



Заходим с помощью дашборда K8s на сервер Clickhouse (заходим в под -> кнопка EXEC справа наверху)

В консоли выполняем:
```
clickhouse client -m

DROP TABLE event;

CREATE TABLE event (
    timestamp UInt64,
    sessionId String,
    location String,
	price Nullable(Float32)
) ENGINE = TinyLog;
```