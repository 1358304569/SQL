'''
【Group By和Case When的结合使用】（https://blog.csdn.net/u010037020/article/details/59696119）
'''

/*
按B和C来组合分类，分别计算每种组合情况下D和E的比值，
并且按照横轴为C，纵轴为B的形式展示这些比值

数据源 t1：
B 	C 	D 	E
12	2	6	7
12	1	5	8
11	2	3	4
11	1	1	3
11 	2	3	4
11	2	4	8

想要的结果

Bi	C=1		C=2
12	0.625	0.8571
11	0.3333	0.6250

*/


/* 1. 最常规的group by，但是这样显示的形式不对*/

	select t1.B
		   ,t1.C
		   ,sum(t1.D)/sum(t1.E)
	  from t1
  group by t1.B, t1.C
;




/* 2. 使用临时表，二次查找*/
	select 
	  from 
		   (select t1.B as Bi, sum(t1.D)/sum(t1.E) as C1 from t1 
		   	 where t1.C = 1 group by t1.B
		   ) t1,
		   (select t1.B as Bi, sum(t1.D)/sum(t1.E) as C2 from t1 
		   	 where t1.C = 2 group by t1.B
		   ) t2
	 where t1.Bi = t2.Bi
;



/*3. group by + case when解决问题*/

	select t1.B as Bi
		   ,sum(case t1.C = 1 then t1.D else 0 end)/sum(case t1.C = 1 then t1.E else 0 end) as C1
		   ,sum(case t1.C = 2 then t1.D else 0 end)/sum(case t1.C = 2 then t1.E else 0 end) as C2
	  from t1
  group by t1.B
;




