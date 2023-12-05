# Homework

## Развернуть docker локально или в облаке

* Первое, что нужно сделать - это создать сеть для контейнеров, чтобы они могли общаться друг с другом. Для этого выполним команду:

```bash
create-network:
	docker network create cassandra-network
```

* Теперь можно запустить контейнер с кассандрой:
    * Так как я использую M1, то использую образ для архитектуры arm64v8
    * Также я использую версию 5.0
    * По умолчанию cassandra запускается на порту 9042, поэтому пробрасываем этот порт
  
```bash
run-cassandra:
    docker run --rm -d \
    --network cassandra-network \
    --name cassandra-container-id \
    -e CQLSH_HOST=cassandra \
    -e CQLSH_PORT=9042 \
    arm64v8/cassandra:5.0
```
* Так как нам этот контейнер уже не нужен, то можно его убить командой:
```bash
docker rm -f cassandra-container-id
```

## Поднять 3 узловый Cassandra кластер

* Для этого нужно запустить 3 контейнера с кассандрой, но с разными именами и портами
* При чем каждый из контейнеров должен знать о существовании других
* Для этого нужно добавить в контейнеры переменную окружения CASSANDRA_SEEDS, 
которая будет содержать адреса других контейнеров
* Имена контейнеров будут иметь вид cassandra-1, cassandra-2, cassandra-3
* Каждое имя будет использоваться в качестве имени хоста для других контейнеров

```bash
run-cassandra-clusters:
	docker run --rm -d \
	--network cassandra-network \
	--name cassandra-1 \
	-e CASSANDRA_SEEDS="cassandra-1,cassandra-2,cassandra-3" \
	arm64v8/cassandra:5.0

	docker run --rm -d \
	--network cassandra-network \
	--name cassandra-2 \
	-e CASSANDRA_SEEDS="cassandra-1,cassandra-2,cassandra-3" \
	arm64v8/cassandra:5.0

	docker run --rm -d \
	--network cassandra-network \
	--name cassandra-3 \
	-e CASSANDRA_SEEDS="cassandra-1,cassandra-2,cassandra-3" \
	arm64v8/cassandra:5.0
```

## Создать тестовый keyspace и таблицы

* Для дальнейшей работы нужно подключиться к cassandra контейнеру. 
* Мы можем использовать абсолютно любой узел, так как данные которые мы
будем записывать будут появляться на всех узлах

```bash
exec:
	docker run --rm -it \
	--network cassandra-network \
	arm64v8/cassandra:5.0 \
	cqlsh cassandra-1
```

### Создаем keyspace
```cassandraql
CREATE KEYSPACE IF NOT EXISTS store WITH replication = {
    'class':'NetworkTopologyStrategy', 'replication_factor': 2};
```

* replication_factory = 2, потому-что количество нод в кластере = 3
* Нельзя ставить одинаковое количество либо больше, чем количество нод в кластере

### Создаем таблицу products
* Таблица для хранения данных о продуктах будет иметь:
  * составной partition key (id, name)
  * один clustering key (price)
  * одно поле не входящее в primary key (description)

```cassandraql
CREATE TABLE IF NOT EXISTS store.products
(
    id          int,
    name        text,
    description text,
    price       double,
    PRIMARY KEY ((id, name), price)
);
```

### Создаем таблицу с заказами
* Таблица для хранения данных с заказами будет иметь: 
    * составной partition key (id, product_id)
    * один clustering key (date)
    * два поля не входящих в primary key (phone, address)

```cassandraql 
CREATE TABLE IF NOT EXISTS store.orders
(
    id         int,
    product_id int,
    phone      text,
    address    text,
    date       timestamp,
    PRIMARY KEY ((id, product_id), date)
);
```

## Заполнить таблицы тестовыми данными

### Заполняем таблицу products
```cassandraql
  INSERT INTO store.products (id, name, description, price) VALUES (1, 'Apple', 'Green apple', 1.5);
  INSERT INTO store.products (id, name, description, price) VALUES (2, 'Orange', 'Orange orange', 2.5);
  INSERT INTO store.products (id, name, description, price) VALUES (3, 'Banana', 'Yellow banana', 3.5);
  INSERT INTO store.products (id, name, description, price) VALUES (4, 'Pineapple', 'Yellow pineapple', 4.5);
  INSERT INTO store.products (id, name, description, price) VALUES (5, 'Mango', 'Yellow mango', 5.5);
  INSERT INTO store.products (id, name, description, price) VALUES (6, 'Kiwi', 'Green kiwi', 6.5);
  INSERT INTO store.products (id, name, description, price) VALUES (7, 'Lemon', 'Yellow lemon', 7.5);
  INSERT INTO store.products (id, name, description, price) VALUES (8, 'Grapefruit', 'Yellow grapefruit', 8.5);
  INSERT INTO store.products (id, name, description, price) VALUES (9, 'Peach', 'Yellow peach', 9.5);
  INSERT INTO store.products (id, name, description, price) VALUES (10, 'Pear', 'Yellow pear', 10.5);
  INSERT INTO store.products (id, name, description, price) VALUES (11, 'Cherry', 'Red cherry', 11.5);
```

### Заполняем таблицу orders
```cassandraql
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (1, 1, '+380521538567', 'Московская дом 2 кв 10', '2020-01-01 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (2, 8, '+380521538567', 'Московская дом 2 кв 10', '2020-01-01 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (3, 7, '+380541264567', 'Пушкина дом 3 кв 4 ', '2019-12-31 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (4, 5, '+380501234567', 'Проспект Победы дом 10 кв 2', '2020-01-03 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (5, 1, '+380501284567', 'Риххарда Зорге дом 23 кв 712', '2020-01-01 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (6, 2, '+380501234567', 'Проспект Победы дом 10 кв 2', '2020-01-02 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (7, 4, '+340501244567', 'Ершова дом 5, корп. 3, кв 23', '2020-01-04 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (8, 3, '+380501234567', 'Проспект Победы дом 10 кв 2', '2020-01-05 00:00:00');
  INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (9, 1, '+340501244567', 'Ершова дом 5, корп. 3, кв 23', '2020-01-06 00:00:00');
```

## Выполнить 2-3 варианта запроса использую WHERE

### Получение продукта по его идентификатору и названию
```cassandraql
  SELECT name, price FROM store.products WHERE id = 1 and name = 'Apple';
```

result:

| name  | price |
|-------|-------|
| Apple | 1.5 |

### Получение всех продуктов дороже 5.0 

```cassandraql
    SELECT name, price, description FROM store.products WHERE price > 5.0 ALLOW FILTERING;
```
    
result: 

| name      | price | description    |
|-----------|-------|----------------|
| Mango     | 5.5   | Yellow mango   |
| Kiwi      | 6.5   | Green kiwi     |
| Lemon     | 7.5   | Yellow lemon   |
| Grapefruit| 8.5   | Yellow grapefruit |
| Peach     | 9.5   | Yellow peach   |
| Pear      | 10.5  | Yellow pear    |
| Cherry    | 11.5  | Red cherry     |

### Получение всех заказов до определенной даты

```cassandraql
    SELECT * FROM store.orders WHERE date < '2020-01-02 00:00:00' ALLOW FILTERING;
```

result:

| id  | product_id | address                 | date                | phone         |
|-----|------------|-------------------------|---------------------|---------------|
| 1   | 1          | Московская дом 2 кв 10  | 2020-01-01 00:00:00 | +380521538567 |
| 2   | 8          | Московская дом 2 кв 10  | 2020-01-01 00:00:00 | +380521538567 |
| 3   | 7          | Пушкина дом 3 кв 4      | 2019-12-31 00:00:00 | +380541264567 |
| 5   | 1          | Риххарда Зорге дом 23 кв 712 | 2020-01-01 00:00:00 | +380501284567 |

## Создать вторичный индекс на поле, не входящее в primiry key
```cassandraql
    CREATE INDEX IF NOT EXISTS ON  store.orders (phone);
```

проверяем, что индекс создался
```cassandraql
    SELECT id, product_id, address, prone  FROM store.orders WHERE phone = '+380501234567';
```

result:

| id  | product_id | address                 | phone         |
|-----|------------|-------------------------|---------------|
| 4   | 5          | Проспект Победы дом 10 кв 2 | +380501234567 |
| 6   | 2          | Проспект Победы дом 10 кв 2 | +380501234567 |
| 8   | 3          | Проспект Победы дом 10 кв 2 | +380501234567 |

