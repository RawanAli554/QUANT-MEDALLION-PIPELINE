CREATE DATABASE IF NOT EXISTS quant_platform;

USE quant_platform;

CREATE TABLE IF NOT EXISTS bronze_securities
(
    security_id String,
    ticker String,
    name String,
    asset_type String,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/securities/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_market_prices
(
    security_id String,
    date String,
    open Float64,
    high Float64,
    low Float64,
    close Float64,
    volume Int64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/market_prices/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_portfolios
(
    portfolio_id String,
    portfolio_name String,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/portfolios/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_positions
(
    position_id String,
    portfolio_id String,
    security_id String,
    quantity Int64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/positions/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_trades
(
    trade_id String,
    security_id String,
    portfolio_id String,
    side String,
    quantity Int64,
    price Float64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/trades/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_risk_metrics
(
    metric_id String,
    portfolio_id String,
    var_95 Float64,
    sharpe_ratio Float64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/risk_metrics/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_factor_exposures
(
    exposure_id String,
    security_id String,
    value_factor Float64,
    momentum_factor Float64,
    size_factor Float64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/factor_exposures/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_strategies
(
    strategy_id String,
    strategy_name String,
    strategy_type String,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/strategies/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_signals
(
    signal_id String,
    strategy_id String,
    security_id String,
    signal_strength Float64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/signals/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');

CREATE TABLE IF NOT EXISTS bronze_backtests
(
    backtest_id String,
    strategy_id String,
    total_return Float64,
    max_drawdown Float64,
    organisation_id String,
    processing_date String
)
ENGINE = S3('http://minio:9000/bronze/backtests/*/*/data.orc', 'minioadmin', 'minioadmin', 'ORC');
