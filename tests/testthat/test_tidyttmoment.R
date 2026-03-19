testthat::test_that("tidy_calc_moment returns the correct output", {
  # Create a data frame
  df <- data.frame(trait_names = c("A", "A", "B", "B"),
                   comm_names = c("X", "X", "Y", "Y"),
                   trait_value = c(2, 2, 2, 2),
                   weight = c(1, 1, 1, 1))

  # Calculate the expected output
  expected_output <- dplyr::tibble(trait_names = c("A", "B"),
                                comm_names = c("X", "Y"),
                                cwm = c(2, 2),
                                cwv = c(0, 0),
                                cws = c(0, 0),
                                cwk = c(-3, -3))

  # Calculate the actual output
  actual_output <- tidyttmoment::tidy_calc_moment(df,
                                    trait_names = trait_names,
                                    comm_names = comm_names,
                                    trait_value = trait_value,
                                    weight = weight)

  # Test that the actual output matches the expected output
  testthat::expect_equal(actual_output, expected_output)
})
