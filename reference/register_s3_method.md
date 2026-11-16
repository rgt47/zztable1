# Register an S3 Method for a Generic in a Suggested Package

Registers immediately if `pkg` is already loaded, and otherwise (or
additionally, if it is later reloaded) when `pkg` loads.

## Usage

``` r
register_s3_method(pkg, generic, class, fun)
```

## Arguments

- pkg:

  Package that defines the generic

- generic:

  Generic function name

- class:

  Class name

- fun:

  Method function

## Value

`NULL`, invisibly
