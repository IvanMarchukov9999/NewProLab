FROM yandex/clickhouse-client:latest

RUN apt-get update && \
    apt-get install python3 python3-pip -yq
	
ADD requirements.txt /tmp/

RUN pip3 install -r /tmp/requirements.txt

ADD . /etc/divolte-unpack

WORKDIR /etc/divolte-unpack
	
ENTRYPOINT python3 unpack.py > clickhouse-client -n --query="INSERT INTO event FORMAT JSONEachRow" --host 10.111.128.254