with final as (
    select
        customer_id,
        customer_country
    from {{ source('manual', 'customers') }}
)

select * from final
