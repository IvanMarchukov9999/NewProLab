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
    where timestamp >= ${time}
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
FORMAT JSONEachRow
;