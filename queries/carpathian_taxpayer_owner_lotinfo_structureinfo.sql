select
  *
from property_taxpayer
  left join property_owner on property_taxpayer.apn = property_owner.apn
  left join lotinfo on lotinfo.apn = property_taxpayer.apn
  left join structure_information on structure_information.apn = property_taxpayer.apn
where
  (property_taxpayer.taxpayerLine1 LIKE '%carpath%'
    or property_taxpayer.taxpayerLine1 LIKE '%elbrus%'
    or property_taxpayer.taxpayerLine1 LIKE '%ccm%'
    or property_taxpayer.taxpayerLine1 LIKE '%ccf%'
    or property_owner.OWNER_NAME LIKE '%carpath%'
    or property_owner.OWNER_NAME LIKE '%elbrus%'
    or property_owner.OWNER_NAME LIKE '%ccm%'
    or property_owner.OWNER_NAME LIKE '%ccf%')
  order by property_taxpayer.apn
;
