select
  {{ dbt_utils.star(source('saas', 'jira_issues')) }}
from {{ source('saas', 'jira_issues') }}