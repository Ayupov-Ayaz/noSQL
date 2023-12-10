# Homework

## 1. Создать json файл размером >= 20md 

* Так как делать такой json файл руками будет крайне неудобно, 
то я воспользуюсь утилитой jq которая устанавливается командами: 

linux: 
```bash
sudo apt-get update
sudo apt-get install jq
```

macOS: 
```bash
brew install jq
```

* Когда утилита установлена, можно сгенерировать json файл командой: 
```bash
  jq -n --argjson size "$(( 256 * 1024))" '[$size | range(0;.;1) | {"data": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."}]' > large_data.json
```

* так как файл получился на 21mb, то я его не буду коммитить в репозиторий

## Поднимем редис локально в докере
```bash
docker run --name redis-homework -p 6379:6379 -d redis
```

## Замерить скорость записи большой json структуры в redis командой SET
```bash 
    time cat ./large_data.json | docker exec -i redis-homework redis-cli -x set hw
```

вывод команды: 
```bash 
OK
cat ./large_data.json  0.00s user 0.01s system 4% cpu 0.197 total
docker exec -i redis-homework redis-cli -x set hw  0.04s user 0.04s system 27% cpu 0.262 total
```
| команда | время выполнения |
| --- |------------------|
| cat ./large_data.json | 0.197 sec |
| docker exec -i redis-homework redis-cli -x set hw | 0.262 sec |


## Замерить скорость чтения большой json структуры из redis командой GET
```bash 
    time docker exec -i redis-homework redis-cli get hw > /dev/null
```

вывод команды: 
```bash
docker exec -i redis-homework redis-cli get hw > /dev/null  0.05s user 0.03s system 39% cpu 0.195 total
```
| команда | время выполнения |
| --- |------------------|
| docker exec -i redis-homework redis-cli get hw > /dev/null | 0.195 sec |

## Замерить скорость записи большой json структуры в redis командой HSET
```bash 
    time cat ./large_data.json | docker exec -i redis-homework redis-cli -x hset hw-hset 1
```

вывод команды: 
```bash
1
cat ./large_data.json  0.00s user 0.01s system 5% cpu 0.195 total
docker exec -i redis-homework redis-cli -x hset hw-hset 1  0.04s user 0.04s system 28% cpu 0.254 total
```
| команда | время выполнения |
| --- |------------------|
| cat ./large_data.json | 0.195 sec |
| docker exec -i redis-homework redis-cli -x hset hw-hset 1 | 0.254 sec |

## Замерить скорость чтения большой json структуры из redis командой HGET
```bash 
    time docker exec -i redis-homework redis-cli hget hw-hset 1 > /dev/null
```

вывод команды: 
```bash
docker exec -i redis-homework redis-cli hget hw-hset 1 > /dev/null  0.03s user 0.03s system 21% cpu 0.273 total
```
| команда | время выполнения |
| --- |------------------|
| docker exec -i redis-homework redis-cli hget hw-hset 1 > /dev/null | 0.273 sec |

## Замерить скорость записи большой json структуры в redis командой RPUSH
```bash 
    time cat ./large_data.json | docker exec -i redis-homework redis-cli -x rpush hw-rpush
```

вывод команды: 
```bash
1
cat ./large_data.json  0.00s user 0.01s system 4% cpu 0.203 total
docker exec -i redis-homework redis-cli -x rpush hw-rpush  0.03s user 0.04s system 26% cpu 0.274 total
```
| команда | время выполнения |
| --- |------------------|
| cat ./large_data.json | 0.203 sec |
| docker exec -i redis-homework redis-cli -x rpush hw-rpush | 0.274 sec |

## Замерить скорость чтения большой json структуры из redis командой LRANGE 0 -1
```bash 
    time docker exec -i redis-homework redis-cli lrange hw-rpush 0 -1 > /dev/null
```

вывод команды: 
```bash
docker exec -i redis-homework redis-cli lrange hw-rpush 0 -1 > /dev/null  0.03s user 0.03s system 23% cpu 0.252 total
```
| команда | время выполнения |
| --- |------------------|
| docker exec -i redis-homework redis-cli lrange hw-rpush 0 -1 > /dev/null | 0.252 sec |

## Замерить скорость при выполнении операций ZADD
```bash 
    time cat ./large_data.json | docker exec -i redis-homework redis-cli -x zadd hw-zadd 1
```

вывод команды: 
```bash
1
cat ./large_data.json  0.00s user 0.01s system 2% cpu 0.348 total
docker exec -i redis-homework redis-cli -x zadd hw-zadd 1  0.03s user 0.03s system 8% cpu 0.748 total
```
| команда | время выполнения |
| --- |------------------|
| cat ./large_data.json | 0.348 sec |
| docker exec -i redis-homework redis-cli -x zadd hw-zadd 1 | 0.748 sec |

## Замерить скорость при выполнении операций ZRANGE
```bash 
    time docker exec -i redis-homework redis-cli zrange hw-zadd 0 -1 > /dev/null
```

вывод команды: 
```bash
docker exec -i redis-homework redis-cli zrange hw-zadd 0 -1 > /dev/null  0.03s user 0.02s system 25% cpu 0.225 total
```
| команда | время выполнения |
| --- |------------------|
| docker exec -i redis-homework redis-cli zrange hw-zadd 0 -1 > /dev/null | 0.225 sec |

Итог по записи:
| команда | время выполнения |
| --- |------------------|
| SET | 0.262 sec |
| HSET | 0.254 sec |
| ZADD | 0.748 sec |
| RPUSH | 0.274 sec |

Итог по чтению:
| команда | время выполнения |
| --- |------------------|
| GET | 0.195 sec |
| HGET | 0.273 sec |
| LRANGE | 0.252 sec |
| ZRANGE | 0.225 sec |
