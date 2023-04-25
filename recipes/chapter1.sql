-- [1] 레코드 검색

-- 1-1 모두 검색
select *
from emp;

-- 1-2 조건 검색
select *
from emp
where deptno = 10;

-- 1-3 여러 조건 검색
select *
from emp
where deptno = 10
   or comm is not null
   or (deptno = 20 and sal <= 2000);

-- 1-4 특정 열 검색
select ename, deptno, sal
from emp;

-- 1-5 열 이름 지정
select sal as salary, comm as commision
from emp;

-- 1-6 where 절에서 별칭을 사용하는 방법 -> 인라인뷰(서브쿼리)
select *
from (select sal as salary from emp) x
where salary > 200;

-- 1-7 열값 이어 붙이기
select ename || ' WORKS AS A ' || job
from emp;
select concat(ename, ' WORKS AS A ', job)
from emp;

-- 1-8 if-else  -> else 절 생략시 NULL 을 반환
select ename,
       sal,
       case
           when sal <= 2000 then 'UNDERRAPID'
           when sal >= 5000 then 'OVERRAPID'
           else 'OK'
           end as status
from emp;

-- 1-9 갯수제한
select *
from emp
limit 10;

-- 1-10 무작위 조회
select *
from emp
order by random()
limit 5;

-- 1-11 null 찾기
select *
from emp
where sal is null;

-- 1-12 null 변환
select coalesce(comm, 0)
from emp;

-- 1-13 패턴검색
select *
from emp
where ename like '%I%'
   or job like '%ER'