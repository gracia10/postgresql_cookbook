-- [3] 다중 테이블 작업

-- 3-1. 결과셋 포개기
-- EXPLAIN
select ename, deptno
from emp
where emp.deptno = 10
union all
select dname, deptno
from dept;

-- 3-2. 연관 행 결합
-- EXPLAIN
select a.ename, b.dname
from emp a,
     dept b
where a.deptno = b.deptno
  and a.deptno = 10;

-- 3-3. 공통 행 찾기
drop view if exists v;
create view v as
select ename, job, sal
from emp
where job = 'CLERK';

EXPLAIN
select b.*
from v a
         join emp b
              on (a.ename = b.ename and a.job = b.job and a.sal = b.sal);

EXPLAIN
select *
from emp
where (ename, job, sal) in (select * from v);

-- 3-4. 다른 테이블에 없는 값
select deptno
from dept
except
select deptno
from emp;

SELECT deptno
FROM dept d
WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE e.deptno = d.deptno);

-- 3-5. 다른 테이블에 없는 행 (안티조인)
select d.*
from dept d
         left outer join emp e on d.deptno = e.deptno
where e.deptno is null;

-- 3-6. 조인을 방해하지 않고 추가 정보 얻기
drop view if exists emp_bonus;
create view emp_bonus as
select *
from (VALUES (7369, '14-MAR-2005', 1), (7900, '14-MAR-2005', 2), (7788, '14-MAR-2005', 3)) v(empno, received, type);

select e.ename, d.loc, eb.received
from emp e
         inner join dept d on d.deptno = e.deptno
         left outer join emp_bonus eb on e.empno = eb.empno;

select e.ename,
       d.loc,
       (select eb.received from emp_bonus eb where eb.empno = e.empno) received
from emp e
         inner join dept d on d.deptno = e.deptno;

------------------

-- 3-7. 같은 데이터 확인
-- drop view if exists v;
-- create view v as
-- select * from emp where deptno != 10
-- intersect
-- select * from emp where ename = 'WARD';
--
-- select * from v;