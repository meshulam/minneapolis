select
  parcels_2020.APN,
  parcels_2020.FORMATTED_ADDRESS,
  permit_details.*
from parcels_2020
  left join apn_permit_link on apn_permit_link.apn = parcels_2020.APN
  left join permit_details on apn_permit_link.PERMIT = permit_details.PERMIT
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
