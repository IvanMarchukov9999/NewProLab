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
    where timestamp >= ${time}
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
FORMAT JSONEachRow
;