-- case文を使ってupdate
update Salary
set
    sex = case sex
            when 'm' then 'f'
            when 'f' then 'm'
            else null
            end;