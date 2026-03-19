test_that("tidy_to_matrices works correctly", {
  df <- data.frame(
    comm = c("A", "A", "A", "B", "B", "B"),
    species = c("sp1", "sp2", "sp3", "sp1", "sp2", "sp4"),
    trait = c("height", "height", "height", "height", "height", "height"),
    trait_value = c(5, 10, 15, 5, 10, 20),
    abundance = c(1, 2, 0, 1, 3, 2)
  )
  
  mats <- tidy_to_matrices(df, comm, species, trait, trait_value, abundance)
  
  expect_type(mats, "list")
  expect_named(mats, c("site_species", "species_traits"))
  expect_true(is.matrix(mats$site_species))
  expect_true(is.matrix(mats$species_traits))
  
  # Check dimensions
  expect_equal(dim(mats$site_species), c(2, 4))
  expect_equal(dim(mats$species_traits), c(4, 1))
})

test_that("tidy_calc_diversity computes indices", {
  df <- data.frame(
    comm = c("A", "A", "A", "B", "B", "B"),
    species = c("sp1", "sp2", "sp3", "sp1", "sp2", "sp4"),
    trait = c("height", "height", "height", "height", "height", "height"),
    trait_value = c(5, 10, 15, 5, 10, 20),
    abundance = c(1, 2, 0, 1, 3, 2)
  )
  
  res <- tidy_calc_diversity(df, comm, species, trait, trait_value, abundance, index = c("FRic", "FDis", "RaoQ"))
  
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 2)
  expect_named(res, c("comm", "FRic", "FDis", "Q"))
})

test_that("tidy_calc_rarity computes indices", {
  df <- data.frame(
    comm = c("A", "A", "A", "B", "B", "B"),
    species = c("sp1", "sp2", "sp3", "sp1", "sp2", "sp4"),
    trait = c("height", "height", "height", "height", "height", "height"),
    trait_value = c(5, 10, 15, 5, 10, 20),
    abundance = c(1, 2, 0, 1, 3, 2)
  )
  
  res <- tidy_calc_rarity(df, comm, species, trait, trait_value, abundance)
  
  expect_type(res, "list")
  expect_named(res, c("distinctiveness", "uniqueness"))
  expect_s3_class(res$distinctiveness, "tbl_df")
  expect_s3_class(res$uniqueness, "tbl_df")
  
  expect_true("comm" %in% names(res$distinctiveness))
  expect_true("species" %in% names(res$distinctiveness))
  expect_true("species" %in% names(res$uniqueness))
  expect_true("distinctiveness" %in% names(res$distinctiveness))
  expect_true("uniqueness" %in% names(res$uniqueness))
})
