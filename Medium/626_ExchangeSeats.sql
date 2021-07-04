-- idが奇数のときは1つ後の行を出力, idが偶数のときは1つ前の行を出力
select
    *,
    case id%2
        when 1 then (min(student) over(rows between 1 following and 1 following))
        when 0 then (min(student) over(rows between 1 preceding and 1 preceding))
        else null
    end as aaa
from seat;
-- こうすると、最後の行が奇数のときに1 followingがnullとなり、そのままnullが表示されてしまう

-- 最後の行を判定するために、サブクエリでcount(*)を取ってac(模範解答や他の回答も同じことしてる)
select
    id,
    case
        when (id%2=1 and id=(select count(*) from seat)) then student
        when id%2=1 then (min(student) over(rows between 1 following and 1 following))
        when id%2=0 then (min(student) over(rows between 1 preceding and 1 preceding))
        else null
    end as 'student'
from seat;

-- これもあり
SELECT
    (CASE
        WHEN MOD(id, 2) != 0 AND counts != id THEN id + 1
        WHEN MOD(id, 2) != 0 AND counts = id THEN id
        ELSE id - 1
    END) AS id,
    student
FROM
    seat,
    (SELECT
        COUNT(*) AS counts
    FROM
        seat) AS seat_counts
ORDER BY id ASC;
