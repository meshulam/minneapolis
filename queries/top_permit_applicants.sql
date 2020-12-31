-- Top building permit applicants (construction contractors) by lot type.
-- Filtering for permits starting 2015

select
  permit_details.APPLICATION_APPLICANT as permit_applicant,
  lotinfo.type as lot_type,
  count(distinct lotinfo.apn) as lot_count
  count(distinct permit_details.PERMIT) as permit_count
from permit_details
left join apn_permit_link on apn_permit_link.PERMIT = permit_details.PERMIT
left join lotinfo on lotinfo.apn = apn_permit_link.apn
where permit_details.issue_year >= 2015
  and lotinfo.apn IS NOT NULL
group by permit_details.APPLICATION_APPLICANT, lotinfo.TYPE
order by permit_count DESC
limit 500;
