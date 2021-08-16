--№1

select v.vendor_name              as vendor,
       count(distinct o.order_id) as number_of_orders
from orders o
         left join vendors v on o.vendor_id = v.vendor_id
where (date_trunc('month', o.order_date) = --to_timestamp(o.order_date) если всё же не timestamp
       date_trunc('month', (select current_timestamp))) -- если имеется в виду календарный месяц
--where o.order_date > current_timestamp - interval '1' month  -- если имеется в виду 1 месяц (30 дней) до текущей даты
group by v.vendor_name
order by number_of_orders desc limit 10;

---------------------------------------------------------------------------------------------
--№2

select v.vendor_name              as vendor,
       count(distinct o.order_id) as number_of_orders
from orders o
         left join vendors v on o.vendor_id = v.vendor_id
group by v.vendor_name

---------------------------------------------------------------------------------------------
--№3

    with kfc as (
     select o.user_id                as user_id,
            count(distinct order_id) as kfc_orders

     from orders o
              left join vendors v
                        on o.vendor_id = v.vendor_id
     where ((date_trunc('month', o.order_date) =
            date_trunc('month', (select current_timestamp)))        -- если имеется в виду календарный месяц
     --where o.order_date > current_timestamp - interval '1' month  -- если имеется в виду 1 месяц до данного дня
            and v.vendor_name = 'KFC')
     group by user_id
 )
select distinct o.user_id
from orders o
         left join kfc on o.user_id = kfc.user_id
where kfc.kfc_orders IS NULL


---------------------------------------------------------------------------------------------
--№4

select *
from (
         select order_month as month_rating,
                vendor_name,
                row_number()   over (partition by order_month order by orders desc) as vendor_rank
         from (
                  select v.vendor_name                     as vendor_name,
                         date_trunc('month', o.order_date) as order_month,
                         count(distinct order_id)          as orders

                  from orders o
                           left join vendors v
                                     on o.vendor_id = v.vendor_id
                  where date_trunc('month', o.order_date) > date_trunc('month', current_timestamp - interval '1' year)
                  group by order_month, vendor_name
              ) rr
     ) tt
where vendor_rank <= 3


---------------------------------------------------------------------------------------------
--№5

    with fees as(
    select  o.user_id as user_id,
            o.order_id as order_id,
            o.products_sum * v.take_rate as fee

    from orders o
         left join vendors v on o.vendor_id = v.vendor_id
    order by o.user_id asc
),
    revenues as (
        select distinct user_id                                         as user_id,
               sum(fee) over (partition by user_id)                     as revenue,
               sum(fee) over ()                                         as total_revenue,
               sum(fee) over (partition by user_id) / sum(fee) over ()  as frac
        from fees
    )
select user_id,
       revenue,
       total_revenue,
       to_char(100 * frac, '99.9%')                               as share,
       to_char(100 * sum(frac) over(order by user_id), '999.99%') as cumulative_share
from revenues
