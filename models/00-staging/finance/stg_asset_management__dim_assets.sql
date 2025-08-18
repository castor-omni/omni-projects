with 

source as (

    select * from {{ source('asset_management', 'dim_assets') }}

),

renamed as (

    select
        asset_id,
        asset_name,
        asset_type,
        asset_class,
        sector,
        current_price

    from source

)

select * from renamed
