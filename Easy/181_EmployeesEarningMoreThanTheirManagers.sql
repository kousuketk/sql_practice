-- 同じテーブル内で比較して検索するから、同じテーブルを用意して解いた
select E1.Name as Employee from Employee E1, Employee E2
where E1.ManagerId = E2.Id and E1.Salary > E2.Salary;

