-- cancellation rateを求める
-- Trips.Statusがcancelled_by_driver, cancelled_by_clientがあるから、そこをたどっていけば行けそう
-- 期間は'2013-10-01'~'2013-10-03'であるから、Trips.Request_atを見ればいい
-- banされてない人を出力するから、最後にUsers.Banned=Noを確かめる
-- (cancelled/all_count)で小数点第2までを出力する
-- [方針]
-- 日別のall_countとcanncelledがほしい, それぞれTripsにあるが、Usersからbanされていないかを確認する必要がある

-- これで、banされている人を除いた表を出力
select distinct T.Id, T.Client_Id, T.Driver_Id, T.City_Id, T.Status, T.Request_at, U1.Banned
from Trips T, Users U1, Users U2
where U1.Banned = 'No' and U2.Banned = 'No' and 
((U1.Role = 'client' and U1.Users_Id = T.Client_Id) and
 (U2.Role = 'driver' and U2.Users_Id = T.Driver_Id))

-- 上記の表に対して、all_count, canncelledを出力する
select 
    count(*) over(partition by Request_at) as all_count,
    count(*) over(partition by Request_at, Status order by Status) as cancelled
from(
    select distinct T.Id, T.Client_Id, T.Driver_Id, T.City_Id, T.Status, T.Request_at
    from Trips T, Users U
    where U.Banned = 'No' and 
    ((U.Role = 'client' and U.Users_Id = T.Client_Id) or
     (U.Role = 'driver' and U.Users_Id = T.Driver_Id))) as S;

-- 以下となった
select
   Request_at as 'Day', round(((all_count-not_cancelled)/all_count),2) as 'Cancellation Rate'
from(
    select 
        Request_at,
        count(*) over(partition by Request_at) as all_count,
        count(*) over(partition by Request_at, Status order by Status) as not_cancelled
    from(
        select distinct T.Id, T.Client_Id, T.Driver_Id, T.City_Id, T.Status, T.Request_at, U1.Banned
        from Trips T, Users U1, Users U2
        where U1.Banned = 'No' and U2.Banned = 'No' and 
        ((U1.Role = 'client' and U1.Users_Id = T.Client_Id) and
         (U2.Role = 'driver' and U2.Users_Id = T.Driver_Id))) as S1) as S2
group by Request_at;

-- count(*) over(partition by Request_at, Status order by Status) as not_cancelled
-- でnot_cancelledを取ってきちゃってるから、全部cancelledされていると逆転してしまう。
-- →order byで取らずに、ちゃんと条件で取得する(T.Status = 'completed'とか)

select
   Request_at as Day,
   round(((all_count-count(Request_at))/all_count),2) as 'Cancellation Rate'
from(
    select 
        Request_at,
        Status,
        count(*) over(partition by Request_at) as all_count
    from(
        select distinct T.Id, T.Client_Id, T.Driver_Id, T.City_Id, T.Status, T.Request_at, U1.Banned
        from Trips T, Users U1, Users U2
        where U1.Banned = 'No' and U2.Banned = 'No' and 
        ((U1.Role = 'client' and U1.Users_Id = T.Client_Id) and
         (U2.Role = 'driver' and U2.Users_Id = T.Driver_Id))) as S1) as S2
where Status = 'completed'
group by Request_at;

-- これでやると、where Statusのところで、completedがない時(全部キャンセル)にデータが反映,出力されない
-- where Status = 'cancelled_by_client' or Status = cancelled_by_driver'とかでやっても、逆にcompleteしかないときは出力されない

select 
    Request_at as Day,
    round((sum(tmp_cancel)/all_count),2) as 'Cancellation Rate'
from(
    select 
        Request_at,
        Status,
        count(*) over(partition by Request_at) as all_count,
        case Status 
            when 'cancelled_by_client' then 1
            when 'cancelled_by_driver' then 1
            else 0 end as tmp_cancel
    from(
        select distinct T.Id, T.Client_Id, T.Driver_Id, T.City_Id, T.Status, T.Request_at, U1.Banned
        from Trips T, Users U1, Users U2
        where U1.Banned = 'No' and U2.Banned = 'No' and 
        ((U1.Role = 'client' and U1.Users_Id = T.Client_Id) and
         (U2.Role = 'driver' and U2.Users_Id = T.Driver_Id))) as S1) as S2
group by Request_at;

-- tmp_cancelでそれぞれのcancelだったら1、completeだったら0にして、sum(tmp_cancel)でキャンセル数を取得した
-- 問題を見ると期間の条件があったのそれを追加してac

select 
    Request_at as Day,
    round((sum(tmp_cancel)/all_count),2) as 'Cancellation Rate'
from(
    select 
        Request_at,
        Status,
        count(*) over(partition by Request_at) as all_count,
        case Status 
            when 'cancelled_by_client' then 1
            when 'cancelled_by_driver' then 1
            else 0 end as tmp_cancel
    from(
        select distinct T.Id, T.Client_Id, T.Driver_Id, T.City_Id, T.Status, T.Request_at, U1.Banned
        from Trips T, Users U1, Users U2
        where U1.Banned = 'No' and U2.Banned = 'No' and 
        ((U1.Role = 'client' and U1.Users_Id = T.Client_Id) and
         (U2.Role = 'driver' and U2.Users_Id = T.Driver_Id))) as S1
    where Request_at between '2013-10-01' and '2013-10-03') as S2
group by Request_at;

-- runtime:413ms, 67.77%
-- 以下Discussから拾ってきた
-- case文をgroup byすることで、一発でsumを取ってて参考になる(これを含めた他の回答を見るとdriverがbanの検査はしてない....するとしたらもう一つtableをjoinする必要がある)

select 
t.Request_at Day, 
round(sum(case when t.Status like 'cancelled_%' then 1 else 0 end)/count(*),2) 'Cancellation Rate'
from Trips t 
inner join Users u 
on t.Client_Id = u.Users_Id and u.Banned='No'
where t.Request_at between '2013-10-01' and '2013-10-03'
group by t.Request_at