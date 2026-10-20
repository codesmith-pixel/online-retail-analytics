# UK Online Retail Revenue, Customer Value, and Product Performance Analysis

An end-to-end data analytics project investigating transaction patterns, product performance, customer value, and country-level sales in the UK Online Retail II dataset.

## Project Overview

Retail businesses need reliable transaction data to understand what sells, when demand changes, which customers contribute the most transaction value, and which markets perform well.

This project uses Python, pandas, SQL, and Power BI to clean and investigate the Online Retail II dataset and build a dashboard for exploring retail transaction patterns.

## Business Questions

- How does transaction value change over time?
- Which products have the highest recorded line value?
- Which products have the highest sales quantities?
- Which identified customers contribute the highest transaction value?
- How does recorded transaction value vary by country?
- What data-quality issues need to be considered before drawing business conclusions?

## Dataset

**Source:** UCI Machine Learning Repository, Online Retail II  
**Dataset page:** https://archive.ics.uci.edu/dataset/502/online+retail  
**License:** CC BY 4.0

The original workbook contains two worksheets covering December 2009 through December 2011. The combined source data contains over one million transaction rows.

The source worksheets share records in the December 1–9, 2010 date window. The preparation process excludes the repeated window from the second worksheet to avoid counting those records twice.

## Tools and Technologies

- **Python:** data preparation and exploratory analysis
- **pandas and NumPy:** data cleaning and transformation
- **Matplotlib:** data visualization
- **SQLite:** SQL-based analysis and validation
- **Power BI Desktop:** interactive dashboard
- **Git and GitHub:** version control and project documentation

## Data Preparation

The cleaning workflow includes:

1. Loading and combining the source worksheets.
2. Standardizing column names and data types.
3. Correcting the overlapping source date window.
4. Creating a preliminary line-value measure using quantity multiplied by price.
5. Flagging cancellation-style invoices, missing customer IDs, negative quantities, zero prices, negative prices, and duplicate occurrences.
6. Categorizing transactions for analysis.
7. Exporting the prepared data to CSV and loading it into SQLite.
8. Comparing row counts to verify consistency between the prepared CSV and database.

The corrected prepared dataset contains **1,044,848 rows and 18 columns**.

## Data Quality and Limitations

The dataset contains missing customer identifiers, missing product descriptions, repeated rows, cancellation-style invoices, negative quantities, and unusual price or quantity values.

These records are flagged for investigation rather than automatically treated as errors. A repeated row is not necessarily invalid, and a cancellation-style invoice should not automatically be interpreted as a confirmed refund without further evidence.

The `line_value` field is calculated as quantity multiplied by price. It is a **preliminary transaction-value measure**, not audited revenue, cash collected, or profit.

Customer-value rankings are based on recorded transaction value and should not be interpreted as customer profitability.

## Project Structure

```text
online-retail-analytics/
├── notebooks/
│   ├── 02_data_cleaning.ipynb
│   ├── 03_sql_analysis.ipynb
│   └── 04_exploratory_analysis.ipynb
├── sql/
│   ├── 01_data_validation.sql
│   └── 02_business_analysis.sql
├── images/
│   ├── monthly_line_value.png
│   ├── top_products.png
│   └── powerbi_dashboard.png
├── powerbi/
│   └── online_retail_dashboard.pbix
├── data/
│   └── processed/
│       ├── online_retail_prepared.csv
│       └── online_retail.db
├── project_notes.md
├── requirements.txt
├── .gitignore
└── README.md
```

The raw workbook, prepared CSV, and SQLite database are local working files and are not intended to be committed to GitHub.

## Dashboard

The Power BI dashboard explores:

- Monthly ordinary-category line value
- Top products by recorded line value
- Country-level transaction value
- Customer and transaction metrics

![Power BI dashboard](images/powerbi_dashboard.png)

## How to Reproduce the Analysis

1. Download the Online Retail II workbook from the UCI dataset page.
2. Place the workbook at `data/online_retail_II.xlsx`.
3. Install the dependencies listed in `requirements.txt`.
4. Run the data-cleaning notebook.
5. Generate `data/processed/online_retail_prepared.csv`.
6. Build or refresh the SQLite database using the prepared CSV.
7. Run the SQL analysis and exploratory analysis notebooks.
8. Open the Power BI file and refresh it against the prepared dataset.

## Future Improvements

- Add automated data-quality checks.
- Improve date and customer-level analysis.
- Investigate extreme quantities and unusual stock codes.
- Document the final treatment of cancellation-style invoices and duplicate records.
- Add dashboard filters and more detailed customer segmentation.
- Validate all published business findings against the corrected dataset.

## Author

Data analytics portfolio project demonstrating data cleaning, exploratory analysis, SQL validation, visualization, and business-oriented reporting.
