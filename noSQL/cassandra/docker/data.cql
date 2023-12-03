-- Create a keyspace
-- replication_factory = 2, потому-что количество нод в кластере = 3
-- нельзя ставить одинаковое количество либо больше, чем количество нод в кластере
CREATE KEYSPACE IF NOT EXISTS store WITH replication = {
    'class':'NetworkTopologyStrategy', 'replication_factor': 2};

-- Create a tables
CREATE TABLE IF NOT EXISTS store.products (
  id timeuuid,
  name text,
  description text,
  price double,
  PRIMARY KEY ((id,name), price)
);

CREATE TABLE IF NOT EXISTS store.orders (
  id timeuuid,
  product_id timeuuid,
  phone text,
  address text,
  date timestamp,
  PRIMARY KEY ((id, product_id), date)
);