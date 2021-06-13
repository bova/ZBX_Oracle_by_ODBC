SELECT 'SYS::' || METRIC_NAME AS METRIC, ROUND(VALUE,3) as VALUE
 FROM V$SYSMETRIC WHERE GROUP_ID = 2
UNION
  SELECT 'SYSPARAM::' || INITCAP(NAME) AS METRIC, to_number(VALUE)
  FROM V$SYSTEM_PARAMETER WHERE NAME IN ('sessions', 'processes', 'db_files')
UNION
 SELECT 'SESSION::Long time locked' ,count(*) FROM V$SESSION s WHERE s.BLOCKING_SESSION IS NOT NULL AND s.BLOCKING_SESSION_STATUS='VALID' AND s.SECONDS_IN_WAIT > {$ORACLE.SESSION.LOCK.MAX.TIME}
UNION
SELECT 'SESSION::Lock rate' ,(cnt_block / cnt_all)* 100 pct
FROM ( SELECT COUNT(*) cnt_block FROM v$session WHERE blocking_session IS NOT NULL), ( SELECT COUNT(*) cnt_all FROM v$session)
UNION
  SELECT 'SESSION::Long time locked' ,count(*) FROM V$SESSION s WHERE s.BLOCKING_SESSION IS NOT NULL AND s.BLOCKING_SESSION_STATUS='VALID' AND s.SECONDS_IN_WAIT > {$ORACLE.SESSION.LOCK.MAX.TIME}
UNION
 SELECT 'SESSION::Total', COUNT(*) AS VALUE FROM V$SESSION
UNION
SELECT 'SESSION::Concurrency rate', NVL(ROUND(SUM(duty_act.cnt*100 / num_cores.val)), 0)
FROM
( SELECT DECODE(session_state, 'ON CPU', 'CPU', wait_class) wait_class, ROUND(COUNT(*)/(60 * 15), 1) cnt
FROM v$active_session_history sh
WHERE sh.sample_time >= SYSDATE - 15 / 1440 AND DECODE(session_state, 'ON CPU', 'CPU', wait_class) IN('Concurrency')
GROUP BY DECODE(session_state, 'ON CPU', 'CPU', wait_class)) duty_act,
( SELECT SUM(value) val FROM v$osstat WHERE stat_name = 'NUM_CPU_CORES') num_cores
UNION
 SELECT 'PGA::' || INITCAP(NAME), VALUE FROM V$PGASTAT
UNION
 SELECT 'FRA::Space Limit' AS METRIC, space_limit AS VALUE FROM V$RECOVERY_FILE_DEST
UNION
 SELECT 'FRA::Space Used', space_used AS VALUE FROM V$RECOVERY_FILE_DEST
UNION
 SELECT 'FRA::Space Reclaimable', space_reclaimable AS VALUE FROM V$RECOVERY_FILE_DEST
UNION
 SELECT 'FRA::Number Of Files', number_of_files AS VALUE FROM V$RECOVERY_FILE_DEST
UNION
 SELECT 'FRA::Usable Pct', DECODE(space_limit, 0, 0,(100-(100 *(space_used-space_reclaimable)/ space_limit))) AS VALUE FROM V$RECOVERY_FILE_DEST
UNION
 SELECT 'FRA::Restore Point', COUNT(*) AS VALUE FROM V$RESTORE_POINT
UNION
 SELECT 'PROC::Procnum', COUNT(*) FROM v$process
UNION
 SELECT 'DATAFILE::Count', COUNT(*) FROM v$datafile
UNION
 SELECT 'SGA::' || INITCAP(pool), SUM(bytes) FROM V$SGASTAT
 WHERE pool IN ( 'java pool', 'large pool' ) GROUP BY pool
UNION
 SELECT 'SGA::Shared Pool', SUM(bytes) FROM V$SGASTAT
 WHERE pool = 'shared pool' AND name NOT IN ('library cache', 'dictionary cache', 'free memory', 'sql area')
UNION
 SELECT 'SGA::' || INITCAP(name), bytes FROM V$SGASTAT
 WHERE pool IS NULL AND name IN ('log_buffer', 'fixed_sga')
UNION
 SELECT 'SGA::Buffer_Cache', SUM(bytes) FROM V$SGASTAT
 WHERE pool IS NULL AND name IN ('buffer_cache', 'db_block_buffers')
UNION
 SELECT 'REDO::Available', count(*) from v$log t where t.status in ('INACTIVE', 'UNUSED')
UNION
 SELECT 'USER::Expire password', ROUND(DECODE(SIGN(NVL(u.expiry_date, SYSDATE + 999) - SYSDATE),-1, 0, NVL(u.expiry_date, SYSDATE + 999) - SYSDATE)) exp_passwd_days_before
FROM dba_users u WHERE username = UPPER('{$ORACLE.USER}')
UNION
select 'ASH::' || Decode(Session_State, 'ON CPU', 'CPU', 'User I/O', 'User I/O', 'Waiting') as Metric, Round(count(*) / 60, 1) as Value
  from V$active_Session_History where Sample_Time > (SYSDATE - INTERVAL '1' Minute) group by Session_State
UNION
select 'OBJECT::Invalid count', count(*) from dba_objects where status='INVALID'
UNION
select 'INDEX::Nonpartitioned unusable count', count(*) from dba_indexes where status = 'UNUSABLE'
UNION
select 'INDEX::Partitioned unusable count', count(*) from dba_ind_partitions where status = 'UNUSABLE';