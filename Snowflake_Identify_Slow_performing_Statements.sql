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
