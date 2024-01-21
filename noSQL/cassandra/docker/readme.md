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
	-v ./data-cassandra-1:/var/lib/cassandra/data \
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
    SELECT id, product_id, address, phone  FROM store.orders WHERE phone = '+380501234567';
```

result:

| id  | product_id | address                 | phone         |
|-----|------------|-------------------------|---------------|
| 4   | 5          | Проспект Победы дом 10 кв 2 | +380501234567 |
| 6   | 2          | Проспект Победы дом 10 кв 2 | +380501234567 |
| 8   | 3          | Проспект Победы дом 10 кв 2 | +380501234567 |


# Создание snapshots

> Для ручного управления snapshot-ами используется nodetool
> nodetool - это инструмент командной строки, который позволяет управлять кластером Cassandra.
> Чтобы создать ручные snapshot-ы, нужно установить параметр 
> auto_snapshot в значение false в файле cassandra.yaml.

* Создать snapshot всех данных в keyspace store

```bash
    docker exec -it cassandra-1 nodetool snapshot -t store
```

* чтобы посмотреть список снапшотов

```bash
    docker exec -it cassandra-1 nodetool listsnapshots;
```

* чтобы удалить все снапшоты

```bash
    docker exec -it cassandra-1 nodetool clearsnapshot --all
```

* чтобы удалить конкретный снапшот

```bash
    docker exec -it cassandra-1 nodetool clearsnapshot -t store
```

* Cоздать snapshot определенной таблицы в keyspace store

```bash
    docker exec -it cassandra-1 nodetool snapshot -t store.orders
```

* Удаление всех данных

```cassandraql
    DROP KEYSPACE store;
```

## Backup

> Для создание инкрементных backup-ов нужно установить incremental_backups 
> в значение true в файле cassandra.yaml.

> Это единственная настройка, необходимая для создания инкрементных 
> резервных копий. По умолчанию настройка incremental_backups установлена на false, 
> потому что для каждого сброса данных создается новый набор файлов SSTable,
> и если необходимо запустить несколько инструкций CQL, 
> каталог резервных копий может быстро заполниться и использовать хранилище, 
> необходимое для хранения данных таблицы. Инкрементное резервное копирование 
> также может быть включено в командной строке с помощью команды nodetool nodetool enablebackup.
> Инкрементное резервное копирование может быть отключено с помощью команды nodetool disablebackup.
> Статус инкрементных резервных копий, включены ли они, можно проверить с помощью nodetool statusbackup
[источник](https://cassandra.apache.org/doc/stable/cassandra/operating/backups.html)

# Restore

В качестве примера мы попробуем восстановить все удаленные данные из snapshot-а
Раннее, как можно заметить контейнер cassandra-1 имеет volume, который проброшен
в папку data-cassandra-1. В этой папке хранятся все данные, которые были записаны
в cassandra-1. Поэтому, чтобы восстановить данные, нужно просто скопировать
все данные из snapshot-а в папку с keyspace store.

Для начала давайте посмотрим список наших файлов в data-cassandra-1: 
    
```bash
    tree ./data-cassandra-1/store
```

вывод: 

```
./data-cassandra-1/store </br>
├── orders-f897bcb0aca111eea2714d9710d14fc9 </br>
│   ├── backups </br>
│   ├── nc-1-big-CompressionInfo.db </br>
│   ├── nc-1-big-Data.db </br>
│   ├── nc-1-big-Digest.crc32 </br>
│   ├── nc-1-big-Filter.db </br>
│   ├── nc-1-big-Index.db </br>
│   ├── nc-1-big-Statistics.db </br>
│   ├── nc-1-big-Summary.db </br>
│   └── nc-1-big-TOC.txt </br>
└── products-f4ff2ca0aca111eea2714d9710d14fc9 </br>
│   ├── backups </br>
│   ├── nc-1-big-CompressionInfo.db </br>
│   ├── nc-1-big-Data.db </br>
│   ├── nc-1-big-Digest.crc32 </br>
│   ├── nc-1-big-Filter.db </br>
│   ├── nc-1-big-Index.db </br>
│   ├── nc-1-big-Statistics.db </br>
│   ├── nc-1-big-Summary.db </br>
│   └── nc-1-big-TOC.txt </br>
```

все эти файлы были созданы cassandra-1, когда мы записывали данные в таблицы.
Если вызвать команду 

```bash
  docker exec -it cassandra-1 nodetool snapshot -t store
```

вывод программы будет следующим:

```
  Requested creating snapshot(s) for [all keyspaces] with snapshot name [store] and options {skipFlush=false}
  Snapshot directory: store
```

После этой команды в нашей дирректории с файлами появится папка snapshots
в которой будут храниться все снапшоты. В нашем случае это папка store.

вот так выглядит snapshot таблицы products:

```bash
  tree ./data-cassandra-1/store/products-f4ff2ca0aca111eea2714d9710d14fc9/snapshots/store
```

вывод:

```
./data-cassandra-1/store/products-f4ff2ca0aca111eea2714d9710d14fc9/snapshots/store
├── manifest.json
├── nc-1-big-CompressionInfo.db
├── nc-1-big-Data.db
├── nc-1-big-Digest.crc32
├── nc-1-big-Filter.db
├── nc-1-big-Index.db
├── nc-1-big-Statistics.db
├── nc-1-big-Summary.db
├── nc-1-big-TOC.txt
└── schema.cql
```

давайте теперь удалим все данные из таблицы products

```cassandraql
  TRUNCATE store.products;
```

проверяем, что данные удалились

```cassandraql
  SELECT * FROM store.products;
```

вывод:

```
  id | name | description | price
  ----+------+-------------+-------
  (0 rows)
```

теперь давайте скопируем все данные из snapshot-а в папку с таблицей products

```bash
  cp -r ./data-cassandra-1/store/products-f4ff2ca0aca111eea2714d9710d14fc9/snapshots/store/* ./data-cassandra-1/store/products-f4ff2ca0aca111eea2714d9710d14fc9/
```

затем, чтобы cassandra подхватила изменения, нужно выполнить refresh

```bash
    docker exec -it cassandra-1 nodetool refresh store products
```

теперь давайте проверим, что данные восстановились

```cassandraql
  SELECT * FROM store.products;
```

вывод программы: 

| id | name  |  price | description |
|----|-------|--------|-------------|
| 4  |  Pineapple |   4.5 |  Yellow pineapple
| 11 |     Cherry |  11.5 |        Red cherry
| 3  |     Banana |   3.5 |     Yellow banana
| 1  |      Apple |   1.5 |       Green apple
| 10 |       Pear |  10.5 |       Yellow pear
| 7  |      Lemon |   7.5 |      Yellow lemon
| 9  |      Peach |   9.5 |      Yellow peach
| 6  |       Kiwi |   6.5 |        Green kiwi
| 2  |     Orange |   2.5 |     Orange orange
| 8  | Grapefruit |   8.5 | Yellow grapefruit
| 5  |      Mango |   5.5 |      Yellow mango

Подводные камни:
1) Важно понимать, что это процесс возвращения данных к моменту создания snapshot-а.
   Если вам нужно восстановить данные к определенному моменту времени, то нужно
   создать snapshot в этот момент времени, что довольно таки сложно. 
2) Перед тем как делать restore, нужно убедиться, что схема таблиц в snapshot-e и в cassandra
   совпадают. Иначе, при restore, cassandra выдаст ошибку.
3) Такой подход выглядит не очень безопасным, так как мы просто копируем данные из одной папки в другую.