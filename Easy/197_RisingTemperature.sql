-- 前日より気温が高いidを出力する
-- rows between 1 preciding and 1 precidingでmin(temperature)をサブクエリで取得して
-- whereで比較する
select distinct S.id as Id
from(
    select 
        *,
        min(RecordDate) over(order by RecordDate rows between 1 preceding and 1 preceding) as before_date,
        min(Temperature) over(order by RecordDate rows between 1 preceding and 1 preceding) as before_temp
    from Weather) as S
where S.Temperature > S.before_temp and S.RecordDate = S.before_date+1;
-- acしなかった.....
-- 日付の比較のところを以下のようにするとacした
-- おそらく年や月をまたぐときにTO_DAYSしておかないとうまく計算ができなかったのだろう
-- Runtime:321ms, faster than 86.11%
select distinct S.id as Id
from(
    select 
        *,
        min(RecordDate) over(order by RecordDate rows between 1 preceding and 1 preceding) as before_date,
        min(Temperature) over(order by RecordDate rows between 1 preceding and 1 preceding) as before_temp
    from Weather) as S
where S.Temperature > S.before_temp and TO_DAYS(S.RecordDate)-TO_DAYS(S.before_date)=1;

-- 以下で2つのテーブルを比較すると
-- 1回目:Runtime:885ms, faster than 5.01%
-- 2回目:397ms, 72.35%
SELECT wt1.Id 
FROM Weather wt1, Weather wt2
WHERE wt1.Temperature > wt2.Temperature AND 
      TO_DAYS(wt1.recordDate)-TO_DAYS(wt2.recordDate)=1;

-- 278ms, 96.62%
SELECT w1.id AS `id` FROM Weather w1, Weather w2
WHERE w1.recordDate = DATE_ADD(w2.recordDate, INTERVAL 1 DAY) AND w1.Temperature > w2.Temperature

-- runtime, faster thanは割と運ゲー, 同じsqlでも実行時間の幅が最大500msぐらいあったから、上の3つのコードはほとんど変わらない