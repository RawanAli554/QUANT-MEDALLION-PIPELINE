import sys
import yaml
import pyarrow.orc as orc

ARROW_TO_CLICKHOUSE = {
    "string": "String",
    "int64": "Int64",
    "int32": "Int32",
    "double": "Float64",
    "float": "Float32",
    "bool": "UInt8",
}


def infer_clickhouse_type(arrow_type: str) -> str:
    arrow_type_lower = str(arrow_type).lower()
    for key, ch_type in ARROW_TO_CLICKHOUSE.items():
        if key in arrow_type_lower:
            return ch_type
    return "String"


def generate_bronze_config(orc_file_path: str, table_name: str, bucket: str = "bronze"):
    with open(orc_file_path, "rb") as f:
        reader = orc.ORCFile(f)
        schema = reader.schema

    columns = []
    for field in schema:
        columns.append({
            "name": field.name,
            "type": infer_clickhouse_type(field.type),
        })

    config = {
        "table_name": f"bronze_{table_name}",
        "source": {
            "engine": "S3",
            "path": f"http://minio:9000/{bucket}/{table_name}/*/*/*.orc",
            "format": "ORC",
        },
        "columns": columns,
        "partitioning": {
            "organisation_id": "folder_level_1",
            "processing_date": "folder_level_2",
        },
    }
    return config


def main():
    if len(sys.argv) != 3:
        print("Usage: python schema_helper.py <path_to_orc_file> <table_name>")
        sys.exit(1)

    orc_path = sys.argv[1]
    table_name = sys.argv[2]

    config = generate_bronze_config(orc_path, table_name)
    output_path = f"config/bronze/{table_name}_auto.yaml"

    with open(output_path, "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)

    print(f"Generated Bronze config: {output_path}")
    print("---")
    print(yaml.dump(config, default_flow_style=False, sort_keys=False))


if __name__ == "__main__":
    main()
