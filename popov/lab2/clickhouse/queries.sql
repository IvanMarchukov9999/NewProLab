select
    timestamp
  , sessionId
  , item_id
  , item_url
  , item_price 
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


select
    deep,
    count(sessionId) AS cnt
from
(
    select
        sessionId,
        multiIf(deep_bad_buy = 2, 3, deep) AS deep
    from
    (
        select
            sessionId,
            windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'pageView', eventType = 'itemViewEvent', eventType = 'itemBuyEvent') AS deep,
            windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'pageView', eventType = 'itemBuyEvent') AS deep_bad_buy
        from site.event
        group by sessionId
    )
)
group by deep
;

--result users
select
    item_url,
    real_item_id, 
    multiIf(deep_bad_buy = 1, 2, deep) as deep,
    cnt as count
from
(
    select
        extract(item_id,'(?:.*?_){2}(\\d*)') as real_item_id,
        windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'itemViewEvent', eventType = 'itemBuyEvent') AS deep,
        windowFunnel(3600)(CAST(timestamp / 1000, 'UInt32'), eventType = 'itemBuyEvent') AS deep_bad_buy,
        count(distinct extract(item_id,'(?:.*?_){2}(\\d*)')) cnt
    from site.event
    where timestamp >= 1543176213140
      and eventType in ('itemViewEvent','itemBuyEvent')
    group by extract(item_id,'(?:.*?_){2}(\\d*)')
) any left join
(
  select extract(item_id,'(?:.*?_){2}(\\d*)') real_item_id, item_url
  from   site.event
  where  eventType in ('itemBuyEvent','itemViewEvent')
     and notEmpty(item_url) = 1
)
using real_item_id
;

--result orders
select
    item_url,
    real_item_id, 
    sum_price as sum,
    cnt as count
from
(
    select
        extract(item_id,'(?:.*?_){2}(\\d*)') as real_item_id,
        sum(toDecimal32(item_price, 2))sum_price,
        count(*) cnt
    from site.event
    where timestamp >= 1543176213140
      and eventType in ('itemBuyEvent')
    group by extract(item_id,'(?:.*?_){2}(\\d*)')
) any left join
(
  select extract(item_id,'(?:.*?_){2}(\\d*)') real_item_id, item_url
  from   site.event
  where  eventType in ('itemBuyEvent','itemViewEvent')
     and notEmpty(item_url) = 1
)
using real_item_id
;


;

1543162118220 - Avro
1543159218484

1268722858    - CH

4294967295

