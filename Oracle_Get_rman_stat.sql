select 'RMAN::Archlog backup count' as Metric,
       To_Char(count(Status)) as VALUE
  from V$rman_Status t
 where t.Object_Type = 'ARCHIVELOG'
   and t.End_Time > SYSDATE - 1
UNION
select 'RMAN::Archlog backup status' as Metric,
       Decode(Status,
              'COMPLETED',
              '0',
              'RUNNING',
              '0',
              'COMPLETED WITH WARNINGS',
              '0',
              'RUNNING WITH WARNINGS',
              '0',
              '1') as VALUE
  from V$rman_Status t
 where t.Object_Type = 'ARCHIVELOG'
   and t.Recid = (select max(t.Recid)
                    from V$rman_Status t
                   where t.Object_Type = 'ARCHIVELOG')
UNION
select 'RMAN::FRA backup count 24h' as Metric,
       To_Char(count(Status)) as Value
  from V$rman_Status t
 where t.Object_Type in ('RECVR AREA')
   and t.End_Time > SYSDATE - 1
UNION
select 'RMAN::FRA backup count 48h' as Metric,
       To_Char(count(Status)) as Value
  from V$rman_Status t
 where t.Object_Type in ('RECVR AREA')
   and t.End_Time > SYSDATE - 2
UNION
select 'RMAN::FRA backup status' as Metric,
       Decode(Status,
              'COMPLETED',
              '0',
              'RUNNING',
              '0',
              'COMPLETED WITH WARNINGS',
              '0',
              'RUNNING WITH WARNINGS',
              '0',
              '1') as Value
  from V$rman_Status t
 where t.Object_Type in ('RECVR AREA')
   and t.Recid = (select max(t.Recid)
                    from V$rman_Status t
                   where t.Object_Type in ('RECVR AREA'))
UNION
select 'RMAN::full/incr backup count' as Metric,
       To_Char(count(Status)) as Value
  from V$rman_Status t
 where t.Object_Type in ('DB FULL', 'DB INCR')
   and t.End_Time > SYSDATE - 1
UNION
select 'RMAN::full/incr backup status' as Metric,
       Decode(Status,
              'COMPLETED',
              '0',
              'RUNNING',
              '0',
              'COMPLETED WITH WARNINGS',
              '0',
              'RUNNING WITH WARNINGS',
              '0',
              '1') as Value
  from V$rman_Status t
 where t.Object_Type in ('DB FULL', 'DB INCR')
   and t.Recid = (select max(t.Recid)
                    from V$rman_Status t
                   where t.Object_Type in ('DB FULL', 'DB INCR'))
