

/*
CREATE TABLE `employees` (
`emp_no` int(11) NOT NULL,
`birth_date` date NOT NULL,
`first_name` varchar(14) NOT NULL,
`last_name` varchar(16) NOT NULL,
`gender` char(1) NOT NULL,
`hire_date` date NOT NULL,
PRIMARY KEY (`emp_no`));
*/


/*
1.查找最晚入职员工的所有信息

*/

    select *
      from employees t1
     where t1.hire_date = (select max(t2.hire_date) from employees t2)


/*
2. 查找入职员工时间排名倒数第三的员工所有信息

*/

    select t2.*
      from employees t2
 left join (select t1.emp_no
                   ,dense_rank() over(order by t1.hire_date desc) as rn 
              from employees t1) t3
        on t3.emp_no = t2.emp_no
     where t3.rn = 3



-- 本题中dense_rank()，rank()和row_number()都可以，引申知识：区别在哪？
--经查询，应该用dense_rank()


--网友的解法
-- distinct 用于去重

    select t2.*
      from employees t2
     where t2.hire_date = (select distinct t1.hire_date 
                             from employees t1 
                         order by t1.hire_date desc
                            limit 2,1)

