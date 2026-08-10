# Credit Risk Analytics & Monitoring Dashboard

A comprehensive **Credit Risk Analytics and Loan Monitoring Dashboard** built using **Power BI and SQL** to analyze loan portfolio risk, default behavior, expected losses, and high-risk loans.

## 📊 Project Overview

This project analyzes a loan portfolio of approximately **50K loans** across multiple sectors and loan types.

The dashboard provides:

- Portfolio default-rate analysis
- Risk-category analysis
- Credit-score distribution
- Sector-level risk analysis
- Loan-type risk analysis
- Expected-loss analysis
- High-risk loan monitoring
- Loan-level risk details

## 🛠️ Tools & Technologies

- **Power BI** – Dashboard development and visualization
- **SQL** – Data analysis and risk calculations
- **CSV** – Source dataset
- **GitHub** – Project documentation and version control

# 📈 Dashboard

## 1. Executive Overview

Provides an executive-level view of overall portfolio performance and credit risk.

### Key KPIs

| Metric | Value |
|---|---:|
| Default Rate | 13.90% |
| Total Loans | 50K |
| Defaulted Loans | 6.95K |
| Total Expected Loss | 1.92bn |

### Dashboard

![Executive Overview](SQL/executive-overview.png)

---

## 2. Credit Risk Analysis

Analyzes portfolio credit quality, risk segmentation, expected losses, and loan-level risk patterns.

### Key KPIs

| Metric | Value |
|---|---:|
| Average Credit Score | 714.98 |
| Average LGD | 54.65% |
| Average PD | 2.25% |
| Total EAD | 164.93bn |

### Analysis Includes

- Risk Decile vs Default Rate
- Credit Score Distribution
- Expected Loss by Loan Type
- Default Rate by Loan Type
- Risk Category × Loan Type analysis
- Sector analysis
- Interactive risk filters

### Dashboard

![Risk Analysis](SQL/risk-analysis.png)

---

## 3. Loan Monitoring

Provides loan-level monitoring of **High Risk** and **Critical Risk** portfolios.

### Monitoring Features

- Loan ID
- Sector
- Loan Type
- Risk Category
- Credit Score
- Probability of Default (PD)
- Loss Given Default (LGD)
- Exposure at Default (EAD)
- Expected Loss
- Default Status

Interactive filters allow analysis by:

- Sector
- Loan Type
- Risk Category
- Default Status

### Dashboard

![Loan Monitoring](SQL/loan-monitoring.png)

---

# 🔍 Key Insights

### Risk Categories

Critical Risk and High Risk segments show significantly higher default rates than lower-risk categories.

### Risk Deciles

Default rates decline substantially across increasing risk deciles, demonstrating a strong relationship between risk segmentation and observed default behavior.

### Loan Types

Different loan types have different default-rate and expected-loss profiles, allowing comparison of credit risk across lending products.

### Sectors

Sector-level analysis highlights differences in default rates, exposure, and expected losses across the portfolio.

### Expected Loss

Expected-loss analysis helps identify loan types and sectors contributing significantly to potential portfolio losses.

---

# 🧮 SQL Analysis

SQL was used for portfolio-level and loan-level credit risk analysis.

The analysis includes:

- Default-rate calculations
- Risk-category analysis
- Loan-type analysis
- Sector-level analysis
- Expected-loss calculations
- Credit-risk segmentation
- High-risk loan identification
- Defaulted-loan analysis

SQL script:

`SQL/credit_risk_analysis.sql`

---

# 📂 Repository Structure

```text
credit-risk-analytics/
│
├── README.md
│
└── SQL/
    ├── credit_risk_analysis.sql
    ├── executive-overview.png
    ├── risk-analysis.png
    └── loan-monitoring.png
