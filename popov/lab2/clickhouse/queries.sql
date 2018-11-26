select
    timestamp
  , sessionId
  , item_id
  , item_url
  from site.event
where timestamp >= 1543176213140
order by timestamp;

select
    timestamp
  , sessionId
  , eventType
  , item_id
  , item_url
  , extract(item_id,'(?:.*?_){2}(\\d*)') real_item_id
from site.event
where timestamp >= 1543176213140
order by timestamp;


SELECT
    deep,
    count(sessionId) AS cnt
FROM
(
    SELECT
        sessionId,
        multiIf(deep_bad_buy = 2, 3, deep) AS deep
    FROM
    (
        SELECT
            sessionId,
            windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'pageView', eventType = 'itemViewEvent', eventType = 'itemBuyEvent') AS deep,
            windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'pageView', eventType = 'itemBuyEvent') AS deep_bad_buy
        FROM site.event
        WHERE timestamp >= 1543176213140
        GROUP BY sessionId
    )
)
GROUP BY deep
;


SELECT
    real_item_id,
    multiIf(deep_bad_buy = 1, 2, deep) AS deep,
    cnt as count
FROM
(
    SELECT
        extract(item_id,'(?:.*?_){2}(\\d*)') real_item_id,
        windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'itemViewEvent', eventType = 'itemBuyEvent') AS deep,
        windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'itemBuyEvent') AS deep_bad_buy,
        count(*) cnt
    FROM site.event
    WHERE timestamp >= 1543176213140
      and eventType in ('itemViewEvent','itemBuyEvent')
    GROUP BY extract(item_id,'(?:.*?_){2}(\\d*)')
)
;

1543162118220 - Avro
1543159218484

1268722858    - CH

4294967295
