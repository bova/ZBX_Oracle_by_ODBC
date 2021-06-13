with Status_Type as
 (select Column_Value as Status
    from table(Sys.Odcivarchar2list('RUNNING',
                                    'RUNNING WITH WARNINGS',
                                    'RUNNING WITH ERRORS',
                                    'COMPLETED',
                                    'COMPLETED WITH WARNINGS',
                                    'COMPLETED WITH ERRORS',
                                    'FAILED'))
  
  )
-- Full backup status
select 'RMAN::Backup ' || t.Object_Type || ', ' || St.Status as Metric,
       count(*) as value
  from V$rman_Status t
  full outer join Status_Type St
    on St.Status = t.Status
 where 1 = 1
--   and t.Object_Type in ('DB FULL', 'DB INCR')
   and t.Start_Time > (SYSDATE - 1)
 group by t.Object_Type, St.Status
/*
union
-- Increlental backup status
select 'RMAN::Incremental backup status' as Metric,
       Decode(Status,
              'COMPLETED',
              '0',
              'RUNNING',
              '0',
              'COMPLETED WITH WARNINGS',
              '0',
              'RUNNING WITH WARNINGS',
              '0',
              '1') as value
  from V$rman_Status t
 where t.Object_Type in ('DB INCR') and
 t.Recid = (select max(t.Recid)
              from V$rman_Status t
             where t.Object_Type in ('DB INCR'))
*/
