-- 5人以上の生徒が受けているクラスを出力する
-- group by classでhavingでcount()をチェックすればいい
select class
from courses
group by class
having count(*) >= 5;

-- courseテーブルが重複ありのテーブルだったらしく、最初にuniqueにする必要があった
-- 今回はgroup by student, classでuniqueにして以下の通りでac

select class
from(
    select *
    from courses
    group by student, class) as S
group by class
having count(*) >= 5;


-- 回答を見るとhaving count(distinct student) >= 5とかでできるらしい
select class
from courses
group by class
having count(distinct student)>=5;