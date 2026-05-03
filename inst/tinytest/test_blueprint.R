# Test Blueprint System
# ====================


# Test uses package functions via testthat - no need to source files

bp <- Table1Blueprint(10, 5)

expect_inherits(bp, "table1_blueprint")
expect_equal(bp$nrows, 10)
expect_equal(bp$ncols, 5)
expect_true(inherits(bp$cells, "environment"))


expect_error(Table1Blueprint(-1, 5), "positive")
expect_error(Table1Blueprint(5, -1), "positive")
expect_error(Table1Blueprint(0, 5), "positive")


bp <- Table1Blueprint(5, 3)

# Create a test cell (assuming Cell constructor exists)
if (exists("Cell", mode = "function")) {
  test_cell <- Cell(type = "content", content = "Test Value")
  
  # Assign cell
  bp[2, 1] <- test_cell
  
  # Retrieve cell
  retrieved <- bp[2, 1]
  expect_equal(retrieved$content, "Test Value")
}


bp <- Table1Blueprint(3, 3)

expect_error(bp[5, 1], "out of bounds")
expect_error(bp[1, 5], "out of bounds") 
expect_error(bp[0, 1], "out of bounds")
expect_error(bp[1, 0], "out of bounds")


bp <- Table1Blueprint(8, 4)
dims <- dim(bp)

expect_equal(dims, c(8, 4))
expect_equal(length(dims), 2)


bp <- Table1Blueprint(3, 3)

# Empty cell should return NULL
empty_cell <- bp[1, 1]
expect_null(empty_cell)
