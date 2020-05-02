import json
import csv
import urllib.parse
from datetime import datetime
import requests


def arcgis_query(offset = 0, chunk_size = 1):
    AG_RKI_SUMS_QUERY_BASE_URL = "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query?"

    params = urllib.parse.urlencode(
    {
            "where": "1=1",
            "returnGeometry": "false",
            "outFields": "*",
            "orderByFields": "Meldedatum asc",
            "resultOffset": offset,
            "resultRecordCount": chunk_size,
            "f": "json",
        }
    )

    url = f"{AG_RKI_SUMS_QUERY_BASE_URL}{params}"
    #print(url)

    resp = requests.get(url)
    resp.raise_for_status()
    data = resp.json()
    return data

data = arcgis_query()

header = data["fields"]
#cases = data["features"]

header = [h["name"] for h in header]
#print(header)

f = csv.writer(open("rki_data/RKI_COVID19.csv", "w+"))
# Write CSV Header
f.writerow(header)

def csv_add_lines(file, cases):
    for c in cases:
        row = [c["attributes"][h] for h in header]
        # convert the strange arcgis time format:
        # Meldedatum:
        row[8] = datetime.fromtimestamp(int(row[8] / 1000.0))
        # Refdatum:
        row[13] = datetime.fromtimestamp(int(row[13] / 1000.0))
        # print(row)
        file.writerow(row)

chunk_size = 2000
offset = 0
while(True):
    data = arcgis_query(offset=offset, chunk_size=chunk_size)
    cases = data["features"]
    if not cases:
        break
    csv_add_lines(f, cases)
    offset += chunk_size
