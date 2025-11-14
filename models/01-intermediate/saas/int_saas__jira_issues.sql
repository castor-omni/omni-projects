select * from {{ ref('stg_saas__jira_issues') }}
WHERE created_date < current_date