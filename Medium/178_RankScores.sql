-- dense_rankを使うと同順があっても連番でつけてくれる, 
-- あとas Rankとかしたときは"Rank"にすると実行できる.
select Score as score, dense_rank() over(order by Score desc) as "Rank"
from Scores;