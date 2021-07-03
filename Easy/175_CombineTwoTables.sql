--  内部結合(inner join普通のjoin)かと思ったら、left outer joinを使わないといけなかった....
select
  Person.FirstName,
  Person.LastName,
  Address.City,
  Address.State
from
  Person
  left outer join Address on Person.PersonId = Address.PersonId;