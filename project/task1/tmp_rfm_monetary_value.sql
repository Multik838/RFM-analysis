CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

insert into analysis.tmp_rfm_monetary_value 
select
user_id, monetary_value
from analysis.monetary_value;