# ============================================================
# Did Canada's Federal Carbon Tax Change Ontario's GHG Emissions Trend?
# An interrupted time series analysis, 2009-2023 (base R only)
#
# Data: Statistics Canada Table 38-10-0097-01
#       "Physical flow account for greenhouse gas emissions"
# ============================================================

raw <- read.csv("statcan_ghg_province.csv", stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")

# ---- 1. Filter to Ontario, total emissions ----
ontario <- raw[raw$GEO == "Ontario" & raw$Sector == "Total, industries and households", ]
ontario <- data.frame(
  year = as.integer(ontario$REF_DATE),
  emissions_mt = as.numeric(ontario$VALUE) / 1000  # kilotonnes -> megatonnes
)
ontario <- ontario[order(ontario$year), ]
print(ontario)

# ---- 2. Mark the policy period ----
# Federal carbon tax ("backstop") took effect in Ontario in April 2019.
ontario$post      <- as.integer(ontario$year >= 2019)
ontario$time      <- ontario$year - min(ontario$year)
ontario$time_post <- pmax(0, ontario$year - 2019)

# ---- 3. Interrupted time series regression ----
# emissions = b0 + b1*time + b2*post + b3*time_post + error
its_model <- lm(emissions_mt ~ time + post + time_post, data = ontario)
cat("\n==================== FULL MODEL ====================\n")
print(summary(its_model))

# ---- 4. Counterfactual: pre-2019 trend extrapolated forward ----
pre_only <- lm(emissions_mt ~ time, data = ontario[ontario$year <= 2018, ])
ontario$counterfactual <- predict(pre_only, newdata = ontario)

# ---- 5. Plot ----
png("ontario_emissions_its_plot.png", width = 900, height = 600, res = 130)
plot(ontario$year, ontario$emissions_mt, type = "o", pch = 16, col = "black",
     xlab = "Year", ylab = "Emissions (Mt CO2 eq)",
     main = "Ontario GHG Emissions vs. Pre-Tax Trend Extrapolation",
     ylim = range(c(ontario$emissions_mt, ontario$counterfactual)))
lines(ontario$year, ontario$counterfactual, col = "steelblue", lty = 2, lwd = 2)
abline(v = 2019, col = "red", lty = 3)
text(2019.2, max(ontario$emissions_mt), "Carbon tax starts", col = "red", pos = 4, cex = 0.8)
legend("bottomleft", legend = c("Actual emissions", "Pre-2019 trend (extrapolated)"),
       col = c("black", "steelblue"), lty = c(1,2), pch = c(16, NA), bty = "n", cex = 0.85)
dev.off()

# ---- 6. Summary of findings ----
cat("\n\n==================== SUMMARY ====================\n")
cat("Pre-tax annual trend (2009-2018):", round(coef(pre_only)[2], 2), "Mt/year\n")
cat("\nInterrupted time series model coefficients:\n")
print(round(coef(its_model), 3))
cat("\np-value on trend-change term (time_post):",
    round(summary(its_model)$coefficients["time_post", "Pr(>|t|)"], 3), "\n")
cat("\nGap between actual and counterfactual (pre-trend extrapolation), by year:\n")
post_years <- ontario[ontario$year >= 2019, ]
post_years$actual <- round(post_years$emissions_mt, 1)
post_years$counterfactual <- round(post_years$counterfactual, 1)
post_years$gap <- round(post_years$emissions_mt - post_years$counterfactual, 1)
print(post_years[, c("year", "actual", "counterfactual", "gap")])
