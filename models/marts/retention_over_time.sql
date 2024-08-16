with date_spine as (
    select
        date_trunc(date, month) as month
    from
        unnest(generate_date_array('2019-01-04', current_date(), interval 1 month)) as date
),

active_users as (
    select
        date_spine.month,
        customers.customer_country,
        acq_orders.acquisition_taxonomy,
        count(distinct activity.customer_id) as active_customers
    from date_spine
    left join {{ ref('stg_activity') }} as activity
        on date_trunc(activity.from_date, month) <= date_spine.month
        and (activity.to_date is null or date_trunc(activity.to_date, month) >= date_spine.month)
    left join {{ ref('stg_customers') }} as customers
        on activity.customer_id = customers.customer_id
    left join {{ ref('stg_acq_orders') }} as acq_orders
        on activity.customer_id = acq_orders.customer_id
    group by
        date_spine.month,
        customers.customer_country,
        acq_orders.acquisition_taxonomy
),

sign_ups as (
    select
        date_spine.month,
        customers.customer_country,
        acq_orders.acquisition_taxonomy,
        count(distinct activity.customer_id) as sign_ups
    from date_spine
    left join {{ ref('stg_activity') }} as activity
        on date_spine.month = date_trunc(activity.from_date, month)
    left join {{ ref('stg_customers') }} as customers
        on activity.customer_id = customers.customer_id
    left join {{ ref('stg_acq_orders') }} as acq_orders
        on activity.customer_id = acq_orders.customer_id
    group by
        date_spine.month,
        customers.customer_country,
        acq_orders.acquisition_taxonomy
),

churn as (
    select
        date_spine.month,
        customers.customer_country,
        acq_orders.acquisition_taxonomy,
        count(distinct activity.customer_id) as churn
    from date_spine
    left join {{ ref('stg_activity') }} as activity
        on date_spine.month = date_trunc(activity.to_date, month)
    left join {{ ref('stg_customers') }} as customers
        on activity.customer_id = customers.customer_id
    left join {{ ref('stg_acq_orders') }} as acq_orders
        on activity.customer_id = acq_orders.customer_id
    group by
        date_spine.month,
        customers.customer_country,
        acq_orders.acquisition_taxonomy
),

final as (
    select
        date_spine.month,
        coalesce(active_users.customer_country, sign_ups.customer_country, churn.customer_country) as customer_country,
        coalesce(active_users.acquisition_taxonomy, sign_ups.acquisition_taxonomy, churn.acquisition_taxonomy) as acquisition_taxonomy,
        active_users.active_customers,
        sign_ups.sign_ups,
        churn.churn
    from date_spine
    left join active_users
        on active_users.month = date_spine.month
    left join sign_ups 
        on date_spine.month = sign_ups.month
        and active_users.customer_country = sign_ups.customer_country
        and (active_users.acquisition_taxonomy = sign_ups.acquisition_taxonomy 
        or  (active_users.acquisition_taxonomy is null and sign_ups.acquisition_taxonomy is null))
    left join churn
        on date_spine.month = churn.month
        and active_users.customer_country = churn.customer_country
        and (active_users.acquisition_taxonomy = churn.acquisition_taxonomy
        or  (active_users.acquisition_taxonomy is null and churn.acquisition_taxonomy is null))
    order by 
        date_spine.month desc,
        customer_country
)

select * 
from final
