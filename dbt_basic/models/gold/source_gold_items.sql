with dedup_query as(
select *,
row_number() over(partition by id order by updated_date desc) as dedup
 from {{ source('source', 'items') }}
)
select id,name,catogory,updated_date from dedup_query
where dedup = 1