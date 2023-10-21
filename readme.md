# noSQL

> Теорема CAP (Consistency, Availability, Partition tolerance)
> описывает основные аспекты распределенных систем и говорит
> о том, что невозможно обеспечить одновременно все три свойства
> * Согласованность (Consistency)
> * Доступность (Availability)
> * Устойчивость к разделению (Partition tolerance)

## Согласованность (Consistency)
Все усзлы в системе видят одни и те же данные одновременно. При записи данных в систему, 
данные становятся доступны для чтения во всех узлах системы одновременно.

## Доступность (Availability)
Система всегда готова отвечать на запросы клиентов, даже если это означает, 
что клиент получит не самые актуальные данные.

## Устойчивость к разделению (Partition tolerance)
Система продолжает функционировать даже при возникновении сетевых разрывов между узлами. 
Разделение означает, что узлы системы не могут обмениваться сообщениями друг с другом. 

## noSQL базы данных
* [mongoDB](./mongo-db/mongo-db.md)
* [cassandra](./cassandra/cassandra.md)