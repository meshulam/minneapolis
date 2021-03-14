select
  permit_details.PERMIT,
  permit_details.pid,
  parcels_2020.*
from permit_details
left join apn_permit_link on apn_permit_link.PERMIT = permit_details.PERMIT
left join parcels_2020 on parcels_2020.APN = apn_permit_link.apn
where
  permit_details.APPLICATION_APPLICANT LIKE '%BENSON%ORTH%';
