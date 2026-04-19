# F1 World Championship Analytics — SQL

**Tools:** PostgreSQL, pgAdmin  
**Dataset:** Formula 1 World Championship 1950–2024 (Kaggle)  

---

## Overview

A collection of SQL queries analysing 75 years of Formula 1 data across 1,125 races and 26,759 race results. The project covers driver performance, constructor dominance, season standings and head to head comparisons using PostgreSQL.

---

## Skills Demonstrated

- Joins across multiple tables
- Aggregations — COUNT, SUM, AVG, ROUND
- GROUP BY, HAVING, ORDER BY
- CASE WHEN for conditional logic
- Window functions — RANK, DENSE_RANK, LAG
- CTEs (Common Table Expressions)
- Subquery chaining

---

## Queries Overview

| # | Query | Description |
|---|---|---|
| 1-4 | Database Setup | Create tables for drivers, races, constructors, results |
| 5-6 | Basic Exploration | Row counts, driver lookup |
| 7 | Most Race Entries | Drivers with 100+ race starts |
| 8 | Top Points Scorers | All time points leaders |
| 9 | Most Race Wins | All time win leaders |
| 10 | Win Rate Analysis | Win percentage per driver (min 10 races) |
| 11 | Season Standings | Championship rankings per season using RANK |
| 12 | Season + LAG | Season standings with previous year comparison |
| 13 | Hamilton Career | Season by season points and ranking |
| 14 | Constructor Wins | All time wins by team |
| 15 | Constructor by Era | Dominant team per regulation era |
| 16 | Hamilton vs Verstappen | Head to head career comparison |

---

## Key Findings

- **Lewis Hamilton** leads all time with 105 wins and 202 podiums across 356 races
- **Juan Manuel Fangio** holds the highest win rate at 46%+ from the early era
- **Ferrari** dominated the early era, **McLaren/Williams** the turbo era, **Mercedes** the hybrid era
- **Verstappen** edges Hamilton on win percentage (30.1% vs 29.5%) in fewer races

---

## Dataset

Downloaded from Kaggle:  
[Formula 1 World Championship Dataset](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)

---
