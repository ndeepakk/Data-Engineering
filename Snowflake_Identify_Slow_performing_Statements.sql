-- Identify slow performing SQL statements

select query_id                      as query_id
,      round(bytes_scanned/1024/1024)     as mb_scanned
,    total_elapsed_time / 1000          as elapsed_seconds
,      (partitions_scanned / 
        nullif(partitions_total,0)) * 100 as pct_table_scan
,      percent_scanned_from_cache * 100   as pct_from cache
,    bytes_spilled_to_local_storage     as spill_to_local
,      bytes_spilled_to_remote_storage    as spill_to_remote
from   snowflake.account_usage.query_history
where (bytes_spilled_to_local_storage > 1024 * 1024 or
       bytes_spilled_to_remote_storage > 1024 * 1024 or
       percentage_scanned_from_cache < 0.1)
and  elapsed_seconds > 120
and    bytes_scanned > 1024 * 1024
order by elapsed_seconds desc;


-- This query retrieves the load history of your warehouse for the past hour:

-- use warehouse mywarehouse;

      select *
      from
      table(information_schema.warehouse_load_history(date_range_start=>dateadd
      ('hour',-1,current_timestamp())));
      
-- Three parameters help diagnose slow queries:

-- AVG_RUNNING — the average number of queries executing
-- AVG_QUEUED_LOAD — the average number of queries queued because the warehouse is overloaded
-- AVG_QUEUED_PROVISIONING — the average number of queries queued because Snowflake is provisioning the warehouse
