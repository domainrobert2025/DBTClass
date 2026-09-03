{{
    config (
          materialized = 'table'
    )
}}

with customers as (
    select * from {{ source('jaffle_shop', 'customers') }}
),
orders as (
    select * from {{ source('jaffle_shop', 'orders') }}
),
payments as (
    select * from {{ source('stripe', 'payment') }}
),
customer_orders as (
    select
        o.user_id as customer_id,
        min(o.order_date) as first_order_date,
        max(o.order_date) as most_recent_order_date,
        count(o.id) as number_of_orders,
        sum(p.amount) as lifetime_value
    from orders o
    left join payments p
        on o.id = p.order_id
    group by o.user_id
)

select
    c.id as customer_id,
    c.first_name,
    c.last_name,
    co.first_order_date,
    co.most_recent_order_date,
    co.number_of_orders,
    co.lifetime_value
from customers c
left join customer_orders co
    on c.id = co.customer_id

select * from final