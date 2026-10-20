# Project Investigation Notes

## Project
UK Online Retail Revenue, Customer Value, and Product Performance Analysis

## Dataset
- Source: UCI Online Retail II
- File: `data/online_retail_II.xlsx`
- Worksheets: `Year 2009-2010`, `Year 2010-2011`
- Columns: 8 in each worksheet
- Total data rows across both worksheets: 1,067,371

## Initial Data-Quality Observations
- Customer IDs are missing in both worksheets.
- Product descriptions are missing in both worksheets.
- Exact duplicate rows exist in both worksheets.
- Some invoice IDs begin with `C`, indicating cancellation-style invoices.
- Some transactions have negative quantities.
- A small number of rows have negative prices.
- The two worksheets contain different sets of countries.

## Decisions Not Yet Made
- Whether duplicate rows should be removed.
- How cancellation-style invoices and negative quantities should be handled.
- How missing Customer IDs should affect each analysis.
- How negative prices should be treated.
- How revenue should be defined for the business questions.

## Investigation Principle
Do not delete or alter records until their nature and potential impact have been investigated. Record decisions and justify them using evidence from the dataset.

## Results Pending Verification
- Revenue contribution of records with missing Customer IDs.
- Revenue contribution of exact duplicate rows.
- Final definition of revenue for each business question.
## Measured Investigation Results

### Missing Customer IDs

| Worksheet | Rows with missing Customer ID | Line value of missing-ID rows | Line value of known-ID rows |
|---|---:|---:|---:|
| 2009–2010 | 107,927 | 1,191,276.06 | 8,348,208.574 |
| 2010–2011 | 135,080 | 1,447,682.12 | 8,300,083.814 |

- Line value is calculated as `Quantity × Price`.
- These are preliminary line-value totals, not yet validated net revenue.
- Missing Customer IDs should not automatically cause a row to be deleted.
- Customer-level analysis may exclude unidentified transactions when reliable customer identity is required.

### Exact Duplicate Rows

| Worksheet | Exact duplicate rows | Line value associated with duplicate rows |
|---|---:|---:|
| 2009–2010 | 6,865 | 33,709.07 |
| 2010–2011 | 5,268 | 21,740.98 |

- Duplicate counts were calculated using exact row equality with `duplicated(keep="first")`.
- Duplicate rows have not been removed.
- The reported duplicate-row line values require further interpretation before any removal decision.

### Decisions Still Pending

- Investigate duplicate examples and their invoice context.
- Examine cancellation-style invoices and negative quantities together.
- Inspect negative prices and missing product descriptions.
- Compare the countries present in each worksheet.
- Establish and document the revenue rules before producing final business metrics.


## Phase 1 Conclusion

### Dataset Structure
- Total records and columns:
- Unique invoices:
- Unique stock codes:
- Unique identified customers:
- Unique countries:
- Schema compatibility:

### Transaction Patterns
- Negative quantities without C invoice IDs:
- Zero-price records:
- Invoice prefix patterns:
- StockCode B observations:

### Missing Data
- Rows with both missing Customer IDs and descriptions:
- Rows with only missing Customer IDs:
- Rows with only missing descriptions:
- Rows with neither field missing:

### Preliminary Line-Value Investigation
- Total line value:
- Line value associated with C invoice rows:
- Line value associated with negative quantities:
- Line value associated with zero prices:
- Line value associated with negative prices:
- Line value associated with StockCode B:

### Outstanding Questions
- Which duplicate rows, if any, should be removed?
- How should cancellation and return-related records be represented?
- How should bad-debt adjustments be treated?
- How should missing Customer IDs and descriptions affect each analysis?
- What revenue definition will be used for each business question?

### Phase 1 Status
- Investigation completed:
- Decisions that still require evidence:
- Confirmation to begin Phase 2:

## SQL Analysis Progress

- SQLite database created from the prepared CSV.
- Imported row count verified against the prepared dataset.
- Transaction-category totals reconciled with Python.
- Monthly line value, product rankings, customer value, and country
  performance explored.
- Product/service code exclusions are documented as analytical filters.
- Final revenue definition and duplicate-handling policy remain pending.
- Findings are preliminary until transaction and date-overlap checks
  are complete.

  ## SQL Analysis Findings

- Prepared dataset rows: 1,067,371
- SQLite row count matches the prepared CSV.
- Transaction category totals reconcile with Python.
- Extra duplicate occurrences: 34,335
- Extra duplicate signed line value: 431,716.87
- Missing Customer ID rows: 243,007
- Missing Customer ID preliminary line value: 2,638,958.18
- Top ordinary-category product by line value:
  REGENCY CAKESTAND 3 TIER, 344,563.25
- Top ordinary-category product by units:
  WORLD WAR 2 GLIDERS ASSTD DESIGNS, 110,249
- UK ordinary-category line value: 17,859,915.72

## Pending Validation

- Check for exact record overlap between source worksheets.
- Investigate extreme quantities and unusual stock codes.
- Finalize duplicate and cancellation handling.
- Define the final revenue metric before publishing conclusions.

## Exploratory Analysis Progress

- Prepared dataset loaded into Power BI.
- Monthly ordinary-category line-value chart created.
- Top 10 retail stock-code chart created.
- Source worksheets contain identical records in the
  December 1–9, 2010 overlap window.
- Cross-sheet overlap requires correction or documented
  treatment before final business conclusions are published.
- Preliminary line value is not audited revenue or profit.