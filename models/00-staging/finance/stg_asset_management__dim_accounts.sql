with 

source as (

    select * from {{ source('asset_management', 'dim_accounts') }}

),

renamed as (

    select
        account_id,
        account_type,
        account_status,
        balance,
        currency,
        open_date

    from source

)

select * from renamed
