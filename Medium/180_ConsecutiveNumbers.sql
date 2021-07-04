-- max(Num) over(rows between A and B) を使って、それぞれ3個前までの値を出力し(サブクエリ)
-- whereで3つ同じものをdistinctで出力している
-- →サブクエリを使わないで書けそう
select distinct Num as 'ConsecutiveNums' from
    (select Id,
        max(Num) over(rows between 1 preceding and 1 preceding) as var,
        max(Num) over(rows between 2 preceding and 2 preceding) as var2,
        Num
    from Logs) as S
where S.var = S.var2 and S.var = S.Num;

-- {"headers": ["EXPLAIN"], "values": [["-> Table scan on <temporary>  (actual time=0.000..0.000 rows=1 loops=1)\n    
-- -> Temporary table with deduplication  (actual time=0.086..0.086 rows=1 loops=1)\n        
-- -> Filter: ((s.var2 = s.var) and (s.var = s.Num))  (actual time=0.068..0.069 rows=1 loops=1)\n            
-- -> Table scan on S  (actual time=0.000..0.001 rows=7 loops=1)\n                
-- -> Materialize  (actual time=0.066..0.067 rows=7 loops=1)\n                    
-- -> Window multi-pass aggregate with buffering: max(`logs`.Num) OVER (ROWS BETWEEN 2 PRECEDING AND 2 PRECEDING)   (actual time=0.049..0.059 rows=7 loops=1)\n                        
-- -> Table scan on <temporary>  (actual time=0.000..0.001 rows=7 loops=1)\n                            
-- -> Temporary table  (actual time=0.044..0.045 rows=7 loops=1)\n                                
-- -> Window multi-pass aggregate with buffering: max(`logs`.Num) OVER (ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING)   (actual time=0.021..0.038 rows=7 loops=1)\...


-- 速い
-- whereのみで検索かけてるから速いんだと思う
Select DISTINCT l1.Num as 'ConsecutiveNums' from Logs l1, Logs l2, Logs l3 
where l1.Id=l2.Id-1 and l2.Id=l3.Id-1 
and l1.Num=l2.Num and l2.Num=l3.Num;

-- {"headers": ["EXPLAIN"], "values": [["-> Table scan on <temporary>  (actual time=0.000..0.001 rows=1 loops=1)\n    
-- -> Temporary table with deduplication  (actual time=0.080..0.080 rows=1 loops=1)\n        
-- -> Inner hash join (l3.Num = l1.Num), (l2.Id = (l3.Id - 1))  (cost=11.25 rows=7) (actual time=0.042..0.045 rows=1 loops=1)\n            
-- -> Table scan on l3  (cost=0.05 rows=7) (actual time=0.002..0.004 rows=7 loops=1)\n            
-- -> Hash\n                
-- -> Inner hash join (l2.Num = l1.Num), (l1.Id = (l2.Id - 1))  (cost=6.10 rows=7) (actual time=0.029..0.033 rows=3 loops=1)\n                    
-- -> Table scan on l2  (cost=0.05 rows=7) (actual time=0.003..0.006 rows=7 loops=1)\n                   
--  -> Hash\n                        
--  -> Table scan on l1  (cost=0.95 rows=7) (actual time=0.009..0.013 rows=7 loops=1)\n"]]}