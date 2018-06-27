排序和聚集
//order by 全排序
//sort by 为每个reducer产生一个排序文件
//distribute by 控制特定行到哪一个reducer
//asc从小到大 desc从大到小
from records 
select year, temperature
distribute by year
sort by year asc, temperature desc;

//执行python脚本
add file /is_good_quality.py
from records 
select transform(year, temperature, quality)
using 'is_good_quality.py'
as year, temperature;

table1
Joe		2
Hank	4
Ali		0
Eve		3
Hank	2

table2
2		Tie
4		Coat
3		Hat
1		Scarf
//连接
//内连接
//Hive连接只能使用=号
//可以使用多个join...on...顺序很重要，将最大的表放在后面
//explain 可以输出执行计划的详细信息
explain
select table1.*, table2.*
from sales join things on (table.id = table2.id);
result:
Joe		2	2	Tie
Hank	4	4	Coat
Eve		3	3	Hat
Hank	2	2	Tie

//外连接
//左外连接
//右外连接
//全外连接
SELECT table1.*,table2.*
from table1 left outer join things on (table1.id = table2.id);
Joe		2	2		Tie
Hank	4	4		Coat
Ali		0	null	null
Eve		3	3		Hat
Hank	2	2		Tie
//可以看出将右表逐项与左表每项对比,左表没有对应项则左表为Null
//Tie : Joe->Hank->Ali->Eve->Hank
//Coat: Joe->Hank->Ali->Eve->Hank...
SELECT table1.*,table2.*
from table1 right outer join things on (table1.id = table2.id);
Joe		2	2		Tie
Hank	2	2		Tie
Hank	4	4		Coat
Eve		3	3		Hat
null  null	1		Scarf
//全外连接
SELECT table1.*,table2.*
from table1 full outer join things on (table1.id = table2.id);
Ali		0	null	null
null  null	1		Scarf
Joe		2	2		Tie
Hank	4	4		Coat
Eve		3	3		Hat
Hank	2	2		Tie
//半连接
select table1.* from table1 left semi join table2 on(table1.id = table2.id);
=
select table1.* from table1 where table1.id in(select id from table2);
//map连接 小的连接表放入mapper的内存执行连接
set hive.optimize.bucketmapjoin=true;


子查询
select station, year, avg(max_temperature)
from(
select station, year, max(temperature) as max_temperature
from records2
where temperature != 9999
group by station, year
) mt
group by station, year;


视图
//view中字段不需要再指定类型
create view max_temperatures (station, year, max_temperature)
as
select station year, max(temperature) from valid_records
group by station, year;

