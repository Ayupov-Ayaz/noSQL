# Practice 

## Create a keyspace

```sql
CREATE KEYSPACE  IF NOT EXISTS my_keyspace
WITH REPLICATION = {
    'class' : 'NetworkTopologyStrategy',
    'replication_factor' : '4'
};
```

## Get keyspace or table description

```sql
DESCRIBE KEYSPACE my_keyspace;
DESCRIBE TABLE my_keyspace.my_table;
``` 

## Connect to keyspace

```sql 
USE my_keyspace;
```

## Create a table

```sql
CREATE TABLE IF NOT EXISTS my_keyspace.my_table (
    id timeuuid,
    name text,
    date timestamp,
    PRIMARY KEY (id)
);
```


## Insert data

```sql
INSERT INTO my_keyspace.my_table (id, name, date) 
VALUES (now(), 'name', toTimestamp(now())) IF NOT EXISTS;
```

## Select data

```sql
SELECT * FROM my_keyspace.my_table WHERE CASE WHEN id = now() THEN true ELSE false END;
```

## Update data

```sql
UPDATE my_keyspace.my_table SET name = 'new_name' WHERE id = now() IF EXISTS;
```



