with cohorts as (
    select
        activity.customer_id,
        customers.customer_country,
        acq_orders.acquisition_taxonomy,
        date_trunc(activity.from_date, month) as cohort_month
    from {{ ref('stg_activity') }} as activity
    left join {{ ref('stg_customers') }} as customers
      on activity.customer_id = customers.customer_id
    left join {{ ref('stg_acq_orders') }} as acq_orders
      on acq_orders.customer_id = customers.customer_id
    group by 
      customer_id, 
      cohort_month,
      customers.customer_country,
      acq_orders.acquisition_taxonomy
),

final as (
    select
        cohort_month,
        cohorts.customer_country,
        cohorts.acquisition_taxonomy,
        date_diff(date_trunc(to_date, month), cohort_month, month) as months_active,
        count(distinct activity.customer_id) as num_customers
    from {{ ref('stg_activity') }} as activity
    left join cohorts 
      on activity.customer_id = cohorts.customer_id
      and date_trunc(activity.from_date, month) = cohort_month
    group by
        cohort_month,
        cohorts.customer_country,
        cohorts.acquisition_taxonomy,
        months_active
    order by 
      cohort_month desc, 
      customer_country, 
      months_active
)
select *
from final
