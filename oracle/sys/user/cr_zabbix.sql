CREATE USER zabbix IDENTIFIED BY <PASSWORD>;
-- Grant access to the zabbix user.
GRANT CONNECT, CREATE SESSION TO zabbix;
GRANT SELECT ON v_$instance TO zabbix;
GRANT SELECT ON v_$database TO zabbix;
GRANT SELECT ON v_$sysmetric TO zabbix;
GRANT SELECT ON v_$system_parameter TO zabbix;
GRANT SELECT ON v_$session TO zabbix;
GRANT SELECT ON v_$recovery_file_dest TO zabbix;
GRANT SELECT ON v_$active_session_history TO zabbix;
GRANT SELECT ON v_$osstat TO zabbix;
GRANT SELECT ON v_$restore_point TO zabbix;
GRANT SELECT ON v_$restore_point TO zabbix;
GRANT SELECT ON v_$process TO zabbix;
GRANT SELECT ON v_$datafile TO zabbix;
GRANT SELECT ON v_$pgastat TO zabbix;
GRANT SELECT ON v_$sgastat TO zabbix;
GRANT SELECT ON v_$log TO zabbix;
GRANT SELECT ON v_$archive_dest TO zabbix;
GRANT SELECT ON v_$asm_diskgroup TO zabbix;
GRANT SELECT ON sys.dba_data_files TO zabbix;
GRANT SELECT ON DBA_TABLESPACES TO zabbix;
GRANT SELECT ON DBA_TABLESPACE_USAGE_METRICS TO zabbix;
GRANT SELECT ON DBA_USERS TO zabbix;
-- Required for v$restore_point
grant SELECT_CATALOG_ROLE to zabbix;
-- Additional grants
grant select on dba_objects to zabbix;
grant select on dba_indexes to zabbix;
grant select on dba_ind_partitions to zabbix;
grant select on dba_segments to zabbix;