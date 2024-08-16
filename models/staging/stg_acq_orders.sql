with final as (
    select
        customer_id,
        taxonomy_business_category_group as acquisition_taxonomy
    from {{ source('manual', 'acq_orders') }}
)

select * from final
