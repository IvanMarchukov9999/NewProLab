insert into site.repo_agg
select ${day_hh} ts,
       avg(toDecimal32(item_price, 2)) avg_price,
       sum(toDecimal32(item_price, 2)) sum_price,
       toDate(${day_00}) date
  from site.event
 where eventType in ('itemBuyEvent')
   and timestamp >= ${day_00}*1000 and timestamp < ${day_hh}*1000 + 60*60*1000
group by ts, date
;