-- [2] 결과 정렬

-- 2-1. 오름차순
select ename, job, sal
from emp
where deptno = 10
order by sal;

-- 2-2. 다중필드
select empno, deptno, sal, ename, job
from emp
order by deptno, sal desc;

-- 2-3. 마지막 두글자
select empno, job
from emp
order by substr(job, length(job));

-- 2-4. 영숫자 혼합 데이터 정렬
-- create view V as select ename||' '||deptno as data from emp;
select *
from V
order by replace(data, replace(translate(data, '0123456789', '#########'), '#', ''), '');

select *
from V
order by replace(translate(data, '0123456789', '#########'), '#', '');


-- 2-5. null 마지막 정렬
select *
from emp
order by comm nulls last;

-- 2-6. 조건을 넣은 정렬
select ename, sal, job, comm
from emp
order by case when job = 'SALESMAN' then comm else sal end