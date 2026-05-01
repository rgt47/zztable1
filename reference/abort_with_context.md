# Throw informative error (with optional rlang)

Throws an error with context information. If rlang is available, uses
rlang::abort() for better error formatting and stack traces. Otherwise
falls back to base R stop().

## Usage

``` r
abort_with_context(message, class = NULL, ...)
```

## Arguments

- message:

  Error message

- class:

  Error class (for rlang)

- ...:

  Additional arguments for error context
