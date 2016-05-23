SELECT /*+ ORDERED USE_NL(A C D) */
    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') TIME,
    A.SQL_ID,
    A.PLAN_HASH_VALUE,
    D.OLD_HASH_VALUE,
    D.HASH_VALUE,
    A.EXECUTIONS,
    A.DISK_READS,
    A.BUFFER_GETS,
    A.ROWS_PROCESSED,
    A.CPU_TIME,
    A.ELAPSED_TIME,
    C.COMMAND_TYPE,
    A.MODULE
FROM (
    SELECT /*+ ORDERED USE_NL(A B) */
        B.SQL_ID,
        B.PLAN_HASH_VALUE,
        SUM(B.EXECUTIONS_DELTA) EXECUTIONS,
        SUM(B.DISK_READS_DELTA) DISK_READS,
        SUM(B.BUFFER_GETS_DELTA) BUFFER_GETS,
        SUM(B.ROWS_PROCESSED_DELTA) ROWS_PROCESSED,
        SUM(B.CPU_TIME_DELTA/1000000) "CPU_TIME",
        SUM(B.ELAPSED_TIME_DELTA/1000000) "ELAPSED_TIME",
        B.MODULE
    FROM DBA_HIST_SNAPSHOT A,DBA_HIST_SQLSTAT  B
    WHERE A.END_INTERVAL_TIME > SYSDATE - 1/24
    AND A.SNAP_ID = B.SNAP_ID
    GROUP BY B.SQL_ID,B.PLAN_HASH_VALUE,B.MODULE) A,
DBA_HIST_SQLTEXT C,V$SQL D
WHERE A.SQL_ID  = C.SQL_ID(+)
  AND A.SQL_ID  = D.SQL_ID(+)
  AND D.CHILD_NUMBER(+) = 0
;
