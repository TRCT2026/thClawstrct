# 02 — Trading

Quantitative Trading: strategies, backtests, bots

## โครงสร้าง
- `strategies/` — Strategy logic (.py, .pine, .mq5, .md)
- `backtests/` — Equity curve, metrics, reports
- `indicators/` — Custom indicators
- `data/` — Historical OHLCV (CSV/Parquet) — **gitignore**
- `bots/` — Live execution code, exchange configs

## Risk rule (default)
- Risk per trade: **≤ 1%** of equity
- Max daily drawdown: **3%**
- Max concurrent positions: **3**
- Always set SL **before** entry

## Tools แนะนำ
- **Backtest**: `backtesting.py`, `vectorbt`, `freqtrade`
- **Live**: `ccxt` (crypto), MT5 (forex), Pine Script (TradingView)
- **Data**: `yfinance`, Binance API, Polygon.io
