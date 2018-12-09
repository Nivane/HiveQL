 hive行列转换
	1.1 行转列-多行转一行，使用concat_ws(',', collect_set(columnname))，去重使用collect_set，不去重使用collect_list
	select cityname, concat_ws(',',collect_set(regionname)) as address_set 
	from cityInfo 
	group by cityname;
	1.2 列转行-一行转多行，使用lateral view explode(split(column_set, ','))
	select cityname, region 
	from cityInfoSet 
	lateral view explode(split(address_set, ',')) aa as region;

 hive分组取前几条数据
	2.1 用户最喜欢购买的前三个product, 使用排序和row_number()，筛选出row_number()小于4的记录
	2.2 rank 12335 dense_rank 12334 row_number 12345
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
	3.1 order by 全排序; sort by 为每个reducer产生一个排序文件; distribute by 控制特定行到哪一个reducer; cluster by 在distribute by基础上做sort by
	from records 
	select year, temperature
	distribute by year
	sort by year asc, temperature desc;
	
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