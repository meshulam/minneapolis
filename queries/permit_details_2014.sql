select
  apn_permit_link.apn,
  parcels_2020.FORMATTED_ADDRESS,
  permit_details.*
from permit_details
left join apn_permit_link on apn_permit_link.PERMIT = permit_details.PERMIT
left join parcels_2020 on parcels_2020.APN = apn_permit_link.apn
where
  permit_details.ISSUE_DATE between "2014-01-01" and "2014-12-31"
order by permit_details.ISSUE_DATE;
