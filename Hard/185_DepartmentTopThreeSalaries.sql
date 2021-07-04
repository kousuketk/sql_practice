-- それぞれの部門ごとに給料が3位(dense_rank())の人を出力する
-- まず順位を連番で出したいからdense_rank()を使う
-- where rank_salary <= 3とかやりたいから、サブクエリにする
-- 最後にdepartmentと紐付けて出力
select D.Name 'Department', S.Name 'Employee', S.Salary
from(
    select
        *,
        dense_rank() over(partition by DepartmentId order by Salary desc) as rank_salary
    from Employee) as S, Department D
where rank_salary <= 3 and S.DepartmentId = D.Id;