# Generate Cache Key for Statistical Computation

Creates a unique, deterministic cache key for a statistical computation
based on variable, stratum, and test type. Used for blueprint-level
result caching to avoid recomputing statistics across multiple renders.

## Usage

``` r
create_stat_cache_key(variable, stratum = NULL, test_type = "none")
```

## Arguments

- variable:

  Character string with variable name

- stratum:

  Optional stratum identifier (NULL or character)

- test_type:

  Character string with test type (e.g., "ttest", "chisq")

## Value

Character string with unique cache key

## Details

Cache key format:
`"var_\{variable\}_strat_\{stratum\}_test_\{test_type\}"` where stratum
defaults to "none" if NULL.

## Examples

``` r
if (FALSE) { # \dontrun{
create_stat_cache_key("age", "arm==treatment", "ttest")
# Returns: "var_age_strat_arm==treatment_test_ttest"

create_stat_cache_key("sex", NULL, "chisq")
# Returns: "var_sex_strat_none_test_chisq"
} # }
```
