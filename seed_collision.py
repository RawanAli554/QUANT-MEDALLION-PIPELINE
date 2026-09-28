from pathlib import Path
import pandas as pd
import pyarrow as pa
import pyarrow.orc as orc

OUTPUT_ROOT = Path("data/minio_bucket")

def write_orc(df, table, org, date):
    out_dir = OUTPUT_ROOT / "bronze" / table / org / date
    out_dir.mkdir(parents=True, exist_ok=True)
    t = pa.Table.from_pandas(df)
    orc.write_table(t, out_dir / "collision.orc")

date = "2026-08-20"
shared_id = "SEC_SHARED_COLLISION_001"

for org, name in [("org_001", "Alpha Corp (org_001 version)"), ("org_002", "Beta Corp (org_002 version)")]:
    df = pd.DataFrame([{
        "security_id": shared_id,
        "ticker": "COLL",
        "name": name,
        "asset_type": "equity",
        "organisation_id": org,
        "processing_date": date,
    }])
    write_orc(df, "securities", org, date)

print(f"Seeded collision for security_id={shared_id} in org_001 and org_002 on {date}")
