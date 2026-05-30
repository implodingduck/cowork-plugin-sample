---
name: investment-advisor-copilot
description: |
  Connects to the Investment Advisor Copilot Foundry agent for portfolio analysis
  and macro/markets strategy. Use when the user asks about investment portfolios,
  asset allocation, geopolitical scenario analysis, cross-asset impact assessments,
  or ETF-level strategic recommendations.
license: MIT
metadata:
  author: implodingduck
  version: "1.0"
---

# Investment Advisor Copilot

## What This Skill Does

Delegates financial analysis tasks to the **investment-advisor-copilot** Foundry agent via the `foundry-mcp` MCP server connector. The Foundry agent serves two complementary roles:

1. **Portfolio Advisor** — Helps financial advisors understand and optimize their clients' investment portfolios.
2. **Macro & Markets Strategist** — Provides institutional-grade geopolitical scenario analysis, cross-asset impact assessments, and ETF-level strategic recommendations.

## Workflow

1. Use the `foundry-mcp` MCP server connector to invoke the **investment-advisor-copilot** Foundry agent.
2. Pass the user's question or request to the agent as-is, preserving full context.
3. Return the agent's response to the user, maintaining the original formatting and detail.

## When to Use

- Portfolio review, optimization, or rebalancing questions
- Asset allocation analysis
- Geopolitical risk and scenario analysis
- Cross-asset impact assessments
- ETF screening and strategic recommendations
- Market outlook and macro strategy discussions

## Output Format

Present the Foundry agent's response directly. Preserve any tables, lists, or structured data returned by the agent.