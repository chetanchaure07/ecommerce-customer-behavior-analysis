# Business Requirements Document (BRD)

## Customer Behavior and Retention Analytics for ShopEasy India

| Field | Details |
| --- | --- |
| Document version | 1.0 |
| Date | 27 October 2026 |
| Prepared for | Head of Business, Marketing, Operations, Category and Retention teams |
| Tools | Python (Google Colab), PostgreSQL (pgAdmin), Power BI |
| Status | Draft for review |
| Project note | This is a portfolio project. ShopEasy India is a fictional company and all data is synthetic. |

## 1. Executive Summary

ShopEasy India is an online retailer selling Electronics, Fashion, Home & Kitchen, Beauty, Grocery, Sports and Books in 14 Indian cities. Between January 2023 and December 2025 the store recorded about 6,000 orders from about 1,200 customers.

Leadership currently has no single view of which customers, categories, cities and marketing channels create value, or why orders are returned and cancelled. This document defines the business requirements for an analytics solution that answers these questions with SQL analysis and an interactive Power BI dashboard, so that stakeholders can make evidence-based decisions.

## 2. Business Background

- The business sells through its own website and app, with payments by UPI, cards, net banking, wallet and Cash on Delivery.
- Customers join through six acquisition channels: Organic Search, Instagram Ads, Google Ads, Referral, Email and YouTube.
- Some customers are Prime members, who receive free shipping.
- Reporting is currently done by hand from raw exports, which are inconsistent: dates appear in several formats, spellings vary, and some values are missing or invalid.

## 3. Problem Statement

Revenue is growing, but management cannot explain why, where, or from whom. Specifically:

1. The business does not know which categories, cities and customers produce the most revenue.
2. Return and cancellation rates are not tracked by category or payment method, so the cause is unknown.
3. Marketing spend is not linked to customer value, so budget may go to channels that bring low-value customers.
4. There is no list of inactive customers to target for win-back campaigns.

## 4. Business Objectives and Success Criteria

| ID | Objective | Success measure |
| --- | --- | --- |
| OBJ-1 | Give leadership one trusted view of business performance | KPI cards and monthly trends available and reconciled with SQL results |
| OBJ-2 | Identify the highest-value categories, cities and acquisition channels | Ranked views of revenue, orders and revenue per customer |
| OBJ-3 | Find where returns and cancellations occur | Return and cancellation rates reported by category and payment method |
| OBJ-4 | Understand customer value differences (for example Prime vs non-Prime) | Comparison of AOV and orders per customer |
| OBJ-5 | Identify customers who have never purchased | Customer list produced for the retention team |
| OBJ-6 | Deliver documented, reproducible analysis | SQL file, cleaning log and dashboard published in one repository |

## 5. Scope

**In scope**

- Cleaning and validating the customers and orders data
- Loading the clean data into PostgreSQL
- 20 SQL analysis questions
- A 3-page Power BI dashboard
- Written insights and recommendations

**Out of scope**

- Profit and cost analysis (no cost data is available)
- Predictive modelling and machine learning
- Real-time data refresh
- Product-level (SKU) analysis

## 6. Stakeholders

| Stakeholder | Interest | Key decision |
| --- | --- | --- |
| Head of Business | Overall performance and growth | Where to focus next year's budget |
| Head of Marketing | Channel quality | How to split spend across channels |
| Head of Operations | Returns, cancellations, payments | How to reduce returns |
| Category Manager | Category and order value behaviour | Which categories to promote |
| Retention Lead | Customer activity | Whom to target in win-back campaigns |
| Data Analyst (author) | Delivery of the analysis | Methods, definitions, quality of results |

## 7. Business Requirements

| ID | Business requirement | Priority |
| --- | --- | --- |
| BR-01 | The business must see total customers, orders, revenue and average order value (AOV) | High |
| BR-02 | The business must see revenue trends by year and month | High |
| BR-03 | The business must see revenue, orders and AOV by product category | High |
| BR-04 | The business must see revenue and customers by city | High |
| BR-05 | The business must see customers and revenue by acquisition channel | High |
| BR-06 | The business must compare Prime and non-Prime customers | Medium |
| BR-07 | The business must see the split of Delivered, Returned and Cancelled orders | High |
| BR-08 | The business must see return rate by payment method | High |
| BR-09 | The business must see how orders are distributed by value band | Medium |
| BR-10 | The business must receive a list of customers who have never ordered | Medium |

## 8. KPI Definitions

All queries and dashboard measures must use these definitions.

| KPI | Definition |
| --- | --- |
| Revenue | Sum of order\_total for orders with order\_status = Delivered |
| Total orders | Count of all orders (all statuses) |
| AOV | Revenue divided by the number of Delivered orders |
| Return rate | Returned orders divided by total orders (state the denominator on every chart) |
| Cancellation rate | Cancelled orders divided by total orders |
| Revenue per customer | Revenue divided by distinct customers in the group |
| Order value band | Low: under 1,000; Medium: 1,000 to 10,000; High: over 10,000 (INR) |

## 9. Data Requirements

### 9.1 Data sources

| Table | Rows (approx.) | Description |
| --- | --- | --- |
| customers | 1,200 | One row per customer |
| orders | 6,000 | One row per order |

Relationship: one customer has many orders, joined on customer\_id.

### 9.2 Data dictionary

**customers**

| Column | Type | Description |
| --- | --- | --- |
| customer\_id | VARCHAR (primary key) | Unique customer identifier |
| gender | VARCHAR | Male, Female or Other |
| age | INTEGER | Customer age in years |
| city | VARCHAR | City of residence |
| state | VARCHAR | State of residence |
| signup\_date | DATE | Date the customer registered |
| acquisition\_channel | VARCHAR | How the customer was acquired |
| is\_prime\_member | VARCHAR | Yes or No |

**orders**

| Column | Type | Description |
| --- | --- | --- |
| order\_id | VARCHAR (primary key) | Unique order identifier |
| customer\_id | VARCHAR (foreign key) | Links to customers |
| order\_date | DATE | Date the order was placed |
| product\_category | VARCHAR | Product category |
| unit\_price | NUMERIC | Price per unit in INR |
| quantity | INTEGER | Units ordered |
| discount\_pct | NUMERIC | Discount percentage applied |
| shipping\_fee | NUMERIC | Shipping fee in INR |
| order\_total | NUMERIC | Final amount charged in INR |
| payment\_method | VARCHAR | Payment method used |
| order\_status | VARCHAR | Delivered, Returned or Cancelled |
| customer\_rating | NUMERIC | Rating 1 to 5 (Delivered orders only) |
| delivery\_days | INTEGER | Days taken to deliver |

### 9.3 Data quality requirements

The raw data contained duplicates, mixed date formats, inconsistent text values, missing values, invalid values, price outliers and orders linked to unknown customers. The cleaned data must meet these rules before analysis:

- No duplicate order\_id or customer\_id
- Every order links to an existing customer
- All dates in one format (YYYY-MM-DD)
- Standardised text values (categories, cities, payment methods, gender)
- Quantity between 1 and 5, and no missing price, quantity or discount
- order\_total equals unit\_price x quantity x (1 - discount\_pct/100) + shipping\_fee, within a tolerance of 1 INR
- Every cleaning decision recorded in a cleaning log (issue, rows affected, action, reason)

## 10. SQL Analysis Requirements

The analyst must answer the following questions in PostgreSQL. Each query is saved in analysis.sql with a header comment stating the question, the linked requirement and the insight.

### Level 1: Basic

| ID | Question | Linked requirement |
| --- | --- | --- |
| SQL-01 | How many rows are in the orders and customers tables? | Data validation |
| SQL-02 | Show the first 10 orders. | Data validation |
| SQL-03 | What are the distinct product categories? | BR-03 |
| SQL-04 | How many orders are Delivered, Returned and Cancelled? | BR-07 |
| SQL-05 | What is the total revenue from Delivered orders? | BR-01 |
| SQL-06 | What are the highest and lowest order totals? | BR-01 |
| SQL-07 | Which orders are above 20,000, highest first? | BR-09 |
| SQL-08 | How many orders were paid by UPI? | BR-08 |

### Level 2: Grouping and conditions

| ID | Question | Linked requirement |
| --- | --- | --- |
| SQL-09 | What is the total revenue per category? | BR-03 |
| SQL-10 | What is the AOV per category? | BR-03 |
| SQL-11 | How many orders are there per payment method? | BR-08 |
| SQL-12 | How many orders were placed in each year? | BR-02 |
| SQL-13 | What is the monthly revenue for 2025? | BR-02 |
| SQL-14 | Which categories have more than 800 orders? | BR-03 |
| SQL-15 | How many orders fall into the Low, Medium and High value bands? | BR-09 |

### Level 3: Joins

| ID | Question | Linked requirement |
| --- | --- | --- |
| SQL-16 | What is the revenue per city (top 5)? | BR-04 |
| SQL-17 | How many customers and how much revenue does each acquisition channel have? | BR-05 |
| SQL-18 | Do Prime members have a higher AOV than non-Prime members? | BR-06 |
| SQL-19 | What is the return rate per payment method? | BR-08 |
| SQL-20 | Which customers have never placed an order? | BR-10 |

## 11. Dashboard Requirements (Power BI)

### 11.1 General requirements

- Connect to PostgreSQL (or the exported SQL result tables)
- Three pages with consistent colours, fonts and layout
- Maximum 8 visuals per page, KPI cards at the top
- Every chart title states the finding or the metric clearly
- Slicers for Year, Product category, City, Payment method and Prime membership, synchronised across pages
- Tooltips showing order counts next to any percentage

### 11.2 Page 1: Executive Overview

| Visual | Content | Requirement |
| --- | --- | --- |
| KPI cards | Revenue, total orders, customers, AOV | BR-01 |
| Line chart | Monthly revenue trend | BR-02 |
| Bar chart | Revenue by category | BR-03 |
| Bar chart or map | Revenue by city (top 5) | BR-04 |
| Column chart | Orders by year | BR-02 |

### 11.3 Page 2: Customers and Marketing

| Visual | Content | Requirement |
| --- | --- | --- |
| Bar chart | Customers and revenue by acquisition channel | BR-05 |
| Column chart | Revenue per customer by channel | BR-05 |
| Clustered column | Prime vs non-Prime AOV | BR-06 |
| Column chart | Orders by value band | BR-09 |
| Table | Customers with no orders | BR-10 |

### 11.4 Page 3: Orders, Returns and Payments

| Visual | Content | Requirement |
| --- | --- | --- |
| Donut chart | Delivered, Returned, Cancelled split | BR-07 |
| Bar chart | Return rate by payment method | BR-08 |
| Bar chart | Return rate by category | BR-07 |
| Column chart | Orders by payment method | BR-08 |
| Table | Orders above 20,000 | BR-09 |

## 12. Traceability Matrix

Every requirement must trace to at least one SQL query and one dashboard visual.

| Requirement | SQL questions | Dashboard visual |
| --- | --- | --- |
| BR-01 | SQL-05, SQL-06 | KPI cards (page 1) |
| BR-02 | SQL-12, SQL-13 | Monthly revenue line, orders by year (page 1) |
| BR-03 | SQL-03, SQL-09, SQL-10, SQL-14 | Revenue by category (page 1) |
| BR-04 | SQL-16 | Revenue by city (page 1) |
| BR-05 | SQL-17 | Channel charts (page 2) |
| BR-06 | SQL-18 | Prime vs non-Prime (page 2) |
| BR-07 | SQL-04 | Order status donut, return rate by category (page 3) |
| BR-08 | SQL-08, SQL-11, SQL-19 | Return rate and orders by payment method (page 3) |
| BR-09 | SQL-07, SQL-15 | Value band chart (page 2), high-value table (page 3) |
| BR-10 | SQL-20 | No-order customers table (page 2) |

## 13. Non-Functional Requirements

| Area | Requirement |
| --- | --- |
| Accuracy | SQL totals and dashboard KPIs must match |
| Reproducibility | All cleaning and analysis can be re-run from the raw files |
| Usability | A non-technical stakeholder can read each page without help |
| Performance | Dashboard pages load in under 5 seconds on the sample data |
| Documentation | Cleaning log, KPI definitions and data dictionary are included |
| Security | No real personal data is used; all data is synthetic |

## 14. Assumptions, Constraints and Risks

**Assumptions**

- Revenue is recognised only on Delivered orders
- All amounts are in INR
- The cleaned dataset is the single source of truth

**Constraints**

- No cost or profit data, so margin analysis is not possible
- A small dataset (about 6,000 orders), so small groups can give unstable percentages
- Synthetic data may not reflect real customer behaviour

**Risks**

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Some orders are dated before the customer signup date | Cohort and tenure analysis would be wrong | Flag the rows and correct signup date to first order date; document in the cleaning log |
| Different metric definitions across queries | Conflicting numbers | Use the KPI definitions in section 8 everywhere |
| Small group sizes | Misleading percentages | Show order counts next to every rate |
| Join duplication | Inflated revenue | Check row counts after every join |

## 15. Deliverables and Timeline

| Deliverable | Description |
| --- | --- |
| Cleaning notebook (.ipynb) | Python cleaning with issue register |
| Cleaning log (.csv) | Every cleaning decision |
| Clean datasets (.csv) | customers\_clean and orders\_clean |
| analysis.sql | 20 queries with header comments and insights |
| Power BI file (.pbix) and screenshots | Three-page dashboard |
| Executive summary (1 page) | Findings and recommendations |
| README and this BRD | Project documentation |

| Phase | Activity |
| --- | --- |
| Week 1 | Data cleaning and cleaning log |
| Week 2 | Load PostgreSQL, SQL questions 1 to 15 |
| Week 3 | SQL questions 16 to 20, validation of results |
| Week 4 | Power BI dashboard and executive summary |
| Week 5 | Review, README and publish to GitHub |

## 16. Acceptance Criteria

The project is accepted when all of the following are true:

- [ ] Cleaned data passes every rule in section 9.3
- [ ] All 20 SQL questions are answered with a header comment and a written insight
- [ ] Revenue by category adds up to total revenue
- [ ] Dashboard KPI values match the SQL results
- [ ] Every business requirement is covered in the traceability matrix
- [ ] The executive summary contains at least three findings and three recommendations
- [ ] The repository contains all deliverables and can be understood from the README

## 17. Recommended Repository Structure

```
ecommerce-customer-behavior-analysis/
  README.md
  docs/
    BRD.md
    executive_summary.md
  data/
    raw/ (customers_raw.csv, orders_raw.csv)
    clean/ (customers_clean.csv, orders_clean.csv)
  notebooks/
    01_data_cleaning.ipynb
  sql/
    create_tables.sql
    analysis.sql
  dashboard/
    dashboard.pbix
    screenshots/
```

## 18. Glossary

| Term | Meaning |
| --- | --- |
| AOV | Average order value |
| BRD | Business requirements document |
| KPI | Key performance indicator |
| COD | Cash on Delivery |
| UPI | Unified Payments Interface, an Indian instant payment system |
| DAX | Data Analysis Expressions, the formula language of Power BI |
