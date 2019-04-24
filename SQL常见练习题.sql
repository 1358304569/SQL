

'''
--SQL在线练习网站
--https://www.w3resource.com/sql-exercises/sql-retrieve-from-table.php#SQLEDITOR
'''




/*
编写一个SQL查询，查找至少连续出现三次的数字
id  num
1	1
2	1
3	1
4	2
5	1
6	2
7	2
上面logs表中，只有1是唯一连续出现至少三次的数字，结果是1。
*/

--思路1：找出id连续，num相等的数字
select num as consecutive
  from logs l1,logs l2, logs l3
 where l1.id = l2.id - 1 
   and l2.id = l3.id - 1
   and l1.num = l2.num 
   and l2.num = l3.num


--思路2：
--因为id是连续自增的，可以作为顺序序号id
--对同一个num下进行排序，得到rn，
--由id和rn相减，连续值在该相减过程中，差值是一样的，就可以对差值进行count(1)，超过3个，则计


--注意第4行中的减号！！！

select distinct num as consecutive
  from
		(select num
		        ,count(1) as rn2
		   from (select id,num
					    ,row_number() over(order by id) - row_number() over(partition by num order by id) as rn1 
		           from logs) t1
       group by t1.num,t1.rn1) t2
where t2.rn2 >= 3


--思路3：利用lag函数

with temp_a as
(select  t1.num
		,lag(t1.num,1) over(order by id) as lastnum
		,lag(t1.num,2) over(order by id) as last2num
from logs t1)
select distinct num from temp_a
where temp_a.num = temp_a.lastnum
	and temp_a.lastnum = temp_a.last2num

-- =================================判断用户状态：注册未实名，实名未开户，开户未投资，投资到期============

/*
user_info 表，记录了所有用户的信息，无论什么状态
fact_biz_nono_invest 表，记录了所有投资记录，无论是在投还是到期
fact_biz_nono_aum 表，按每日分区，记录了当日在投记录
*/

--开户未投资：在ui表中，却不在nono_invest表中的user_id

--1. not in 方法--效率低
select ui.id 
from odsopr.user_info ui
where ui.id not in (select distinct temp.user_id from idw.fact_biz_nono_invest temp)


--2. left join 方法
select ui.id
from odsopr.user_info ui
left join idw.fact_biz_nono_invest temp
	on ui.id = temp.user_id
where temp.user_id is null


--3. count(1)思路--速度快
select ui.id
from odsopr.user_info ui
where (select count(1) as num from idw.fact_biz_nono_invest temp where temp.user_id = ui.id) = 0


/*
--投资到期：前一天在nono_aum表中，今天不在的user_id，即为到期---有误！！！
select ui.id
from odsopr.user_info ui
left join (select distinct na.user_id			as user_id
					,1							as expire_flag
			from idw.fact_biz_nono_aum na
			left join (select distinct na.user_id
						from idw.fact_biz_nono_aum na
						where to_date(na.stat_date) = to_date(now(),1)
			  			) t1 on t1.user_id = na.user_id 
			where t1.user_id is null	
				and	to_date(na.stat_date) = days_sub(now(),2)
		  ) t2 on t2.user_id = ui.id

*/




left join (select distinct na.user_id
			 from idw.fact_biz_nono_aum na
			where to_date(aum.stat_date) = to_date(now(),1)
		  )




-- ========================================================================


'''
# --https://www.cnblogs.com/diffrent/p/8854995.html
'''

-- 1.用一条SQL 语句 查询出每门课都大于80 分的学生姓名

select distinct name 
from table
where name not in 
	(select distinct name from table where fenshu <= 80)
;

select name
from table
group by name
having min(fenshu) > 80;

/*
2、 学生表 如下:
id   学号   姓名 课程编号 课程名称 分数
1        2005001 张三 0001      数学    69
2        2005002 李四 0001      数学    89
3        2005001 张三 0001      数学    69
 删除除了自动编号(id)不同, 其他都相同的学生冗余信息
*/

delete
from student
where id not in 
	(select min(id) from student group by 学号,姓名,课程编号,课程名称,分数)


/*
3.一个叫 team 的表，里面只有一个字段name, 一共有4 条纪录，
分别是a,b,c,d, 对应四个球对，现在四个球对进行比赛，用一条sql 语句显示所有可能的比赛组合.
*/

select a.name,b.name
from team a,team b
where a.name < b.name


/*
 4.请用SQL 语句实现：
从TestDB 数据表中查询出所有月份的发生额都比101 科目相应月份的发生额高的科目。
请注意：TestDB 中有很多科目，都有1 －12 月份的发生额。
AccID ：科目代码，Occmonth ：发生额月份，DebitOccur ：发生额。
数据库名：JcyAudit ，数据集：Select * from TestDB
*/

select a.*
from TestDB a
	,(select Occmonth,max(DebitOccur) as Debit101cur
		from TestDB where AccID = '101' group by Occmonth) b
where a.Occmonth = b.Occmonth and a.DebitOccur > b.Debit101cur


/*
5.面试题：怎么把这样一个表儿
year   month amount
1991   1     1.1
1991   2     1.2
1991   3     1.3
1991   4     1.4
1992   1     2.1
1992   2     2.2
1992   3     2.3
1992   4     2.4
查成这样一个结果
year m1   m2   m3   m4
1991 1.1 1.2 1.3 1.4
1992 2.1 2.2 2.3 2.4

*/


select  year
		,(select t1.amount from table t1 where t1.month = 1 and t1.year = t.year)	as m1
		,(select t1.amount from table t1 where t1.month = 2 and t1.year = t.year)	as m2
		,(select t1.amount from table t1 where t1.month = 3 and t1.year = t.year)	as m3
		,(select t1.amount from table t1 where t1.month = 4 and t1.year = t.year)	as m4
from table t
group by t.year


/*
6. 说明：复制表( 只复制结构, 不复制内容，源表名：a新表名：b)

 */


create table b as select * from a where 1 <> 1

/*
7. 说明：拷贝表( 拷贝数据, 源表名：a目标表名：b)
 */


insert into b(a,b,c) select d,e,f from a;



/*
8. 说明：显示文章、提交人和最后回复时间
 */


select a.title,a.author,b.addtime
from table a
	,(select max(t.addtime) as addtime from table t where t.title = a.title) b



/*
9. 说明：外连接查询( 表名1 ：a表名2 ：b)
 */

select  a.a, a.b, a.c
		,b.c, b.d, b.f
from a LEFT OUTER JOIN b
	ON a.a = b.c


/*
10. 说明：日程安排提前五分钟提醒
 */


select * from 日常安排表 where datediff('minute',开始时间,getdate()) > 5


/*
11. 说明：两张关联表，删除主表中已经在,副表中没有的信息
 */

delete
from infoA
where not exists (select * from infoB where infoA.id = infoB.id)


/*
12. 有两个表A 和B ，均有key 和value 两个字段，如果B 的key 在A 中也有，就把B 的value 换为A 中对应的value
这道题的SQL 语句怎么写？
*/

update b
set b.value = (select a.value from a where a.key = b.key)
where b.id in (select b.id from b,a where b.key = a.key)


/*
13.原表:
courseid coursename score
-------------------------------------
1 Java 70
2 oracle 90
3 xml 40
4 jsp 30
5 servlet 80
-------------------------------------
为了便于阅读, 查询此表后的结果显式如下( 及格分数为60):
courseid coursename score mark
---------------------------------------------------
1 Java 70 pass
2 oracle 90 pass
3 xml 40 fail
4 jsp 30 fail
5 servlet 80 pass
---------------------------------------------------
写出此查询语句
*/

select t1.courseid
		,t1.coursename
		,t1.score
		,if(t1.score >= 60, "pass", "fail") as mark
from table 

--原答案，使用decode()函数
-- decode(field, 值1，结果1，值2，结果2，...，默认值)
-- sign()，根据某个值是0、正数还是负数，分别返回0、1、-1，

select t1.courseid
		,t1.coursename
		,t1.score
		,decode(sign(t1.score-60),-1,"fail","pass") as mark
from table 




/*
14. 两张表
table1:		id department
			1   设计
			2   市场
			3   售后

table2:		id dptid name
			1   1	 张三
			2   1	 李四
			3   2	 王五
用一条SQL语句，怎么显示如下结果
id dptID department name
1   1      设计        张三
2   1      设计        李四
3   2      市场        王五
4   3      售后        彭六
5   4      黑人        陈七
*/

--参考答案
SELECT testtable2.* , ISNULL(department,'黑人')
FROM testtable1 right join testtable2 on testtable2.dptID = testtable1.ID

/*
15.有表A，结构如下： 
A: p_ID  p_Num  s_id 
	1 	 10 	01 
	1 	 12		02 
	2 	 8 		01 
	3 	 11		01 
	3 	 8 		03 
其中：p_ID为产品ID，p_Num为产品库存量，s_id为仓库ID。请用SQL语句实现将上表中的数据合并，合并后的数据为： 
p_ID  s1_id  s2_id  s3_id 
1 	   10 	  12 	 0 
2		8 	  0  	 0 
3       11    0      8 
其中：s1_id为仓库1的库存量，s2_id为仓库2的库存量，s3_id为仓库3的库存量。如果该产品在某仓库中无库存量，那么就是0代替。 
*/


select t1.p_id 
	,sum(case when s_id = 01 then p_num else 0 end) as s1_id
	,sum(case when s_id = 02 then p_num else 0 end) as s2_id
	,sum(case when s_id = 03 then p_num else 0 end) as s3_id
from A t1
group by t1.id



/*
16. 触发器的作用

几种触发类型：以SQL Server为例
				DML->insert,update,delete;
				DDL->create,alter,drop;
常用形式：
		create trigger xxx1
			on t1						--在t1表中创建触发器
		   for update					--由什么事件触发
		    as 							--触发后的动作
			   uadate t2
			      set t2.col1 = xxx
				 from t2
				where xxx = xxx

触发器依附在表上，不能依附在视图或临时表

*/


/*
17. 索引的作用，优缺点？

索引就像是书的目录，加快查询速度，减慢插入速度

有两种形式：
	聚集索引，一个表只能有一个，物理上连续的字段，例如字典的拼音查询
	非聚集索引，一个表可以有多个，逻辑上连续的，例如字典的部首查询
	根本区别是表的排列顺序与索引的排列顺序是否一致。

几种索引类型：
	唯一索引，Unique 
	全局索引, Full
	  列索引

更多详细讲解：https://www.cnblogs.com/sheseido/p/5825441.html
*/

/*
18. 为管理业务培训信息，建立3个表：

     t1(s_id, s_name,   s_dep,     s_age)
	    学号，学员姓名，所属单位，学员年龄

     t2(s_id, c_id,     grade) 
	    学号,课程编号，学习成绩

     t3(c_id,   c_name)
	 课程编号，课程名称

*/

--使用标准SQL嵌套语句查询不选修课程编号为’C5’的学员姓名和所属单位?
   select t1.s_name
		  ,t1.s_dep
     from t1
left join t2
	   on t2.s_id = t1.s_id
	where t2.c_id = "C2"

--查询选修了课程的学员人数
   select count(distinct t2.s_id) as "学员人数"
     from t2
	where t2.c_id is not null

--查询选修课程超过5门的学员学号和所属单位?
   select t1.s_id
		  ,t1.s_dep
	 from t1
left join t2
	   on t2.s_id = t2.s_id
 group by t1.s_id,t1.s_dep
   having count(distinct t2.c_id) >5


/*
19. 查询A(ID,Name)表中第31至40条记录，ID作为主键可能不是连续增长的列(即乱序)
*/

--思路：先全局排序，取30之后的
--		再子排序，取前10个，即为31-40条记录

--(mysql写法)
   select A.*
     from A
    where A.id >  select max(t1.id)
				    from ( select *
						     from A
					     order by A.id
						    limit 30
					      ) t1
 order by A.id
    limit 10



/*
20. SQL Server 2000中使用的一些数据库对象

表格、视图、用户定义函数（UDF），存储过程，触发器
*/



-- =============================================================


'''
## https://blog.csdn.net/codema/article/details/80915311
'''








