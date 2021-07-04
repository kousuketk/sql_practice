-- rank()で分けたけどlimit, offsetみたい
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      SELECT ifnull((
          SELECT distinct S.Salary 
          FROM(
              SELECT Salary, rank() OVER(order by Salary desc) as ranka FROM Employee
          ) AS S
          WHERE S.ranka = N
      ), NULL)
  );
END

-- 以下、limit, offsetを使用する
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    declare tmp INT;
    set tmp = N-1;
  RETURN(
    select distinct Salary from Employee order by Salary desc limit 1 offset tmp
  );
END