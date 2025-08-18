with 

source as (

    select * from {{ source('asset_management', 'dim_portfolios') }}

),

renamed as (

    select
        portfolio_id,
        portfolio_name,
        portfolio_type,
        target_return,
        risk_level,
        inception_date

    from source

)

select * from renamed
