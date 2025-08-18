with 

source as (

    select * from {{ source('asset_management', 'fct_transactions') }}

),

renamed as (

    select
        transaction_id,
        client_id,
        portfolio_id,
        asset_id,
        account_id,
        transaction_type,
        quantity,
        price_per_unit,
        total_amount,
        fees,
        created_at

    from source

)

select * from renamed
