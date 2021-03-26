WITH flips AS (
  SELECT
    bought.apn as apn,
    parcels_2020.FORMATTED_ADDRESS as address,
    parcels_2020.LANDUSE as land_use_in_2020,
    bought.sale_date as purchased_date,
    sold.sale_date as sold_date,
    bought.SALES_BUYERNAME as purchased_buyer_name,
    sold.SALES_SELLERNAME as sold_seller_name,
    bought.SALES_PRICE as purchased_price,
    sold.SALES_PRICE as sold_price,
    julianday(sold.sale_date) - julianday(bought.sale_date) as days_held
  FROM sale_history bought
  LEFT JOIN sale_history sold ON bought.apn = sold.apn
    AND bought.sale_date < sold.sale_date
    AND julianday(sold.sale_date) - julianday(bought.sale_date) < 540
  LEFT JOIN parcels_2020 ON bought.apn = parcels_2020.apn
  WHERE sold.sale_date > "2014-01-01"
)
SELECT
  flips.*,
  count(distinct permit_details.PERMIT) as permit_count,
  group_concat(distinct permit_details.APPLICATION_APPLICANT) as permit_applicants,
  group_concat(distinct permit_details.TYPE) as permit_types
FROM flips
LEFT JOIN apn_permit_link ON flips.apn = apn_permit_link.apn
LEFT JOIN permit_details ON apn_permit_link.PERMIT = permit_details.PERMIT
  AND permit_details.ISSUE_DATE BETWEEN flips.purchased_date AND flips.sold_date
GROUP BY flips.apn, flips.purchased_date, flips.sold_date
ORDER BY flips.sold_date
