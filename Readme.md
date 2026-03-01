# dbops-project
Исходный репозиторий для выполнения проекта дисциплины "DBOps"

### Установка прав для работы автотестов и миграций для созданной УЗ
```
GRANT CREATE ON SCHEMA public TO store_user;
```
### Количество сосисок, которое было продано за каждый день предыдущей недели (дата заказа и сумма всех заказанных сосисок во всех заказах за этот день)
```
SELECT o.date_created, SUM(op.quantity)
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created;
```
### Сравнение выполнения запроса до и после создания индексов
До создания индексов:
```
                                                                              QUERY PLAN                                                                               
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=188875.34..188979.59 rows=200 width=12) (actual time=23202.501..23217.129 rows=7 loops=1)
   Group Key: o.date_created
   Buffers: shared hit=15548 read=111980 dirtied=11706 written=11502, temp read=521 written=524
   ->  Gather Merge  (cost=188875.34..188975.59 rows=400 width=12) (actual time=23198.635..23217.060 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         Buffers: shared hit=15548 read=111980 dirtied=11706 written=11502, temp read=521 written=524
         ->  Partial GroupAggregate  (cost=187875.32..187929.39 rows=200 width=12) (actual time=23107.038..23127.884 rows=7 loops=3)
               Group Key: o.date_created
               Buffers: shared hit=15548 read=111980 dirtied=11706 written=11502, temp read=521 written=524
               ->  Sort  (cost=187875.32..187892.68 rows=6943 width=8) (actual time=23100.193..23113.416 rows=78536 loops=3)
                     Sort Key: o.date_created
                     Sort Method: external merge  Disk: 1352kB
                     Buffers: shared hit=15548 read=111980 dirtied=11706 written=11502, temp read=521 written=524
                     Worker 0:  Sort Method: external merge  Disk: 1456kB
                     Worker 1:  Sort Method: external merge  Disk: 1360kB
                     ->  Parallel Hash Join  (cost=71133.82..187432.31 rows=6943 width=8) (actual time=4801.298..23060.907 rows=78536 loops=3)
                           Hash Cond: (op.order_id = o.id)
                           Buffers: shared hit=15435 read=111979 dirtied=11706 written=11502
                           ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.13 rows=4166613 width=12) (actual time=7.629..17221.968 rows=3333333 loops=3)
                                 Buffers: shared hit=6534 read=57161
                           ->  Parallel Hash  (cost=71126.08..71126.08 rows=619 width=12) (actual time=4793.375..4793.376 rows=78536 loops=3)
                                 Buckets: 262144 (originally 2048)  Batches: 1 (originally 1)  Memory Usage: 15152kB
                                 Buffers: shared hit=8877 read=54818 dirtied=11706 written=11502
                                 ->  Parallel Seq Scan on orders o  (cost=0.00..71126.08 rows=619 width=12) (actual time=14.800..4741.220 rows=78536 loops=3)
                                       Filter: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Rows Removed by Filter: 3254797
                                       Buffers: shared hit=8877 read=54818 dirtied=11706 written=11502
 Planning:
   Buffers: shared hit=147 read=9 dirtied=1
 Planning Time: 24.048 ms
 JIT:
   Functions: 57
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 9.060 ms, Inlining 0.000 ms, Optimization 1.251 ms, Emission 43.272 ms, Total 53.584 ms
 Execution Time: 23252.405 ms
(36 rows)
```

После создания индексов:
```
                                                                                     QUERY PLAN                                                                                      
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize GroupAggregate  (cost=179390.25..179413.30 rows=91 width=12) (actual time=36721.836..36728.409 rows=7 loops=1)
   Group Key: o.date_created
   Buffers: shared hit=668481 read=100733 written=3415
   ->  Gather Merge  (cost=179390.25..179411.48 rows=182 width=12) (actual time=36721.823..36728.393 rows=21 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         Buffers: shared hit=668481 read=100733 written=3415
         ->  Sort  (cost=178390.22..178390.45 rows=91 width=12) (actual time=36648.650..36648.653 rows=7 loops=3)
               Sort Key: o.date_created
               Sort Method: quicksort  Memory: 25kB
               Buffers: shared hit=668481 read=100733 written=3415
               Worker 0:  Sort Method: quicksort  Memory: 25kB
               Worker 1:  Sort Method: quicksort  Memory: 25kB
               ->  Partial HashAggregate  (cost=178386.35..178387.26 rows=91 width=12) (actual time=36648.618..36648.621 rows=7 loops=3)
                     Group Key: o.date_created
                     Batches: 1  Memory Usage: 24kB
                     Buffers: shared hit=668465 read=100733 written=3415
                     Worker 0:  Batches: 1  Memory Usage: 24kB
                     Worker 1:  Batches: 1  Memory Usage: 24kB
                     ->  Nested Loop  (cost=3200.95..177900.16 rows=97239 width=8) (actual time=26.571..36624.629 rows=78536 loops=3)
                           Buffers: shared hit=668465 read=100733 written=3415
                           ->  Parallel Bitmap Heap Scan on orders o  (cost=3200.51..68840.29 rows=97239 width=12) (actual time=20.065..30746.135 rows=78536 loops=3)
                                 Recheck Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                 Heap Blocks: exact=20437
                                 Buffers: shared hit=3 read=62360 written=2112
                                 ->  Bitmap Index Scan on orders_status_date_created_idx  (cost=0.00..3142.17 rows=233373 width=0) (actual time=43.861..43.861 rows=235609 loops=1)
                                       Index Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                       Buffers: shared hit=3 read=205
                           ->  Index Only Scan using order_product_order_id_idx on order_product op  (cost=0.43..1.11 rows=1 width=12) (actual time=0.074..0.074 rows=1 loops=235609)
                                 Index Cond: (order_id = o.id)
                                 Heap Fetches: 0
                                 Buffers: shared hit=668462 read=38373 written=1303
 Planning:
   Buffers: shared hit=95 read=10
 Planning Time: 54.582 ms
 JIT:
   Functions: 36
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 2.822 ms, Inlining 0.000 ms, Optimization 1.264 ms, Emission 27.142 ms, Total 31.228 ms
 Execution Time: 36730.656 ms
```

Хотя общее время выполнения запроса после добавления индексов увеличилось, эффективность использования ресурсов существенно выросла. При запросе использовалась quicksort в оперативной памяти, вместо external merge:
без индексов: ```Sort Method: external merge  Disk: 1352kB```
с индексами: ```Sort Method: quicksort  Memory: 25kB```

А также увеличилось время самой операции сортировки:
без индексов: ```actual time=4801.298..23060.907```
с индексами: ```actual time=26.571..36624.629```

Из чего следует что индексы справились со своей задачей.
