with orders as (
    select * from {{ ref('stg_orders') }}
), payments as (
    select * from {{ ref('stg_payments') }}
), customers as (
    select * from {{ ref('stg_customers') }}
), order_payments as (
    select order_id, sum(case when status = 'success' then amount end) as amount
    from payments
    group by order_id
), final as (
    select 
        orders.order_id, 
        customers.customer_id, 
        orders.order_date, 
        order_payments.amount
    from orders
    left join order_payments using (order_id)
    left join customers using (customer_id)
)
select * from final
