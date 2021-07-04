-- 今まで注文をしていないユーザーを求める問題
-- not exits, not in, left join + where is nullのどれかで解ける
select C.Name as 'Customers'
from Customers C
where not exists(select * from Orders O where C.ID = O.CustomerId);

