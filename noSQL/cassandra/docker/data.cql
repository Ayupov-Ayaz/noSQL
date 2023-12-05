-- Create a keyspace
-- replication_factory = 2, потому-что количество нод в кластере = 3
-- нельзя ставить одинаковое количество либо больше, чем количество нод в кластере
CREATE KEYSPACE IF NOT EXISTS store WITH replication = {
    'class':'NetworkTopologyStrategy', 'replication_factor': 2};

-- Create a tables
CREATE TABLE IF NOT EXISTS store.products
(
    id          int,
    name        text,
    description text,
    price       double,
    PRIMARY KEY ((id, name), price)
);

CREATE TABLE IF NOT EXISTS store.orders
(
    id         int,
    product_id int,
    phone      text,
    address    text,
    date       timestamp,
    PRIMARY KEY ((id, product_id), date)
);

-- Insert data to products table
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

-- Insert data to orders table
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (1, 1, '+380521538567', 'Московская дом 2 кв 10', '2020-01-01 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (2, 8, '+380521538567', 'Московская дом 2 кв 10', '2020-01-01 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (3, 7, '+380541264567', 'Пушкина дом 3 кв 4 ', '2020-01-02 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (4, 5, '+380501234567', 'Проспект Победы дом 10 кв 2', '2020-01-03 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (5, 1, '+380501284567', 'Риххарда Зорге дом 23 кв 712', '2020-01-01 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (6, 2, '+380501234567', 'Проспект Победы дом 10 кв 2', '2020-01-02 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (7, 4, '+340501244567', 'Ершова дом 5, корп. 3, кв 23', '2020-01-04 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (8, 3, '+380501234567', 'Проспект Победы дом 10 кв 2', '2020-01-05 00:00:00');
INSERT INTO store.orders (id, product_id, phone, address, date) VALUES (9, 1, '+340501244567', 'Ершова дом 5, корп. 3, кв 23', '2020-01-06 00:00:00');

-- Select data from products table
SELECT name, price FROM store.products WHERE id = 1 and name = 'Apple';
SELECT name, price, description FROM store.products WHERE price > 5.0 ALLOW FILTERING;
SELECT * FROM store.orders WHERE date < '2020-01-02 00:00:00' ALLOW FILTERING;

-- Create second index
CREATE INDEX IF NOT EXISTS ON  store.orders (phone);
-- Select data from orders table with index
SELECT id, product_id, address  FROM store.orders WHERE phone = '+380501234567';