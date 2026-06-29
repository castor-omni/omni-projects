-- Validated raw-SQL tile queries for the benchmarking workbook (path C / reference).
-- All run green against ANALYTICS_PROD.SAAS via POST /api/v1/query/run.
-- Featured company: Yield Path = '001xx000003E4A09CAAG' (Enterprise / North America).
-- In an Omni raw-SQL tile: query.userEditedSQL = <sql>, rewriteSql=false, topicName=null,
--   query.fields = the UPPERCASE column aliases.

-- 1) scorecard  fields: METRIC, MY_VALUE, PEER_MEDIAN, MY_PERCENTILE
select m.name as METRIC, u.value as MY_VALUE, b.value as PEER_MEDIAN, r.percentile_rank as MY_PERCENTILE
from ANALYTICS_PROD.SAAS.FACT_COMPANY_USAGE_METRICS u
join ANALYTICS_PROD.SAAS.DIM_METRIC m on m.metric_id=u.metric_id
left join ANALYTICS_PROD.SAAS.FACT_COMPANY_PERCENTILE_RANK r
  on r.account_id=u.account_id and r.snapshot_month=u.snapshot_month and r.metric_id=u.metric_id
 and r.peer_group_segment='__ALL__' and r.peer_group_region='__ALL__' and r.peer_group_product_tier='__ALL__'
left join ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS b
  on b.snapshot_month=u.snapshot_month and b.metric_id=u.metric_id and b.statistic='p50'
 and b.peer_group_segment='__ALL__' and b.peer_group_region='__ALL__' and b.peer_group_product_tier='__ALL__'
where u.account_id='001xx000003E4A09CAAG'
 and u.metric_id in ('total_events','total_agentic_events','total_api_events','total_ui_events','total_admin_other_events')
 and u.snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_COMPANY_USAGE_METRICS)
order by MY_VALUE desc;

-- 2) distribution (My Value vs Enterprise/N.America peer band, AI/Agentic Events)  fields: SERIES, AMOUNT, ORD
select SERIES, AMOUNT, ORD from (
  select 'My Value' as SERIES, u.value as AMOUNT, 1 as ORD
    from ANALYTICS_PROD.SAAS.FACT_COMPANY_USAGE_METRICS u
    where u.account_id='001xx000003E4A09CAAG' and u.metric_id='total_agentic_events'
      and u.snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_COMPANY_USAGE_METRICS)
  union all select 'Peer P25', value, 2 from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS
    where metric_id='total_agentic_events' and statistic='p25' and peer_group_segment='Enterprise' and peer_group_region='North America' and peer_group_product_tier='__ALL__' and snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS)
  union all select 'Peer Median', value, 3 from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS
    where metric_id='total_agentic_events' and statistic='p50' and peer_group_segment='Enterprise' and peer_group_region='North America' and peer_group_product_tier='__ALL__' and snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS)
  union all select 'Peer P75', value, 4 from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS
    where metric_id='total_agentic_events' and statistic='p75' and peer_group_segment='Enterprise' and peer_group_region='North America' and peer_group_product_tier='__ALL__' and snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS)
  union all select 'Peer P90', value, 5 from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS
    where metric_id='total_agentic_events' and statistic='p90' and peer_group_segment='Enterprise' and peer_group_region='North America' and peer_group_product_tier='__ALL__' and snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS)
) order by ORD;

-- 3) percentile by cohort (cohort choice matters)  fields: PEER_GROUP, MY_PERCENTILE
select case when peer_group_segment='__ALL__' then 'All companies'
            when peer_group_region='__ALL__' then 'Segment: '||peer_group_segment
            else peer_group_segment||' / '||peer_group_region end as PEER_GROUP,
       percentile_rank as MY_PERCENTILE
from ANALYTICS_PROD.SAAS.FACT_COMPANY_PERCENTILE_RANK
where account_id='001xx000003E4A09CAAG' and metric_id='total_agentic_events'
  and snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_COMPANY_PERCENTILE_RANK)
  and peer_group_product_tier='__ALL__'
  and ( (peer_group_segment='__ALL__' and peer_group_region='__ALL__')
     or (peer_group_segment='Enterprise' and peer_group_region='__ALL__')
     or (peer_group_segment='Enterprise' and peer_group_region='North America') )
order by MY_PERCENTILE;

-- 4) AI adoption trend vs peer median (Enterprise/N.America)  fields: MONTH, MY_VALUE, PEER_MEDIAN
select to_varchar(u.snapshot_month,'YYYY-MM') as MONTH, u.value as MY_VALUE, b.value as PEER_MEDIAN
from ANALYTICS_PROD.SAAS.FACT_COMPANY_USAGE_METRICS u
left join ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS b
  on b.snapshot_month=u.snapshot_month and b.metric_id=u.metric_id and b.statistic='p50'
 and b.peer_group_segment='Enterprise' and b.peer_group_region='North America' and b.peer_group_product_tier='__ALL__'
where u.account_id='001xx000003E4A09CAAG' and u.metric_id='total_agentic_events'
  and u.snapshot_month >= dateadd('month',-11,(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_COMPANY_USAGE_METRICS))
order by MONTH;

-- 5) peer benchmark overview, all companies, event metrics  fields: METRIC, P25, MEDIAN, P75, P90
select m.name as METRIC,
       max(case when b.statistic='p25' then b.value end) as P25,
       max(case when b.statistic='p50' then b.value end) as MEDIAN,
       max(case when b.statistic='p75' then b.value end) as P75,
       max(case when b.statistic='p90' then b.value end) as P90
from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS b join ANALYTICS_PROD.SAAS.DIM_METRIC m on m.metric_id=b.metric_id
where b.peer_group_segment='__ALL__' and b.peer_group_region='__ALL__' and b.peer_group_product_tier='__ALL__'
  and b.snapshot_month=(select max(snapshot_month) from ANALYTICS_PROD.SAAS.FACT_BENCHMARK_STATS) and m.category='events'
group by m.name order by MEDIAN desc;
