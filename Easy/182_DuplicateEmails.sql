-- 同じテーブルの同じ重複するものを選ぶから、同じテーブルを見て同じものを出力するだけdistinct
select distinct P1.Email
from Person P1, Person P2
where P1.Email = P2.Email and P1.Id != P2.Id;


-- 答えみたら天才がいた
-- こういうやり方もあるみたい, 保守性は微妙だけど
select Email
from Person
group by Email
having count(*) > 1