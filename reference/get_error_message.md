# Get enhanced error message with optional rlang trace

Provides error messages with optional stack trace information. Uses
rlang::trace_back() if available for better debugging.

## Usage

``` r
get_error_message(message, include_trace = FALSE)
```

## Arguments

- message:

  Error message

- include_trace:

  Logical, whether to include stack trace

## Value

Character string with error message and optional trace
