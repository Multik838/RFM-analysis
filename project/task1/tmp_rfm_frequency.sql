CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);


insert into analysis.tmp_rfm_frequency
select 
user_id,
frequency
from analysis.frequency_table;