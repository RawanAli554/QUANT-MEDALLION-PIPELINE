USE quant_platform;

-- ==========================================================
-- Gold Table 1: Portfolio Daily Value
-- Engine: SummingMergeTree
-- Why: We're summing numeric columns (total quantity * price)
-- per (org, portfolio, date). SummingMergeTree auto-merges rows
-- with the same ORDER BY key by summing numeric columns —
-- exactly what a daily portfolio value rollup needs.
-- ==========================================================
CREATE TABLE IF NOT EXISTS gold_portfolio_daily_value
(
    organisation_id String,
    portfolio_id String,
    processing_date String,
    total_position_value Float64
)
ENGINE = SummingMergeTree(total_position_value)
ORDER BY (organisation_id, portfolio_id, processing_date);

INSERT INTO gold_portfolio_daily_value
SELECT
    p.organisation_id,
    p.portfolio_id,
    p.processing_date,
    sum(p.quantity * COALESCE(mp.close, 0)) AS total_position_value
FROM silver_positions p
LEFT JOIN silver_market_prices mp
    ON p.security_id = mp.security_id
    AND p.organisation_id = mp.organisation_id
    AND p.processing_date = mp.processing_date
GROUP BY p.organisation_id, p.portfolio_id, p.processing_date;

-- ==========================================================
-- Gold Table 2: Strategy Performance Summary
-- Engine: AggregatingMergeTree
-- Why: We need averages (avg return, avg drawdown) across
-- backtest runs, not simple sums. AggregatingMergeTree with
-- -State/-Merge combinators handles correct incremental
-- averaging, unlike SummingMergeTree which can only sum.
-- ==========================================================
CREATE TABLE IF NOT EXISTS gold_strategy_performance
(
    organisation_id String,
    strategy_id String,
    avg_return_state AggregateFunction(avg, Float64),
    avg_drawdown_state AggregateFunction(avg, Float64),
    backtest_count_state AggregateFunction(count)
)
ENGINE = AggregatingMergeTree()
ORDER BY (organisation_id, strategy_id);

INSERT INTO gold_strategy_performance
SELECT
    organisation_id,
    strategy_id,
    avgState(total_return) AS avg_return_state,
    avgState(max_drawdown) AS avg_drawdown_state,
    countState() AS backtest_count_state
FROM silver_backtests
GROUP BY organisation_id, strategy_id;

-- ==========================================================
-- Gold Table 3: Organisation Trading Activity
-- Engine: SummingMergeTree
-- Why: Simple daily counts and volume sums per org — a plain
-- additive rollup, so SummingMergeTree is the lightest-weight
-- correct choice (no need for AggregatingMergeTree's overhead).
-- ==========================================================
CREATE TABLE IF NOT EXISTS gold_org_trading_activity
(
    organisation_id String,
    processing_date String,
    trade_count UInt64,
    total_volume Int64
)
ENGINE = SummingMergeTree((trade_count, total_volume))
ORDER BY (organisation_id, processing_date);

INSERT INTO gold_org_trading_activity
SELECT
    organisation_id,
    processing_date,
    count() AS trade_count,
    sum(quantity) AS total_volume
FROM silver_trades
GROUP BY organisation_id, processing_date;
