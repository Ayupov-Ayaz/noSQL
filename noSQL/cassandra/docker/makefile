network = cassandra-network
arch ?= arm64v8
version ?= 5.0
port ?= 9042
name ?= cassandra-test

create-network:
	docker network create $(network)

# создает контейнер с кассандрой
# и запускает его в фоновом режиме
# имеет только 1 узел
run-cassandra:
	docker run --rm -d \
	--network $(network) \
	--name $(name) \
	-e CQLSH_HOST=cassandra \
	-e CQLSH_PORT=$(port) \
	$(arch)/cassandra:$(version)

exec:
	docker run --rm -it \
	--network $(network) \
	$(arch)/cassandra:$(version) \
	cqlsh $(name)


# создает контернер с кассандрой
# и запускает его в фоновом режиме
# имеет 3 узла
run-cassandra-clusters:
	docker run --rm -d \
	--network $(network) \
	--name $(name)-1 \
	-e CASSANDRA_SEEDS="$(name)-1,$(name)-2,$(name)-3" \
	$(arch)/cassandra:$(version)

	docker run --rm -d \
	--network $(network) \
	--name $(name)-2 \
	-e CASSANDRA_SEEDS="$(name)-1,$(name)-2,$(name)-3" \
	$(arch)/cassandra:$(version)

	docker run --rm -d \
	--network $(network) \
	--name $(name)-3 \
	-e CASSANDRA_SEEDS="$(name)-1,$(name)-2,$(name)-3" \
	$(arch)/cassandra:$(version)