# Populate Variables for Single Stratum

Helper function to populate variables within a single stratum.

## Usage

``` r
populate_variables_for_stratum(
  blueprint,
  stratum_data,
  var_info,
  dimensions,
  theme_config,
  start_row,
  current_stratum = NULL
)
```

## Arguments

- blueprint:

  Blueprint object

- stratum_data:

  Data frame for this stratum

- var_info:

  Variable information

- dimensions:

  Dimension analysis

- theme_config:

  Theme configuration

- start_row:

  Starting row number

- current_stratum:

  Value of the stratification variable for this stratum, used so
  per-stratum p-value cells filter to the correct subset rather than the
  whole sample.

## Value

Updated row number after population
