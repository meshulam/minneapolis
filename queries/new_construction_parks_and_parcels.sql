SELECT
  parcels_2020.apn,
  parcels_2020.FORMATTED_ADDRESS as parcels_address,
  parcels_2020.YEARBUILT as parcels_year_built,
  parcels_2020.PROPERTY_TYPE as parcels_property_type,
  parcels_2020.TOTAL_UNITS as parcels_total_units,
  new_units.address as parks_address,
  new_units.issue_date as parks_issue_date,
  inferred_commercial_units as parks_commercial_units_estimate,
  inferred_housing_units as parks_residential_units_estimate
	
from parcels_2020
left join new_units on new_units.apn = parcels_2020.apn
where parcels_2020.YEARBUILT > 2013
or new_units.issue_date is not NULL
union

-- sqlite doesn't support outer joins so use union with a separate query to get the new_units rows that don't match a parcels_2020 row
select
  new_units.apn,
  parcels_2020.FORMATTED_ADDRESS as parcels_address,
  parcels_2020.YEARBUILT as parcels_year_built,
  parcels_2020.PROPERTY_TYPE as parcels_property_type,
  parcels_2020.TOTAL_UNITS as parcels_total_units,
  new_units.address as parks_address,
  new_units.issue_date as parks_issue_date,
  inferred_commercial_units as parks_commercial_units_estimate,
  inferred_housing_units as parks_residential_units_estimate
 from new_units
 left join parcels_2020 on new_units.apn = parcels_2020.apn
 where parcels_2020.FORMATTED_ADDRESS is NULL