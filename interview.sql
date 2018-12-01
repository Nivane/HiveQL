//hive行列转换
//行转列-多行转一行，使用concat_ws(',', collect_set(columnname))
//去重使用collect_set，不去重使用collect_list
select cityname, concat_ws(',',collect_set(regionname)) as address_set 
from cityInfo 
group by cityname;
//列转行-一行转多行，使用explode
select cityname, region 
from cityInfoSet 
lateral view explode(split(address_set, ',')) aa as region;

//hive分组取前几条数据
//用户最喜欢购买的前三个product
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
			
			
			
			
			
			
