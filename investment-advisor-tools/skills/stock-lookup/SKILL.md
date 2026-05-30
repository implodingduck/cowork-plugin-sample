---
name: stock-lookup
description: |
  Looks up stock information and provides relevant data.
  Use when user asks for stock prices, company information, or market data.
license: MIT
metadata:
  author: implodingduck
  version: "1.0"
---

# Stock Lookup

## What This Skill Does

Guides Cowork through systematic stock research, identifying:
- Key financial metrics (price, volume, market cap)
- Risk factors (volatility, sector performance)
- Performance trends and comparisons
- Non-standard or unusual market behaviors

## Workflow

1. Use the `yahoo-finance-api` MCP server connector to look up the current stock information.
2. See if there are any recent events that might affect the stock's performance.

## Output Format

Present findings in an easy to consume format, such as a summary or a list of key points.