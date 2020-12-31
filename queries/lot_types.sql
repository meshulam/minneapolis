select
  TYPE,
  ASSESSOR_USE,
  COUNT(apn)
from lotinfo
group by TYPE, ASSESSOR_USE;
