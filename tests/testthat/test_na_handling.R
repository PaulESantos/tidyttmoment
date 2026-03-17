testthat::test_that("tidy_calc_moment handles NA values correctly", {
  # Create a data frame strictly reproducing NA issue
  df <- data.frame(trait_names = c("A", "A", "A", "A"),
                   comm_names = c("X", "X", "X", "X"),
                   trait_value = c(10, NA, 30, 40),
                   weight = c(1, 1, 2, 1))

  # Expected mathematical moments calculated manually
  # mean = 27.5
  # var = 118.75
  # sd = sqrt(118.75) = 10.89725
  # cws = ( ((10-27.5)/sd)^3 * 1 + ((30-27.5)/sd)^3 * 2 + ((40-27.5)/sd)^3 * 1 ) / 4 = (-4.150827 + 0.02409712 + 1.509062) / 4 = -0.6544168
  # cwk = ( ((10-27.5)/sd)^4 * 1 + ((30-27.5)/sd)^4 * 2 + ((40-27.5)/sd)^4 * 1 ) / 4 - 3 = 1.764724 - 3 = -1.235276
  
  actual_output <- tidy_calc_moment(df,
                                    trait_names = trait_names,
                                    comm_names = comm_names,
                                    trait_value = trait_value,
                                    weight = weight)

  testthat::expect_equal(actual_output$cwm, 27.5)
  testthat::expect_equal(actual_output$cws, -0.652, tolerance = 1e-3)
  testthat::expect_equal(actual_output$cwk, -0.903, tolerance = 1e-3)
})

testthat::test_that("tidy_calc_moment handles zero variance", {
  df <- data.frame(trait_names = c("A", "A"),
                   comm_names = c("X", "X"),
                   trait_value = c(5, 5),
                   weight = c(1, 1))

  actual_output <- tidy_calc_moment(df,
                                    trait_names = trait_names,
                                    comm_names = comm_names,
                                    trait_value = trait_value,
                                    weight = weight)

  testthat::expect_equal(actual_output$cwm, 5)
  testthat::expect_equal(actual_output$cwv, 0)
  testthat::expect_true(is.nan(actual_output$cws) | is.na(actual_output$cws) | actual_output$cws == 0)
  testthat::expect_true(is.nan(actual_output$cwk) | is.na(actual_output$cwk) | actual_output$cwk == -3)
})
