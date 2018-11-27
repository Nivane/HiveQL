//hive有元数据和实际数据，托管表操作元数据和存储数据，外部表只操作元数据

//修改数据库位置
CREATE DATABASE financials 
LOCATION '/usr/local/hello';

//CASCADE先删除表，再删除数据库
DROP DATABASE IF EXISTS financials CASCADE;

//加载本地数据到records
// overwrite告诉Hive删除表对应目录中已有的所有文件，即清空表信息后添加后加载的数据
load data local inpath '/usr/local/sample.txt' overwrite into table records;
//加载HDFS文件
load data inpath 'hdfs://ns1/sample.txt' overwrite into table managed_table;

复杂数据类型
// array map struct
//fileds terminated by 
// collection items terminated by
// map keys terminated by
create table complex(c1 int, c2 array<int>, c3 map<string, int>, c4 struct<a:string, b:string>)
row format delimited
fields terminated by '\t'
collection items terminated by ','
map keys terminated by ':';


//外部表
// external
// location 指定数据的位置，加载的数据加载到location中，
// drop外部表时，只删除元数据，不删除表内数据
create external table external_table(year string, temperature int, quality int) 
row format delimited fields terminated by '\t' 
location '/user/zlp/external_table';

//分区
create table logs(ts bigint, line string) 
partitioned by (dt string, country string);
// 分区相当于是生成目录结构，从前往后的分区是从上到下的目录结构，便于查询
// 加载数据时要确定加载到哪一个分区，给表定义的分区赋值
1oad data local inpath '/usr/local/input/hive/partitions/file1' into table logs partition(dt='2001-01-01', country='GB');
1oad data local inpath '/usr/local/input/hive/partitions/file2' into table logs partition(dt='2001-01-01', country='GB');
1oad data local inpath '/usr/local/input/hive/partitions/file3' into table logs partition(dt='2001-01-01', country='US');
1oad data local inpath '/usr/local/input/hive/partitions/file4' into table logs partition(dt='2001-01-02', country='GB');
1oad data local inpath '/usr/local/input/hive/partitions/file5' into table logs partition(dt='2001-01-02', country='US');
1oad data local inpath '/usr/local/input/hive/partitions/file6' into table logs partition(dt='2001-01-02', country='US');
//按照分区查询
select ts, line, dt from logs
where country = 'GB';

桶和分区都起到了隔离数据和优化查询的功能
//桶
//每个桶对应一个reduce任务，共输出4个文件
//根据id对桶数的hash值(即余数)确定一个桶
//桶便于抽样和map join，分区过多会导致文件系统性能下降
set hive.enforce.bucketing=true;
create table bucketed_user(id int, name string)
clustered by (id) into 4 buckets;
//tablesample取样查询
//bucket 1 out of 4 on id 对于id的桶，查询第一个桶的数据
//查询桶目录
hive> dfs -ls	/user/hive/warehouse/bucketed_users;
//查看桶文件
hive> dfs -cat	/user/hive/warehouse/bucketed_users/000000_0;

//多表插入
from records
insert overwrite  table table1
select year, count(distinct station)
group by year
insert overwrite  table table2
select year, count(1)
group by year
insert overwrite  table table3
select year, count(1)
where quality in (0,1,2,3,4,5)
group by year;

//查询插入表数据
insert overwrite table employees
partition (country = 'US', state = 'OR')
select * from se
where se.cnty = 'US' and se.st = 'OR'; 

//查询语句创建表并加载数据
create table t 
as select name, salary
from employees
where se.state = 'CA';

//导出数据
hadoop fs -cp from to
insert overwrite local directory '/tmp'
select name, salary
from employees;



