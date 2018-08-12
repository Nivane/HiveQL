//创建数据库
//不指定数据库则使用default
CREATE DATABASE financials;
CREATE DATABASE IF NOT EXISTS financials;
SHOW DATABASES;
//正则表达式筛选数据库
//(.*)筛选出financials
SHOW DATABASES LIKE 'f.*'
//修改数据库位置
CREATE DATABASE financials 
LOCATION '/usr/local/hello';
//数据库添加描述信息
CREATE DATABASE financials 
COMMENT 'holds all financial tables';
DESCRIBE DATABASE financials;
CREATE DATABASE financials
WITH DBPROTERTIES('creator' = 'Mark Moneybags', 'date' = '2018-08-12');
DESCRIBE DATABASE financials;
DROP DATABASE IF EXISTS financials CASCADE;//CASCADE先删除表，再删除数据库


建表
// row format delimited fields terminated by '\t'	使用tab分隔行字段
create table records(year string, temperature int, quality int) 
row format delimited fields terminated by '\t';

加载本地数据到records
// overwrite告诉Hive删除表对应目录中已有的所有文件，即清空表信息后添加后加载的数据
load data local inpath '/usr/local/sample.txt' overwrite into table records;

清空托管表中的数据
truncate table records;

描述表信息
desc records;

查询每年最大温度
select year, max(temperature) from records 
where temperature != 9999 and quality in (0,1,2,3,4,5,6,7,8,9) 
group by year;

复杂数据类型
// array map struct
// collection items terminated by
// map keys terminated by
create table complex(c1 array<int>, c2 map<string, int>, c3 struct<a:string,b:int,c:double>) 
row format delimited fields terminated by '\t' 
collection items terminated by ',' 
map keys terminated by ':';


托管表
//从hdfs加载文件
//drop table同时删除元数据和数据
create table managed_table(year string, temperature int, quality int) 
row format delimited fields terminated by '\t';
load data inpath 'hdfs://ns1/sample.txt' overwrite into table managed_table;
drop table managed_table；

外部表
// external
// location 指定数据的位置，加载的数据加载到location中，
// drop外部表时，只删除元数据，不删除表内数据
create external table external_table(year string, temperature int, quality int) 
row format delimited fields terminated by '\t' 
location '/user/zlp/external_table';
load data inpath 'hdfs://ns1/sample.txt' overwrite into table external_table;

分区
// 二进制文件不要使用row format delimited fields terminated by
// 定义表时确定按照什么分区
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
//显示logs表的所有分区
show partitions logs;
//按照分区查询
select ts, line, dt from logs
where country = 'GB';


桶
//建立桶设置
//每个桶对应一个reduce任务，共输出4个文件
//根据id对桶数的hash值(即余数)确定一个桶
set hive.enforce.bucketing=true;
create table bucketed_user(id int, name string)
clustered by (id) into 4 buckets;
//tablesample取样查询
//bucket 1 out of 4 on id 对于id的桶，查询第一个桶的数据
//查询桶目录
hive> dfs -ls	/user/hive/warehouse/bucketed_users;
//查看桶文件
hive> dfs -cat	/user/hive/warehouse/bucketed_users/000000_0;
//四个桶中的第一个桶,返回四分之一数据
select * from bucketed_users tablesample(bucket 1 out of 4 on id);

tablesample
//返回约二分之一数据
select * from bucketed_users tablesample(bucket 1 out of 2 on id);
//返回约三分之一数据
select * from bucketed_users tablesample(bucket 1 out of 3 on id);
//rand()对未划分桶的表取样
select * from users tablesample(bucket 1 out of 4 on rand())


存储格式
//默认文本存储格式
create table ...
create table ...
row format delimited
fields terminated by '\001'
collection items terminated by '\002'
map keys terminated by '\003'
lines terminated by '\n'
stored as textfile;
//二进制存储
set hive.exec.compress.output=true;
set avro.output.codec=snappy;
create table ...stored as avro;
//定制RegexSerDe,正则表达式捕获组
create table stations(usaf string, wban string, name string)
row format serde 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
with serdeproperties(
	"input.regex" = "(\\d{6})(\\d{5})(.{29}).*"
);


导入数据
//insert,有overwrite就不需要用into了
//固定分区
insert overwrite  table target
partition (dt = '2001-01-01')
select s1, s2 from source;
//动态分区dt根据select中dt插入
insert overwrite  table target
partition(dt)
select s1, s2, dt from source
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
//CTAS
create table target as select s1, s2 from source;

表的修改
//重命名
//外部表只修改元数据
//托管表修改元数据并移动存储数据的目录
alter table name1 rename to name2;
//添加列
alter table name1 add columns (s3 string);

表的丢弃
//清空表数据，该命令外部表无效，会提示cannot truncate non-managed_table
truncate table table1;
//删除表drop
drop table table1;
//创建相同格式表 like
create table table2 like table1;


