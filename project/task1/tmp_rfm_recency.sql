CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);


insert into analysis.tmp_rfm_recency
select 
user_id,
recency
from analysis.recency_table;

