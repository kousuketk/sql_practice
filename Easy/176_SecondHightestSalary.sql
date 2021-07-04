-- 二番目に給料が高い人を出力
-- → rank()関数でorder by salary
select
  S.salary as SecondHighestSalary
from
  (
    select
      Id,
      Salary,
      rank() over(
        order by
          Salary
      ) as salary_rank
    from
      Employee
  ) as S
where
  S.salary_rank = 2;

-- limit, offset使ってよかったらしくてこっちにした
select
  distinct Salary as SecondHighestSalary
from
  Employee
order by
  Salary desc
limit
  1 offset 1;

-- 2位がいない時nullにならなかった
-- →サブクエリにしてnull検知(このときはdistinctが必須)
select
  (
    select
      distinct Salary
    from
      Employee
    order by
      Salary desc
    limit
      1 offset 1
  ) AS SecondHighestSalary;

-- or 
select
  ifnull(
    (
      select
        distinct Salary
      from
        Employee
      order by
        Salary desc
      limit
        1 offset 1
    ),
    NULL
  ) AS SecondHighestSalary;

-- 最後にrank()をサブクエリでifnull
select
  ifnull(
    (
      select
        S.salary
      from
        (
          select
            Id,
            Salary,
            rank() over(
              order by
                Salary desc
            ) as salary_rank
          from
            Employee
        ) as S
      where
        S.salary_rank = 2
    ),
    NULL
  ) as SecondHighestSalary;