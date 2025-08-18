with 

source as (

    select * from {{ source('asset_management', 'dim_clients') }}

),

renamed as (

    select
        client_id,
        client_name,
        client_email,
        investment_style,
        risk_tolerance,
        account_manager,
        created_at

    from source

)

select * from renamed
