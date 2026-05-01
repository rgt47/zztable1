# Internal Blueprint Constructor

Low-level constructor for table1_blueprint objects. Used internally
after validation has been performed.

## Usage

``` r
new_table1_blueprint(
  nrows,
  ncols,
  cells = new.env(hash = TRUE, parent = emptyenv()),
  row_names = character(nrows),
  col_names = character(ncols),
  metadata = list(formula = NULL, options = list(), data_info = list(), cell_count = 0L,
    created = Sys.time(), stat_cache = new.env(hash = TRUE, parent = emptyenv()),
    spanner_store = new.env(hash = TRUE, parent = emptyenv()), summary_store =
    new.env(hash = TRUE, parent = emptyenv()))
)
```

## Arguments

- nrows:

  Integer number of rows (validated)

- ncols:

  Integer number of columns (validated)

- cells:

  Environment for sparse cell storage

- row_names:

  Character vector of row names

- col_names:

  Character vector of column names

- metadata:

  List of metadata

## Value

Validated table1_blueprint object
