-- [5] 메타 데이터 쿼리

-- 5-1. 모든 테이블 조회
SELECT *
  FROM information_schema.tables;

-- 5.2 모든 열 조회
SELECT *
  FROM information_schema.columns;

-- 5-3. 인덱싱 열 조회
SELECT *
  FROM pg_catalog.pg_indexes a,
       information_schema.columns b
 WHERE a.tablename = b.table_name;

-- 5-4. 제약조건 조회
SELECT *
  FROM information_schema.table_constraints a,
       information_schema.key_column_usage b
 WHERE a.table_name = b.table_name;

-- 5-6. 동적 SQL
SELECT 'select count(*) from ' || table_name || ';' AS cnts
  FROM information_schema.tables;

