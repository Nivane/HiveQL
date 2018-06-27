UDF
写一个UDF
1)继承org.apache.hadoop.hive.ql.exec.UDF
2)实现至少一个evaluate()
//jar在Hive本地化
//jar添加到类路径
//集群使用hdfs://ns1/jars/hive-strip
create function strip as 'thisisnobody.udf.Strip' using jar 'hdfs://ns1/jars/hive-strip.jar'
select strip(' hello ') from logs;
'hello'
select strip('abababab', 'ab') from logs;
''
select strip('bacdab', 'ab') from logs;
'cd'

//删除UDF
drop function strip;

//临时UDF，当前会话之后失效
//没有持久化存储在metastore中
add jar 'hdfs://ns1/jars/hive-strip.jar'
create temporary function strip as 'thisisnobody.udf.Strip'


