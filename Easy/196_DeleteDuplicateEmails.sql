-- 重複しているメールアドレスをdeleteする
-- group by emailしてemailを一意にし、そのidを使ってnot inする
-- delete not in すると、一意にしたid以外の行が削除され、結果的に一意にしたものしか残らない
-- not inの際にはmin(id)とすることで一意のidが得られる
delete 
from Person
where Id not in (
    select min_id from (
        select MIN(id) min_id from Person group by Email
    ) as S
);

-- 以下でもできる(速度は落ちた...)
DELETE p1
FROM Person p1, Person p2
WHERE p1.Email = p2.Email AND
p1.Id > p2.Id;