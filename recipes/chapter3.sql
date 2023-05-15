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


-- 3-7. 같은 데이터 확인 (차집합)
drop view if exists v;
create view v as
select *
from emp
where deptno != 10
union all
select *
from emp
where ename = 'WARD';


--  3-7-1. 방법1 EXCEPT
(select empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        count(1)
 from emp
 group by 1, 2, 3, 4, 5, 6, 7, 8
 except
 select empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        count(1)
 from v
 group by 1, 2, 3, 4, 5, 6, 7, 8)
union all
(select empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        count(1)
 from v
 group by 1, 2, 3, 4, 5, 6, 7, 8
 except
 select empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        count(1)
 from emp
 group by 1, 2, 3, 4, 5, 6, 7, 8);

--  3-7-2. 방법2 NOT EXISTS ???
select *
from (select e.empno,
             e.ename,
             e.job,
             e.mgr,
             e.hiredate,
             e.sal,
             e.comm,
             e.deptno,
             count(1)
      from emp e
      group by 1, 2, 3, 4, 5, 6, 7, 8) e
where not exists(select null
                 from (select v.empno,
                              v.ename,
                              v.job,
                              v.mgr,
                              v.hiredate,
                              v.sal,
                              v.comm,
                              v.deptno,
                              count(1)
                       from v
                       group by 1, 2, 3, 4, 5, 6, 7, 8) v
                 where e.empno = v.empno
                   AND e.ename = v.ename
                   AND e.job = v.job
                   AND e.mgr = v.mgr
                   AND e.hiredate = v.hiredate
                   AND e.sal = v.sal
                   AND coalesce(e.comm, 0) = coalesce(v.comm, 0)
                   AND e.deptno = v.deptno
                   AND e.count = v.count)
union all
select *
from (select v.empno,
             v.ename,
             v.job,
             v.mgr,
             v.hiredate,
             v.sal,
             v.comm,
             v.deptno,
             count(1)
      from v
      group by 1, 2, 3, 4, 5, 6, 7, 8) v
where not exists(select NULL
                 from (select e.empno,
                              e.ename,
                              e.job,
                              e.mgr,
                              e.hiredate,
                              e.sal,
                              e.comm,
                              e.deptno,
                              count(1)
                       from emp e
                       group by 1, 2, 3, 4, 5, 6, 7, 8) e
                 where e.empno = v.empno
                   AND e.ename = v.ename
                   AND e.job = v.job
                   AND e.mgr = v.mgr
                   AND e.hiredate = v.hiredate
                   AND e.sal = v.sal
                   AND coalesce(e.comm, 0) = coalesce(v.comm, 0)
                   AND e.deptno = v.deptno
                   AND e.count = v.count)
;


-- 3-8. 데카르트 곱
explain
select *
from emp e,
     dept d
where e.deptno = d.deptno
  and e.deptno = 10
;

-- 3-9. 집계 조인
drop view if exists emp_bonus;
create view emp_bonus as
select *
from (VALUES (7934, '17-MAR-2005', 1),
             (7934, '15-MAR-2005', 2),
             (7839, '15-MAR-2005', 3),
             (7782, '15-MAR-2005', 1)) temp (empno, received, type);

with sb as (select distinct e.empno
                          , e.deptno
                          , e.sal
                          , sum(e.sal * (case eb.type when 1 then 0.1 when 2 then 0.2 when 3 then 0.3 end))
                            over (partition by e.empno) bonus
            from emp e
                     join emp_bonus eb on e.empno = eb.empno
            where e.deptno = 10)
select deptno,
       sum(sal)   total_sal,
       sum(bonus) total_bonus
from sb
group by deptno
;

-- 3-10. 집계 시 외부 조인
drop view if exists emp_bonus;
create view emp_bonus as
select *
from (VALUES (7934, '17-MAR-2005', 1),
             (7934, '15-FEB-2005', 2)) temp (empno, received, type);


with sb as (select distinct e.empno
                          , e.deptno
                          , e.sal
                          , sum(e.sal * (case eb.type when 1 then 0.1 when 2 then 0.2 when 3 then 0.3 end))
                            over (partition by e.empno) bonus
            from emp e
                     left join emp_bonus eb on e.empno = eb.empno
            where e.deptno = 10)
select deptno,
       sum(sal)   total_sal,
       sum(bonus) total_bonus
from sb
group by deptno
;

-- 3-11. 누락된 데이터 반환
delete
from emp
where ename = 'YODA';
insert into emp
select 1111,
       'YODA',
       'JEDI',
       null,
       hiredate,
       sal,
       comm,
       null
from emp
where ename = 'KING';

select *
from dept d
         full outer join emp e on d.deptno = e.deptno
where e.deptno is null
   or d.deptno is null
;

-- 3-12. 연산 및 비교에서 null 사용하기
select ename, comm, coalesce(e.comm, 0)
from emp e
where coalesce(e.comm, 0) < (select comm
                             from emp
                             where ename = 'WARD')
;


