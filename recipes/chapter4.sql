-- [4] 삽입, 갱신, 삭제

-- 4-1. 레코드 생성
INSERT INTO dept
VALUES (50, 'PROGRAMMING', 'BALTIMORE');


-- 4-2. 기본값 삽입
DROP TABLE IF EXISTS d;
CREATE TABLE d (
    id INTEGER DEFAULT 0
);
INSERT INTO d
VALUES (default);

SELECT *
  FROM d;

-- 4-3. null로 오버라이딩
DROP TABLE IF EXISTS d;
CREATE TABLE d (
    id  INTEGER DEFAULT 0,
    foo VARCHAR(10)
);
INSERT INTO d
VALUES (NULL, 'bright');

SELECT *
  FROM d;


-- 4-3. null로 오버라이딩
DROP TABLE IF EXISTS d;
CREATE TABLE d (
    id  INTEGER DEFAULT 0,
    foo VARCHAR(10)
);
INSERT INTO d
VALUES (NULL, 'bright');

SELECT *
  FROM d;


-- 4-4. 테이블에다 다른 테이블로 복사하기
DROP TABLE IF EXISTS dept_east;
CREATE TABLE dept_east (
    LIKE dept
);

INSERT INTO dept_east
SELECT *
  FROM dept;

SELECT *
  FROM dept_east;

-- 4-5. 테이블 정의 복사하기
DROP TABLE IF EXISTS dept2;
CREATE TABLE dept2 (
    LIKE dept
);

SELECT *
  FROM dept2;


-- 4-6. 여러 테이블에 삽입하기 (다중 테이블 삽입)
DROP TABLE IF EXISTS dept_east , dept_west, dept_mid;
CREATE TABLE dept_east (
    LIKE dept
);
CREATE TABLE dept_west (
    LIKE dept
);
CREATE TABLE dept_mid (
    LIKE dept
);

-- Oracle 만 지원
-- insert all
--     when loc in ('NEWYORK', 'BOSTON') then into dept_east values
--     when loc in ('CHICACO') then into dept_mid values
--     else into dept_west values
--     select * from dept

-- 4-7. 특정 컬럼만 복사
DROP VIEW IF EXISTS emp2;
CREATE VIEW emp2 AS
SELECT empno, ename, job
  FROM emp;

-- Oralce 만 지원
-- insert into (select empno, ename, job from emp) values (9,'Jonathan','editor')

SELECT *
  FROM emp2;

-- 4-8. 특정 컬럼만 복사
UPDATE emp
   SET sal=sal * 1.1
 WHERE deptno = 20;

SELECT *
  FROM emp
 WHERE deptno = 20;

-- 4-9. 다른 테이블의 행 업데이트
DROP VIEW IF EXISTS emp_bonus;
CREATE VIEW emp_bonus AS
SELECT *
  FROM (VALUES (7369, '14-MAR-2005', 1), (7900, '14-MAR-2005', 2), (7934, '14-MAR-2005', 3)) v(empno, received, type);

UPDATE emp
   SET sal=sal * 1.2
 WHERE EXISTS(SELECT NULL
                FROM emp_bonus
               WHERE emp.empno = emp_bonus.empno);
SELECT *
  FROM emp
 WHERE EXISTS(SELECT NULL
                FROM emp_bonus
               WHERE emp.empno = emp_bonus.empno);


-- 4-10. 다른 테이블 값으로 업데이트 (update join)
DROP VIEW IF EXISTS new_sal;
CREATE VIEW new_sal AS
SELECT *
  FROM (VALUES (10, 4000)) newsal(deptno, sal);

SELECT *
  FROM new_sal;

UPDATE emp
   SET sal  = ns.sal,
       comm = ns.sal / 2
  FROM new_sal ns
 WHERE ns.deptno = emp.deptno;

-- 4-11. 레코드 병합 (삾입, 갱신, 삭제를 동시에)
DROP TABLE IF EXISTS emp_commission;
CREATE TABLE emp_commission AS
SELECT *
  FROM (VALUES (10, 7782, NULL), (10, 7839, NULL), (10, 7934, NULL)) v(deptno, empno, comm);
ALTER TABLE emp_commission
    ADD CONSTRAINT unique_empno UNIQUE (empno);

SELECT *
  FROM emp_commission;

-- Oracle
-- MERGE INTO emp_commission ec
-- USING emp e
-- ON (ec.empno = e.empno)
-- WHEN MATCHED THEN
--  UPDATE SET ec.comm = 1000
--  DELETE WHERE e.sal < 2000
-- WHEN NOT MATCHED THEN
--  INSERT (deptno, empno, comm) VALUES (e.deptno, e.empno, e.comm);

INSERT INTO emp_commission (deptno, empno, comm)
SELECT e.deptno, e.empno, e.comm
  FROM emp e
       LEFT JOIN emp_commission ec ON e.empno = ec.deptno
    ON CONFLICT (empno) DO UPDATE SET comm = 1000;

DELETE
  FROM emp_commission
 WHERE empno IN (SELECT ec.empno
                   FROM emp_commission ec
                        JOIN emp e ON ec.empno = e.empno
                  WHERE e.sal < 2000);


-- 4-12 ~ 14. 레코드 제거
DELETE
  FROM emp
 WHERE deptno = 10;


-- 4-15. 참조 무결성 레코드 제거
DELETE
  FROM emp e
 WHERE NOT EXISTS(SELECT NULL FROM dept d WHERE d.deptno = e.deptno);

-- 4-16. 테이블 내 중복 레코드 제거 (
DROP TABLE IF EXISTS dupes;
CREATE TABLE dupes AS
SELECT *
  FROM (VALUES (1, 'AAA'), (2, 'AAA'), (3, 'AAA'), (4, 'BBB'), (5, 'BBB')) v(id, name);

SELECT *
  FROM dupes;

DELETE
  FROM dupes
 WHERE id NOT IN (SELECT MIN(id) FROM dupes GROUP BY name);