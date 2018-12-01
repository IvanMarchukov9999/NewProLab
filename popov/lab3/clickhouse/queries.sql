--кол-во кликов по дням
SELECT t, groupArray((d, c)) AS groupArr 
FROM ( 
       SELECT (intDiv(timestamp/1000, 3600*24) * 3600*24) * 1000 as t, toDateTime((intDiv(timestamp/1000, 3600*24) * 3600*24)) d, count(*) c 
       FROM site.event 
       GROUP BY t, d
       order by t, d
     ) 
GROUP BY t ORDER BY t;

--кол-во продаж за каждый час
SELECT t, groupArray((d, c)) AS groupArr 
FROM ( 
       SELECT (intDiv(timestamp/1000, 3600) * 3600) * 1000 as t, extract(item_id,'(?:.*?_){2}(\\d*)') as d, count(*) c 
       FROM site.event 
       GROUP BY t, d
       ORDER BY t, d) 
GROUP BY t ORDER BY t;

--активность пользователей
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

--!!-----------------
--число посетителей на сайте за последние 15 минут
select count(distinct sessionId) buyer_cnt
from   site.event
where  timestamp > (toUInt32(now())-15*60)*1000;

--число заказов за последние 15 минут
select count(*) orders_cnt
from   site.event
where  eventType in ('itemBuyEvent')
   and timestamp > (toUInt32(now())-15*60)*1000;
   
--конверсия общая
select
    sumIf(cnt, deep = 3) / (sumIf(cnt, deep = 2)+sumIf(cnt, deep = 1))*100 conver_proc
from
(
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
)
;

--конверсия за последний час
select
    sumIf(cnt, deep = 3) / (sumIf(cnt, deep = 2)+sumIf(cnt, deep = 1))*100 conver_proc
from
(
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
          where timestamp > (toUInt32(now())-3*60*60)*1000
          group by sessionId
      )
  )
  group by deep
)
;

--средний чек заказа
--значение меняется в течение дня безотносительно времени
SELECT t, groupArray((dt, sum_price_by_dt)) AS groupArr 
FROM ( 
  select (intDiv(timestamp/1000, 3600) * 3600) * 1000 as t, 
         dt, sum_price_by_dt
  from
  (
      select timestamp, toDate(timestamp/1000) as dt
        from site.event 
       where eventType in ('itemBuyEvent')
  ) any inner join
  (
    select toDate(timestamp/1000) dt,
         round(avg(toFloat64(item_price)),2) sum_price_by_dt
    from site.event
    where eventType in ('itemBuyEvent')
    group by dt
  )
  using dt
)
GROUP BY t ORDER BY t;

--средний чек заказа с начала дня + сумма заказов с начала дня


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

insert into site.repo_agg
select 1543345200 ts,
       avg(toDecimal32(item_price, 2)) avg_price,
       sum(toDecimal32(item_price, 2)) sum_price,
       toDate(1543276800) date
       --,item_price
       --,timestamp
  from site.event
 where eventType in ('itemBuyEvent')
   and timestamp >= 1543276800*1000 and timestamp < 1543345200*1000 + 60*60*1000
--order by timestamp
;
OPTIMIZE table site.repo_agg;
select * from site.repo_agg;


