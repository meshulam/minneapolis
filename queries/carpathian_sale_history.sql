select
  sale_history.*,
  parcels_2020.*
from sale_history
  left join parcels_2020 on sale_history.apn = parcels_2020.APN
where
  (SALES_SELLERNAME LIKE '%carpathian%'
    or SALES_SELLERNAME LIKE '%elbrus%'
    or SALES_SELLERNAME LIKE '%ccm%'
    or SALES_SELLERNAME LIKE '%ccf%'
    or SALES_BUYERNAME LIKE '%carpathian%'
    or SALES_BUYERNAME LIKE '%elbrus%'
    or SALES_BUYERNAME LIKE '%ccm%'
    or SALES_BUYERNAME LIKE '%ccf%')
;
