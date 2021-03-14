-- Top property owners who have the most properties with construction permits, broken out by lot type.
-- Filtering for permits starting 2015

select
  property_owner.OWNER_NAME as owner_name,
  lotinfo.type as lot_type,
  count(distinct permit_details.PERMIT) as permit_count,
  count(distinct lotinfo.apn) as lot_count
from permit_details
left join apn_permit_link on apn_permit_link.PERMIT = permit_details.PERMIT
left join lotinfo on lotinfo.apn = apn_permit_link.apn
left join property_owner on property_owner.apn = apn_permit_link.apn
where permit_details.issue_year >= 2015
  and property_owner.OWNER_NAME != ''
  and property_owner.OWNER_NAME IS NOT NULL
group by property_owner.OWNER_NAME, lotinfo.TYPE
order by lot_count DESC
limit 1000;
