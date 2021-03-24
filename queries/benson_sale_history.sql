select
  sale_history.*,
  parcels_2020.*
from sale_history
  left join parcels_2020 on sale_history.apn = parcels_2020.APN
where
  (SALES_SELLERNAME LIKE '%BENSON%ORTH%'
    or SALES_BUYERNAME LIKE '%BENSON%ORTH%')
;
