#' @title Calculate functional rarity indices from tidy data
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Wraps the \code{funrar} package to calculate functional rarity indices 
#' (Distinctiveness and Uniqueness) directly from a tidy long-format data frame.
#'
#' @param df A data frame containing the trait and community data.
#' @param comm_names Unquoted column name containing the community names/IDs.
#' @param sp_names Unquoted column name containing the species names/IDs.
#' @param trait_names Unquoted column name containing the trait IDs.
#' @param trait_value Unquoted column name containing the actual trait values.
#' @param weight Unquoted column name containing the variable used to weight the trait values (e.g. abundance).
#'
#' @return A list of tibbles containing distinctiveness and uniqueness metrics.
#' @export
tidy_calc_rarity <- function(df, comm_names, sp_names, trait_names, trait_value, weight) {
    
    mats <- tidy_to_matrices(df = df, 
                             comm_names = {{comm_names}}, 
                             sp_names = {{sp_names}}, 
                             trait_names = {{trait_names}}, 
                             trait_value = {{trait_value}}, 
                             weight = {{weight}})
                             
    # Standardize traits and compute Euclidean distance matrix
    # Note: For more complex traits, users might want to calculate their own distance matrix. 
    # This wrapper focuses on numeric traits (as expected by tidy_calc_moment).
    scaled_traits <- scale(mats$species_traits)
    dist_mat <- as.matrix(stats::dist(scaled_traits))
    
    # Calculate D_i (Distinctiveness) - requires relative abundances
    # Convert absolute abundances to relative abundances
    site_sp_rel <- funrar::make_relative(mats$site_species)
    dist_idx <- funrar::distinctiveness(site_sp_rel, dist_mat)
    
    # Convert to tidy format
    comm_name_str <- rlang::as_name(rlang::enquo(comm_names))
    sp_name_str <- rlang::as_name(rlang::enquo(sp_names))
    
    dist_tidy <- as.data.frame(dist_idx) |>
      tibble::rownames_to_column(var = comm_name_str) |>
      tidyr::pivot_longer(cols = -1, names_to = sp_name_str, values_to = "distinctiveness") |>
      dplyr::filter(!is.na(distinctiveness))
      
    # Calculate U_i (Uniqueness)
    uniq_idx <- funrar::uniqueness(mats$site_species, dist_mat)
    
    # Rename 'species' column to whatever user provided
    sp_name_str <- rlang::as_name(rlang::enquo(sp_names))
    uniq_tidy <- as.data.frame(uniq_idx) |>
      dplyr::rename(!!sp_name_str := species, uniqueness = Ui)
      
    return(list(distinctiveness = tibble::as_tibble(dist_tidy),
                uniqueness = tibble::as_tibble(uniq_tidy)))
}
