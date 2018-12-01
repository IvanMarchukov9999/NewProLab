select
    sumIf(cnt, deep = 3) / (sumIf(cnt, deep = 2)+sumIf(cnt, deep = 1)) conversion_rate
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
FORMAT JSONEachRow
;