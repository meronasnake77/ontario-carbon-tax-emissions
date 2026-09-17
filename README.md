# Ontario Carbon Tax Emissions Analysis

## Overview
This project investigates whether Ontario's greenhouse gas (GHG) emissions trend changed following the introduction of Canada's federal carbon tax in 2019. Using an interrupted time series regression, the analysis compares Ontario's actual post-2019 emissions to what the pre-2019 trend would have predicted, while explicitly accounting for the confounding effect of the COVID-19 pandemic.

## Data
- **Source:** Statistics Canada, Table 38-10-0097-01, *"Physical flow account for greenhouse gas emissions"*
- **Scope:** Ontario, total emissions (industries and households combined), 2009–2023
- **Units:** Kilotonnes CO2 equivalent, converted to megatonnes (Mt) for analysis

## Method
An interrupted time series (ITS) regression was used:

```
emissions = β0 + β1(time) + β2(post) + β3(time_post) + ε
```

- `time`: years since 2009 (captures the pre-existing trend)
- `post`: indicator for 2019 onward (captures an immediate level shift)
- `time_post`: years since 2019 (captures a change in trend slope after the policy)

A separate regression fit only on 2009–2018 data was also used to generate a counterfactual — what emissions would have looked like if the pre-tax trend had simply continued, with no policy change.

## Key Finding
Ontario's emissions were on a gradual decline before 2019. After the carbon tax began, emissions temporarily fell well below the pre-tax trend line — but this coincides almost exactly with COVID-19 lockdowns (2020–2021), not the tax itself. By 2023, emissions had returned close to where the pre-tax trend alone would have predicted.

The `time_post` coefficient (change in trend after the policy) was **not statistically significant (p = 0.89)**, meaning the data does not show a detectable shift in Ontario's emissions trajectory that can be attributed to the carbon tax, once the pandemic disruption is accounted for.

This is an important methodological takeaway as much as a substantive one: it highlights how difficult it is to isolate the effect of a single policy from a major concurrent economic shock, and why a "before vs. after" comparison alone can be misleading without modeling the underlying trend and its confounders.

## Files
- `carbon_tax_analysis_base.R` — full analysis script (data loading, regression, plotting)
- `statcan_ghg_province.csv` — raw StatCan data used in the analysis
- `ontario_emissions_its_plot.png` — output plot: actual emissions vs. pre-tax trend extrapolation

## Tools
R (base R only — no external packages required)

## Limitations
- Uses province-level aggregate emissions; sector-level or per-capita analysis could reveal effects masked at the aggregate level
- COVID-19 is treated qualitatively as a confounder rather than explicitly modeled
- A longer post-policy window (as more years of data become available) would give the trend-change estimate more statistical power
