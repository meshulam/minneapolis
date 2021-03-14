select
  permit_details.PERMIT,
  permit_details.pid,
  lotinfo.*
from permit_details
left join apn_permit_link on apn_permit_link.PERMIT = permit_details.PERMIT
left join lotinfo on lotinfo.apn = apn_permit_link.apn
where
  permit_details.APPLICATION_APPLICANT LIKE '%BENSON%ORTH%';
