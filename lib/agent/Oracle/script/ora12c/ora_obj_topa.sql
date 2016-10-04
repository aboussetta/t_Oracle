SELECT
    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS') TIME,
    B.OWNER,
    DECODE(B.SUBOBJECT_NAME,NULL,B.OBJECT_NAME,B.OBJECT_NAME||'('||B.SUBOBJECT_NAME||')') SEGMENT_NAME,
    C.BYTES,
    C.BUFFER_POOL,
    B.OBJECT_TYPE,
    B.TABLESPACE_NAME,
    A.LOGICAL_READS,
    A.LR_RATIO,
    A.PHYSICAL_READS,
    A.PR_RATIO,
    A.PHYSICAL_WRITES,
    A.RW_RATIO
FROM (
    SELECT
        A.SNAP_ID,
        A.TS#,
        A.OBJ#,
        A.DATAOBJ#,
        A.LOGICAL_READS_DELTA LOGICAL_READS,
        ROUND((RATIO_TO_REPORT(A.LOGICAL_READS_DELTA) OVER ())*100,2) LR_RATIO,
        A.PHYSICAL_READS_DELTA PHYSICAL_READS,
        ROUND((RATIO_TO_REPORT(A.PHYSICAL_READS_DELTA) OVER ())*100,2) PR_RATIO,
        A.PHYSICAL_WRITES_DELTA PHYSICAL_WRITES,
        ROUND((RATIO_TO_REPORT(A.PHYSICAL_WRITES_DELTA) OVER ())*100,2) RW_RATIO
    FROM DBA_HIST_SEG_STAT A
    WHERE SNAP_ID = (SELECT MAX(SNAP_ID) FROM DBA_HIST_SNAPSHOT)
      and INSTANCE_NUMBER = (SELECT INSTANCE_NUMBER from V$INSTANCE)
) A,
DBA_HIST_SEG_STAT_OBJ B,
DBA_SEGMENTS C,
DBA_HIST_SNAPSHOT D
WHERE A.TS# = B.TS#
  AND A.OBJ# = B.OBJ#
  AND A.DATAOBJ# = B.DATAOBJ#
  AND B.OWNER <> 'SYS'
  AND B.OBJECT_NAME = C.SEGMENT_NAME
  AND B.OWNER = C.OWNER
  AND B.OBJECT_TYPE = C.SEGMENT_TYPE
  AND A.SNAP_ID = D.SNAP_ID
  AND NVL(B.SUBOBJECT_NAME,' ') = NVL(C.PARTITION_NAME,' ')
ORDER BY PR_RATIO DESC
;
