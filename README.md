
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ttmoment <a href='https://github.com/PaulESantos/ttmoment'><img src='man/figures/ttmoment.svg' align="right" height="250" width="220" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/ttmoment)](https://CRAN.R-project.org/package=ttmoment)
[![Codecov test
coverage](https://codecov.io/gh/PaulESantos/ttmoment/branch/main/graph/badge.svg)](https://app.codecov.io/gh/PaulESantos/ttmoment?branch=main)
[![R-CMD-check](https://github.com/PaulESantos/ttmoment/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/PaulESantos/ttmoment/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Functional traits are key characteristics of organisms that relate to
their performance, ecology, and evolution. The distribution of
functional traits can provide important insights into the functioning of
ecosystems and the responses of organisms to environmental change.
Evaluating the moments of this distribution (i.e., mean, variance,
skewness, and kurtosis) is a standard approach to quantifying the shape
and dispersion of the distribution. It has been widely used in
ecological and evolutionary research. However, calculating these moments
for functional traits in R currently has two objects which could be
confusing for beginners users of R. By developing the ttmoment R library
that allows for easy and efficient calculation of these moments,
researchers can save time and reduce the potential for errors in their
analyses.

## Key Features
- **Accurate Calculations**: Precisely computes Community-Weighted Mean (CWM), Variance (CWV), Skewness (CWS), and Excess Kurtosis (CWK) following robust methodologies established in trait scaling literature (*Wieczynski et al. 2019*, *Enquist et al. 2015*, *Šímová et al. 2018*, *Metcalfe et al. 2020*).
- **Robust `NA` Handling**: Statistically accurate scaling that properly omits missing trait records from both numerators and denominators.
- **Tidyverse-ready**: Fully designed around `dplyr` principles supporting unquoted column names (tidy evaluation).
- **Semantic Feedback**: Implements user-friendly error messaging using standard `cli` formatting.

## Installation

You can install the released version of ttmoment from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("ttmoment")
```

And the development version from [GitHub](https://github.com/) with:

``` r
pak::pak("PaulESantos/ttmoment")
```

## Example

This is a realistic example demonstrating how to calculate functional moments for an ecological dataset containing multiple traits, communities, and species abundances:

```r
library(ttmoment)
library(dplyr)
set.seed(42)

# 1. Simulate a trait database (e.g., Specific Leaf Area and Wood Density for 10 species)
species_traits <- expand.grid(
  species = paste0("sp_", 1:10),
  trait = c("SLA", "Wood_Density"),
  stringsAsFactors = FALSE
) |> 
  mutate(trait_value = runif(n(), min = 5, max = 100))

# 2. Simulate a community survey (abundances across 3 different sites)
community_survey <- expand.grid(
  comm = c("Forest_A", "Forest_B", "Grassland_C"),
  species = paste0("sp_", 1:10),
  stringsAsFactors = FALSE
) |> 
  mutate(abundance = rpois(n(), lambda = 25)) |> 
  sample_frac(0.8) # Introduce missing species realistically

# 3. Join the traits with the community abundances
ecological_data <- inner_join(community_survey, species_traits, by = "species")

# 4. Calculate the 4 community-weighted moments simultaneously
trait_moments <- tidy_calc_moment(
  df = ecological_data, 
  trait_names = trait,
  comm_names = comm,
  trait_value = trait_value,
  weight = abundance
)

print(trait_moments)
```
