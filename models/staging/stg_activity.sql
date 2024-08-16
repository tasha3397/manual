with final as (
    select 
        customer_id,
        subscription_id,
        from_date,
        to_date
    from {{ source('manual', 'activity') }}
)

select * from final
