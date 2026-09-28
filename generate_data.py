import os
import random
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
import pyarrow as pa
import pyarrow.orc as orc
from faker import Faker

fake = Faker()
random.seed(42)
Faker.seed(42)

ORGS = ["org_001", "org_002", "org_003"]
DATES = [(datetime(2026, 8, 20) + timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7)]
OUTPUT_ROOT = Path("data/minio_bucket")

ASSET_TYPES = ["equity", "bond", "etf", "future"]
STRATEGY_TYPES = ["momentum", "value", "mean_reversion", "factor"]


def write_orc(df: pd.DataFrame, table: str, org: str, date: str):
    out_dir = OUTPUT_ROOT / "bronze" / table / org / date
    out_dir.mkdir(parents=True, exist_ok=True)
    table_arrow = pa.Table.from_pandas(df)
    orc.write_table(table_arrow, out_dir / "data.orc")


def gen_securities(org, date, n=20):
    rows = []
    for i in range(n):
        rows.append({
            "security_id": f"SEC_{org}_{i:04d}",
            "ticker": fake.lexify(text="????").upper(),
            "name": fake.company(),
            "asset_type": random.choice(ASSET_TYPES),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_market_prices(org, date, n=20):
    rows = []
    for i in range(n):
        open_p = round(random.uniform(10, 500), 2)
        rows.append({
            "security_id": f"SEC_{org}_{i:04d}",
            "date": date,
            "open": open_p,
            "high": round(open_p * random.uniform(1.0, 1.05), 2),
            "low": round(open_p * random.uniform(0.95, 1.0), 2),
            "close": round(open_p * random.uniform(0.97, 1.03), 2),
            "volume": random.randint(1000, 1000000),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_portfolios(org, date, n=5):
    rows = []
    for i in range(n):
        rows.append({
            "portfolio_id": f"PORT_{org}_{i:03d}",
            "portfolio_name": f"{fake.word().capitalize()} Fund",
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_positions(org, date, n=15):
    rows = []
    for i in range(n):
        rows.append({
            "position_id": f"POS_{org}_{i:04d}",
            "portfolio_id": f"PORT_{org}_{i % 5:03d}",
            "security_id": f"SEC_{org}_{i % 20:04d}",
            "quantity": random.randint(10, 5000),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_trades(org, date, n=25):
    rows = []
    for i in range(n):
        rows.append({
            "trade_id": f"TRD_{org}_{date}_{i:04d}",
            "security_id": f"SEC_{org}_{i % 20:04d}",
            "portfolio_id": f"PORT_{org}_{i % 5:03d}",
            "side": random.choice(["buy", "sell"]),
            "quantity": random.randint(1, 1000),
            "price": round(random.uniform(10, 500), 2),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_risk_metrics(org, date, n=5):
    rows = []
    for i in range(n):
        rows.append({
            "metric_id": f"RISK_{org}_{date}_{i:03d}",
            "portfolio_id": f"PORT_{org}_{i:03d}",
            "var_95": round(random.uniform(0.01, 0.1), 4),
            "sharpe_ratio": round(random.uniform(-1, 3), 2),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_factor_exposures(org, date, n=20):
    rows = []
    for i in range(n):
        rows.append({
            "exposure_id": f"EXP_{org}_{i:04d}",
            "security_id": f"SEC_{org}_{i:04d}",
            "value_factor": round(random.uniform(-2, 2), 3),
            "momentum_factor": round(random.uniform(-2, 2), 3),
            "size_factor": round(random.uniform(-2, 2), 3),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_strategies(org, date, n=4):
    rows = []
    for i in range(n):
        rows.append({
            "strategy_id": f"STRAT_{org}_{i:03d}",
            "strategy_name": f"{random.choice(STRATEGY_TYPES)}_{i}",
            "strategy_type": random.choice(STRATEGY_TYPES),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_signals(org, date, n=10):
    rows = []
    for i in range(n):
        rows.append({
            "signal_id": f"SIG_{org}_{date}_{i:04d}",
            "strategy_id": f"STRAT_{org}_{i % 4:03d}",
            "security_id": f"SEC_{org}_{i % 20:04d}",
            "signal_strength": round(random.uniform(-1, 1), 3),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


def gen_backtests(org, date, n=3):
    rows = []
    for i in range(n):
        rows.append({
            "backtest_id": f"BT_{org}_{date}_{i:03d}",
            "strategy_id": f"STRAT_{org}_{i % 4:03d}",
            "total_return": round(random.uniform(-0.3, 0.5), 4),
            "max_drawdown": round(random.uniform(-0.4, -0.01), 4),
            "organisation_id": org,
            "processing_date": date,
        })
    return pd.DataFrame(rows)


GENERATORS = {
    "securities": gen_securities,
    "market_prices": gen_market_prices,
    "portfolios": gen_portfolios,
    "positions": gen_positions,
    "trades": gen_trades,
    "risk_metrics": gen_risk_metrics,
    "factor_exposures": gen_factor_exposures,
    "strategies": gen_strategies,
    "signals": gen_signals,
    "backtests": gen_backtests,
}


def main():
    print(f"Generating data for {len(GENERATORS)} tables x {len(ORGS)} orgs x {len(DATES)} dates...")
    for table_name, gen_func in GENERATORS.items():
        for org in ORGS:
            for date in DATES:
                df = gen_func(org, date)
                write_orc(df, table_name, org, date)
        print(f"  done: {table_name}")
    print(f"\nDone. Files written under: {OUTPUT_ROOT.resolve()}")


if __name__ == "__main__":
    main()
