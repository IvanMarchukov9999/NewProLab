## Add table to CH
echo 'DROP TABLE IF EXISTS site.repo_agg' | curl 'http://172.18.0.11:8123/'  --data-binary @-
echo 'CREATE TABLE site.repo_agg (
    ts UInt32,
    avg_price Decimal32(2),
    sum_price Decimal32(2),
    date Date DEFAULT today()
) ENGINE = ReplacingMergeTree(date, (ts), 8192);' | curl 'http://172.18.0.11:8123/' --data-binary @-
echo 'select count(*) from site.repo_agg' | curl 'http://172.18.0.11:8123/' --data-binary @-

