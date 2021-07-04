-- Stadiumの連続する3つ以上idで、全て100以上の列を返す.
-- 4つあったら4つ返すし、idが連続してれば日付は連続してなくても良い
select 
    id, visit_date, people
from(
    select
        *,
        case 
            when (min(people) over(rows between 2 preceding and current row)) >= 100 then 1
            when (min(people) over(rows between 1 preceding and 1 following)) >= 100 then 1
            when (min(people) over(rows between current row and 2 following)) >= 100 then 1
            else null
        end as flag
    from Stadium) as S
where flag = 1;

-- 上のような感じにすると、最後の2行でバグが出る(最初の2行でもバグが出そう)
-- 最後から2行目は上２つの条件、最後の行は上から1つの条件のみ

-- 以下で、people_counts(行数)を取得したテーブルがあるから、それを元に上の条件に組み込めばいい
select
    id, visit_date, people, people_counts
from(
    select
        id, visit_date, people,
        people_counts
    from(
        Stadium,
        (select count(*) as people_counts
        from Stadium) as S1)) S2;


-- 以下、case文でゴリ押してac(実行速度も速めだった)
-- 最後の行の判定とかは今後も使いそう.(最初にサブクエリでcount列を作っておく)
select
    id, visit_date, people
from(
    select
        *,
        case
            when id=people_counts and ((min(people) over(rows between 2 preceding and current row)) >= 100) then 1
            when id=(people_counts-1) and (((min(people) over(rows between 2 preceding and current row)) >= 100) 
                or (min(people) over(rows between 1 preceding and 1 following)) >= 100) then 1 
            when id<people_counts-1 and ((min(people) over(rows between 2 preceding and current row)) >= 100
                or (min(people) over(rows between 1 preceding and 1 following)) >= 100
                or (min(people) over(rows between current row and 2 following)) >= 100) then 1
            else null
        end as flag
    from(
        select
            id, visit_date, people, people_counts
        from(
            select
                id, visit_date, people,
                people_counts
            from(
                Stadium,
                (select count(*) as people_counts
                from Stadium) as S1)) as S2) as S3) as S4
where flag = 1;
