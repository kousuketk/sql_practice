-- 部門ごとに一番給料の高い人を出力する(重複も認めるからrank()を使用した)
-- まず、給料の高さに同順も出力することからrank()=1の人を出力するようにした
-- →そのためにはrank()をサブクエリにしてwhereでrank()=1にする必要がある
-- 最後にDepartmentと紐付けて出力する
select D.Name 'Department', S.Name 'Employee', S.Salary
from (
    select 
        *,
        rank() over(partition by departmentId order by Salary desc) as rank_salary
    from Employee) as S, Department as D
where rank_salary = 1 and S.DepartmentId = D.Id;