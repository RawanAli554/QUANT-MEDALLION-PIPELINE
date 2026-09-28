# Quant Finance Medallion Pipeline

A Bronze - Silver - Gold data pipeline for quantitative finance data, built with ClickHouse and MinIO.

## What this is

Raw synthetic files go into MinIO storage. ClickHouse reads them into Bronze tables. Bronze gets cleaned and deduplicated into Silver. Silver gets aggregated into Gold tables for analytics.

## Stack

MinIO for object storage
ClickHouse for Bronze, Silver and Gold tables
Python for generating data, uploading to MinIO, and reading schemas

Airflow was left out to focus the available time on the core pipeline logic instead.

## Tables

securities, market_prices, portfolios, positions, trades, risk_metrics, factor_exposures, strategies, signals, backtests

Covers 3 fake organisations across 7 dates.

## How to run it

1. docker compose up -d
2. python3 data/generator/generate_data.py
3. python3 data/generator/upload_to_minio.py
4. Run the Bronze SQL file in config/bronze
5. Run the Silver SQL file in config/silver
6. Run the Gold SQL file in config/gold

## Multi tenant proof

The same security_id was seeded under two different organisations with different names. After going through Silver, both rows stay separate instead of getting merged. This shows data from different organisations never mixes together.

## Schema helper

data/generator/schema_helper.py reads any raw file and generates a draft Bronze config automatically, instead of writing it by hand.

## Gold tables and why

gold_portfolio_daily_value uses SummingMergeTree because it just needs to sum position values

gold_strategy_performance uses AggregatingMergeTree because it needs correct averages, not just sums

gold_org_trading_activity uses SummingMergeTree because it is a simple count and volume per day

All three are grouped by organisation_id so tenant data stays separated at the analytics layer too.
