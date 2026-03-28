#' @title Convert tidy long data to community and trait matrices
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Helper function to pivot a tidy long-format data frame into a site-by-species abundance matrix 
#' and a species-by-trait matrix, which are required for indices like functional diversity and rarity.
#'
#' @param df A data frame containing the trait and community data.
#' @param comm_names Unquoted column name containing the community names/IDs.
#' @param sp_names Unquoted column name containing the species names/IDs.
#' @param trait_names Unquoted column name containing the trait IDs.
#' @param trait_value Unquoted column name containing the actual trait values.
#' @param weight Unquoted column name containing the variable used to weight (e.g., abundance).
#'
#' @return A list containing `site_species` (a site by species matrix) and `species_traits` (a species by trait matrix).
#' @export
#' 
#' @examples
#' df <- data.frame(
#'   comm = c("A", "A", "B", "B"),
#'   species = c("sp1", "sp2", "sp1", "sp3"),
#'   trait = c("height", "height", "height", "height"),
#'   trait_value = c(5, 10, 5, 15),
#'   abundance = c(1, 2, 1, 3)
#' )
#' tidy_to_matrices(df, comm, species, trait, trait_value, abundance)
tidy_to_matrices <- function(df, comm_names, sp_names, trait_names, trait_value, weight) {
  
  if (!is.data.frame(df)) {
    cli::cli_abort(c(
      "x" = "{.arg df} must be a data frame or tibble.",
      "i" = "You supplied an object of class {.cls {class(df)}}."
    ))
  }
  
  # Extract site x species matrix
  site_species <- df |> 
    dplyr::filter(!is.na({{trait_value}}), !is.na({{weight}})) |>
    dplyr::select({{comm_names}}, {{sp_names}}, {{weight}}) |>
    dplyr::distinct() |>
    dplyr::group_by({{comm_names}}, {{sp_names}}) |>
    dplyr::summarise(weight_val = sum({{weight}}, na.rm = TRUE), .groups = "drop") |>
    tidyr::pivot_wider(names_from = {{sp_names}}, values_from = weight_val, values_fill = 0)
    
  # Convert to standard matrix format
  site_mat <- as.matrix(site_species[, -1])
  rownames(site_mat) <- dplyr::pull(site_species, {{comm_names}})
  
  # Extract species x trait matrix
  species_traits <- df |>
    dplyr::filter(!is.na({{trait_value}}), !is.na({{weight}})) |>
    dplyr::select({{sp_names}}, {{trait_names}}, {{trait_value}}) |>
    dplyr::distinct() |>
    dplyr::group_by({{sp_names}}, {{trait_names}}) |>
    dplyr::summarise(val = mean({{trait_value}}, na.rm = TRUE), .groups = "drop") |>
    tidyr::pivot_wider(names_from = {{trait_names}}, values_from = val)
    
  # Convert to standard matrix format
  trait_mat <- as.matrix(species_traits[, -1])
  rownames(trait_mat) <- dplyr::pull(species_traits, {{sp_names}})
  
  return(list(site_species = site_mat, species_traits = trait_mat))
}
