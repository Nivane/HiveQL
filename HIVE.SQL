 窗口函数
	排名的rank() dense_rank() row_number()
	取值的first_value() last_value() lead() lag()
	http://lxw1234.com/archives/2015/04/190.htm 关于lag()向上第n行和lead()向下第n行;关于first_value(url)和last_value(url) 
	分析函数Ntile,将分区数据平均分片，如果分5片，则分别为1，2，3，4，5
	count(*)/sum(*) over (partition by ... order by ...)
	select user_id, user_name, sum(sales) over (partition by user_id), rank() over (partition by user_id order by sales desc) 
	from users
	//窗口函数后面不要添加group by
	
 hive行列转换
	行转列-多行转一行，使用concat_ws(',', collect_set(columnname))，去重使用collect_set，不去重使用collect_list
	select cityname, concat_ws(',',collect_set(regionname)) as address_set 
	from cityInfo 
	group by cityname;
	列转行-一行转多行，使用lateral view explode(split(column_set, ','))
	select cityname, region 
	from cityInfoSet 
	lateral view explode(split(address_set, ',')) aa as region;

 hive分组取前几条数据
	用户最喜欢购买的前三个product, 使用排序和row_number()，筛选出row_number()小于4的记录
	rank 12335 dense_rank 12334 row_number 12345
	select user_id,collect_list(product_id) as collect_list
	FROM//对计数进行排序，使用row_number给记录做标记，where条件筛选出前三个商品id，使用collect_List实现列转行
	  (select user_id,
			  product_id,
			  row_number() over(partition BY user_id
								ORDER BY top_cnt DESC) AS row_num
	   FROM//对用户购买记录对应商品计数
		 (select ord.user_id AS user_id,
				 pri.product_id AS product_id,
				 count(1) over(partition BY user_id,product_id) AS top_cnt
		  FROM orders ord
		  JOIN priors pri ON ord.order_id=pri.order_id) new_t) new_t2
	WHERE row_num<4 
	group by user_id //按照用户id做groupby
	LIMIT 10;

 排序 
	order by 全排序; sort by 为每个reducer产生一个排序文件; distribute by 控制特定行到哪一个reducer; cluster by 在distribute by基础上做sort by
	from records 
	select year, temperature
	distribute by year
	sort by year asc, temperature desc;
	
	
  加载本地数据到HIVE
  load data local inpath '/usr/tmp/data' overwrite into table user;
  加载数据到HIVE
  load data inpath 'hdfs://ns1/data' overwrite into table user;
  将HIVE数据导到本地
  insert overwrite local directory '/usr/tmp/data' //不可以用insert into
  select * from user;
  将HIVE数据导出HDFS
  insert overwrite directory 'hdfs://ns1/data'
  select * from user;
  或者可以使用hive -e hive -f并通过数据重定向
	
 执行python脚本
	add file /is_good_quality.py
	from records 
	select transform(year, temperature, quality)
	using 'is_good_quality.py'
	as year, temperature;
	
 半连接
	select table1.* from table1 left semi join table2 on(table1.id = table2.id);
	=
	select table1.* from table1 where table1.id in(select id from table2);
	
