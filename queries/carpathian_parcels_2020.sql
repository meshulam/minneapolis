select
  parcels_2020.*
from parcels_2020
where
  (OWNERNAME LIKE '%carpathian%'
    or OWNERNAME LIKE '%elbrus%'
    or OWNERNAME LIKE '%ccm%'
    or OWNERNAME LIKE '%ccf%'
    or TAXPAYER1 LIKE '%carpathian%'
    or TAXPAYER1 LIKE '%elbrus%'
    or TAXPAYER1 LIKE '%ccm%'
    or TAXPAYER1 LIKE '%ccf%')
;
