with sales as (
    select * from {{ ref('bronze_sales') }}
),

customers as (
    select * from {{ ref('bronze_customers') }}
),

products as (
    select * from {{ ref('bronze_product') }}
),

stores as (
    select * from {{ ref('bronze_store') }}
),

dates as (
    select * from {{ ref('bronze_date') }}
),

-- one row per sale so the join below cannot duplicate sales rows
returns as (
    select
        sales_id,
        sum(returned_qty)   as returned_qty,
        sum(refund_amount)  as refund_amount
    from {{ ref('bronze_returns') }}
    group by sales_id
),

joined as (
    select
        s.sales_id,

        -- date
        d.date                  as sale_date,
        d.year,
        d.quarter,
        d.month_name,
        d.day_name,
        d.is_weekend,

        -- store
        st.store_name,
        st.city,
        st.state_province,
        st.region,
        st.country,

        -- product
        p.product_name,
        p.department,
        p.category,

        -- customer
        c.customer_code,
        c.first_name || ' ' || c.last_name as customer_name,
        c.loyalty_tier,

        -- sales measures
        s.payment_method,
        s.quantity,
        s.unit_price,
        s.gross_amount,
        s.discount_amount,
        s.net_amount,

        -- returns
        coalesce(r.returned_qty, 0)   as returned_qty,
        coalesce(r.refund_amount, 0)  as refund_amount
    from sales s
    left join dates     d  on s.date_sk     = d.date_sk
    left join stores    st on s.store_sk    = st.store_sk
    left join products  p  on s.product_sk  = p.product_sk
    left join customers c  on s.customer_sk = c.customer_sk
    left join returns   r  on s.sales_id    = r.sales_id
)

select * from joined
