registry = instance-1.europe-west1-b.c.agile-splicer-218512.internal:5000

build:
	docker build -t divolte-unpacker .
	docker tag divolte-unpacker $(registry)/divolte-unpacker
	docker push $(registry)/divolte-unpacker
	docker image rm divolte-unpacker

run:
	docker run --name unpacker --rm -it divolte-unpacker /bin/bash

shell:
	docker exec -it unpacker /bin/bash

.PHONY:
	build
