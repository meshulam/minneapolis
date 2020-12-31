#!/usr/bin/env python3

import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile

DATA_DIR = os.path.abspath('./data/csv')
ZIP_FILE = os.path.abspath('./data/FullPIRequest.zip')
DATABASE_FILE = os.path.abspath('./data/minneapolis.db')

def mkdir_p_and_empty(d):
    if os.path.isdir(d):
        shutil.rmtree(d)
    os.makedirs(d)

def run(cmd):
    subprocess.run(cmd, shell=True, check=True)

def unzip():
    temp_dir = tempfile.mkdtemp()
    mkdir_p_and_empty(DATA_DIR)

    run(f"unzip {ZIP_FILE} -d {temp_dir}")

    for filename in glob.glob(os.path.join(temp_dir, '*.txt')):
        print(f"processing {os.path.basename(filename)}")
        destination = os.path.join(DATA_DIR, os.path.basename(filename))
        run(f"iconv -f ISO-8859-1 -t UTF-8 < {filename} > {destination}")
        run(f"sed -i 's/\"//g' {destination}")

    shutil.rmtree(temp_dir)

# Some tables have multiple identical rows, remove them before importing
def dedupe_rows(filename):
    file_path = os.path.join(DATA_DIR, filename)
    temp_path = f"{file_path}-temp"

    run(f"sort {file_path} | uniq > {temp_path}")
    run(f"mv {temp_path} {file_path}")

# fix broken lines in Property Owners:
# They are errors that invalidate the csvs, found via trial and error
def fix_property_owners_file():
    f = os.path.join(DATA_DIR, 'PropertyOwner.txt')

    contents = open(f).read()
    contents = re.sub(r'\|[ ]*\n\n', '|', contents)
    contents = contents.replace('|  \nArtspace', '|Artspace')

    with open(f, 'w') as file:
        file.write(contents)


def create_database():
    sql = """
CREATE TABLE lotinfo(
  "apn" TEXT PRIMARY KEY,
  "ASSESSOR_USE" TEXT,
  "TYPE" TEXT,
  "LOTSIZE" INTEGER,
  "lotDepth" INTEGER,
  "lotFrontage" TEXT,
  "PARCEL_BLOCK" TEXT,
  "PARCEL_LOT" TEXT,
  "PARCEL_ADDITION" TEXT,
  "ASSESSOR_FNAME" TEXT,
  "ASSESSOR_EXTENSION" TEXT,
  "RelativeHomestead" TEXT
);

CREATE TABLE structure_information(
  "apn" TEXT,
  "CONCAT_ADDRESS" TEXT,
  "UNIT_COUNT" INTEGER,
  "building_parkspaces" TEXT,
  "TOTAL_BEDROOMS" INTEGER,
  "TOTAL_BATHS" INTEGER,
  "BUILD_DATE" TEXT,
  "ONE_BEDROOM" TEXT,
  "TWO_BEDROOM" TEXT,
  "THREE_BEDROOM" TEXT,
  "FOUR_BEDROOM" TEXT,
  "EFFICIENCY" TEXT,
  "STORIES" INTEGER,
  "SECOND_FLOOR_AREA" INTEGER,
  "BASEMENT_AREA" INTEGER,
  "FINISHED_BASEMENT_AREA" INTEGER,
  "GROSS_BUILDING_AREA" INTEGER,
  "ABOVEGRADEAREA" INTEGER,
  "GROUND_FLOOR_AREA" INTEGER,
  "BUILDINGCODE" TEXT
);
CREATE TABLE zones(
  "apn" TEXT,
  "ZONE_CODE" TEXT,
  "ZONE_DESC" TEXT,
  "zoneType" TEXT
);

CREATE TABLE property_owner(
  "apn" TEXT,
  "OWNER_NAME" TEXT,
  "OWNER_STREETADDRESS" TEXT,
  "OWNER_ADDRESS" TEXT
);
CREATE INDEX idx_property_owner_apn ON property_owner(apn);

CREATE TABLE property_taxpayer(
  "apn" TEXT,
  "taxpayerLine1" TEXT,
  "taxpayerLine2" TEXT,
  "taxpayerLine3" TEXT,
  "taxpayerLine4" TEXT
);
CREATE INDEX idx_property_taxpayer_apn ON property_taxpayer(apn);

CREATE TABLE permit_details(
  "pid" TEXT,
  "PERMIT" TEXT PRIMARY KEY,
  "ISSUE_YEAR" TEXT,
  "ISSUE_DATE" TEXT,
  "TYPE" TEXT,
  "TYPE_DESCRIPTION" TEXT,
  "STATUS_P" TEXT,
  "VALUATION_ESTIMATE" NUMERIC,
  "APPLICATION_APPLICANT" TEXT,
  "PER_COMPL_DATE" TEXT,
  "SUM_FEE_PAYMENT" TEXT
);

CREATE TABLE sale_history(
  "apn" TEXT,
  "SALES_SELLERNAME" TEXT,
  "SALES_BUYERNAME" TEXT,
  "SALES_PRICE" INTEGER,
  "sale_date" TEXT
);

CREATE TABLE rental_history(
  "apn" TEXT,
  "KEY_" TEXT,
  "PERTYPE" TEXT,
  "PERDESC" TEXT,
  "ISSUE_DATE" TEXT,
  "CONTACT_NAME" TEXT,
  "CONTACT_ADDRESS1" TEXT,
  "CONTACT_ADDRESS2" TEXT,
  "CONTACT_CITY" TEXT,
  "CONTACT_STATE" TEXT,
  "CONTACT_ZIP" TEXT,
  "CONTACT_PHONE" TEXT,
  "paymentDate" TEXT,
  "paymentAmount" NUMERIC,
  "tierCode" TEXT
);

CREATE TABLE valuation_history(
  "apn" TEXT,
  "YEAR" TEXT,
  "EXEMPTIONS_HOMESTEADPERCENT" TEXT,
  "EXEMPTIONS_EXEMPTTYPE" TEXT,
  "TOH" TEXT,
  "STRUCTURE_BUILDINGVALUE" NUMERIC,
  "STRUCTURE_LANDVALUE" NUMERIC,
  "STRUCTURE_MACHINEVALUE" NUMERIC,
  "STRUCTURE_TOTALVALUE" NUMERIC,
  "TAXABLE_VALUE" NUMERIC
);

CREATE TABLE apn_permit_link(
  "apn" TEXT,
  "PERMIT" TEXT
);
CREATE INDEX idx_apn_permit_link_apn ON apn_permit_link(apn);
CREATE INDEX idx_apn_permit_link_permit ON apn_permit_link(PERMIT);

CREATE TABLE new_units(
  "apn" TEXT,
  "issue_date" TEXT,
  "address" TEXT,
  "park_fee" NUMERIC,
  "inferred_building_type" TEXT,
  "inferred_housing_units" TEXT,
  "inferred_commercial_units" TEXT,
  "owner" TEXT
);

.mode csv
.separator "|"

.import data/csv/LotInfo.txt lotinfo
.import data/csv/StructureInformation.txt structure_information
.import data/csv/Zones.txt zones
.import data/csv/PropertyOwner.txt property_owner
.import data/csv/PropertyTaxpayer.txt property_taxpayer
.import data/csv/PermitDetails.txt permit_details
.import data/csv/SaleHistory.txt sale_history
.import data/csv/RentalHistory.txt rental_history
.import data/csv/ValuationHistory.txt valuation_history
.import data/APN_Permit_Link.txt apn_permit_link

.separator ","
.import data/new_units.csv new_units


-- Missing sales price fields loaded as empty strings
UPDATE sale_history SET SALES_PRICE = null WHERE SALES_PRICE = '';
"""
    subprocess.run(f"sqlite3 {DATABASE_FILE}", shell=True, check=True, input=sql, text=True)

if __name__ == '__main__':
    if os.path.isfile(DATABASE_FILE):
        print(f"{DATABASE_FILE} exists. Please delete before running.", file=sys.stderr)
        sys.exit(1)

    unzip()
    fix_property_owners_file()
    dedupe_rows("PermitDetails.txt")
    dedupe_rows("LotInfo.txt")
    create_database()
