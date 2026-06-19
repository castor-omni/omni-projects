-- models/02-mart/saas/dim_metric.sql

{{ config(materialized='table') }}

select
    column1::varchar  as metric_id,
    column2::varchar  as name,
    column3::varchar  as category,
    column4::varchar  as denominator_type,
    column5::boolean  as higher_is_better,
    column6::varchar  as format
from values
    ('total_users',                       'Total Active Users',        'users',   null,            true, 'integer'),
    ('total_admin_users',                 'Admin Users',               'users',   null,            true, 'integer'),
    ('total_creator_users',               'Creator Users',             'users',   null,            true, 'integer'),
    ('total_viewer_users',                'Viewer Users',              'users',   null,            true, 'integer'),
    ('total_events',                      'Total Events',              'events',  null,            true, 'integer'),
    ('total_agentic_events',              'AI/Agentic Events',         'events',  null,            true, 'integer'),
    ('total_api_events',                  'API Events',                'events',  null,            true, 'integer'),
    ('total_ui_events',                   'UI Feature Events',         'events',  null,            true, 'integer'),
    ('total_admin_other_events',          'Admin/Other Events',        'events',  null,            true, 'integer'),
    ('events_per_user',                   'Events / User',             'rate',    'total_users',   true, 'decimal_2'),
    ('agentic_events_per_user',           'AI Events / User',          'rate',    'total_users',   true, 'decimal_2'),
    ('api_events_per_user',               'API Events / User',         'rate',    'total_users',   true, 'decimal_2'),
    ('ui_events_per_user',                'UI Events / User',          'rate',    'total_users',   true, 'decimal_2'),
    ('admin_other_events_per_user',       'Admin Events / User',       'rate',    'total_users',   true, 'decimal_2'),
    ('admin_other_events_per_admin_user', 'Admin Events / Admin User', 'rate',    'total_admin_users',   true, 'decimal_2'),
    ('agentic_events_per_creator_user',   'AI Events / Creator User',  'rate',    'total_creator_users', true, 'decimal_2'),
    ('ui_events_per_creator_user',        'UI Events / Creator User',  'rate',    'total_creator_users', true, 'decimal_2'),
    ('ui_events_per_viewer_user',         'UI Events / Viewer User',   'rate',    'total_viewer_users',  true, 'decimal_2')