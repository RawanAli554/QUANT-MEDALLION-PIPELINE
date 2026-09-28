USE quant_platform;

CREATE TABLE IF NOT EXISTS silver_securities
(
    security_id String,
    ticker String,
    name String,
    asset_type String,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, security_id, processing_date);

INSERT INTO silver_securities (security_id, ticker, name, asset_type, organisation_id, processing_date)
SELECT security_id, ticker, name, asset_type, organisation_id, processing_date
FROM bronze_securities;

CREATE TABLE IF NOT EXISTS silver_market_prices
(
    security_id String,
    date String,
    open Float64,
    high Float64,
    low Float64,
    close Float64,
    volume Int64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, security_id, processing_date);

INSERT INTO silver_market_prices (security_id, date, open, high, low, close, volume, organisation_id, processing_date)
SELECT security_id, date, open, high, low, close, volume, organisation_id, processing_date
FROM bronze_market_prices;

CREATE TABLE IF NOT EXISTS silver_portfolios
(
    portfolio_id String,
    portfolio_name String,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, portfolio_id, processing_date);

INSERT INTO silver_portfolios (portfolio_id, portfolio_name, organisation_id, processing_date)
SELECT portfolio_id, portfolio_name, organisation_id, processing_date
FROM bronze_portfolios;

CREATE TABLE IF NOT EXISTS silver_positions
(
    position_id String,
    portfolio_id String,
    security_id String,
    quantity Int64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, position_id, processing_date);

INSERT INTO silver_positions (position_id, portfolio_id, security_id, quantity, organisation_id, processing_date)
SELECT position_id, portfolio_id, security_id, quantity, organisation_id, processing_date
FROM bronze_positions;

CREATE TABLE IF NOT EXISTS silver_trades
(
    trade_id String,
    security_id String,
    portfolio_id String,
    side String,
    quantity Int64,
    price Float64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, trade_id, processing_date);

INSERT INTO silver_trades (trade_id, security_id, portfolio_id, side, quantity, price, organisation_id, processing_date)
SELECT trade_id, security_id, portfolio_id, side, quantity, price, organisation_id, processing_date
FROM bronze_trades;

CREATE TABLE IF NOT EXISTS silver_risk_metrics
(
    metric_id String,
    portfolio_id String,
    var_95 Float64,
    sharpe_ratio Float64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, metric_id, processing_date);

INSERT INTO silver_risk_metrics (metric_id, portfolio_id, var_95, sharpe_ratio, organisation_id, processing_date)
SELECT metric_id, portfolio_id, var_95, sharpe_ratio, organisation_id, processing_date
FROM bronze_risk_metrics;

CREATE TABLE IF NOT EXISTS silver_factor_exposures
(
    exposure_id String,
    security_id String,
    value_factor Float64,
    momentum_factor Float64,
    size_factor Float64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, exposure_id, processing_date);

INSERT INTO silver_factor_exposures (exposure_id, security_id, value_factor, momentum_factor, size_factor, organisation_id, processing_date)
SELECT exposure_id, security_id, value_factor, momentum_factor, size_factor, organisation_id, processing_date
FROM bronze_factor_exposures;

CREATE TABLE IF NOT EXISTS silver_strategies
(
    strategy_id String,
    strategy_name String,
    strategy_type String,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, strategy_id, processing_date);

INSERT INTO silver_strategies (strategy_id, strategy_name, strategy_type, organisation_id, processing_date)
SELECT strategy_id, strategy_name, strategy_type, organisation_id, processing_date
FROM bronze_strategies;

CREATE TABLE IF NOT EXISTS silver_signals
(
    signal_id String,
    strategy_id String,
    security_id String,
    signal_strength Float64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, signal_id, processing_date);

INSERT INTO silver_signals (signal_id, strategy_id, security_id, signal_strength, organisation_id, processing_date)
SELECT signal_id, strategy_id, security_id, signal_strength, organisation_id, processing_date
FROM bronze_signals;

CREATE TABLE IF NOT EXISTS silver_backtests
(
    backtest_id String,
    strategy_id String,
    total_return Float64,
    max_drawdown Float64,
    organisation_id String,
    processing_date String,
    ingested_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(ingested_at)
ORDER BY (organisation_id, backtest_id, processing_date);

INSERT INTO silver_backtests (backtest_id, strategy_id, total_return, max_drawdown, organisation_id, processing_date)
SELECT backtest_id, strategy_id, total_return, max_drawdown, organisation_id, processing_date
FROM bronze_backtests;
