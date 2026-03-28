#' @title Calculate functional diversity indices from tidy data
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Wraps the \code{fundiversity} package to calculate functional diversity indices 
#' (FRic, FDiv, FEve, FDis, Rao's Q) directly from a tidy long-format data frame.
#' Automatically handles parallelization if a \code{future::plan()} is set.
#'
#' @param df A data frame containing the trait and community data.
#' @param comm_names Unquoted column name containing the community names/IDs.
#' @param sp_names Unquoted column name containing the species names/IDs.
#' @param trait_names Unquoted column name containing the trait IDs.
#' @param trait_value Unquoted column name containing the actual trait values.
#' @param weight Unquoted column name containing the variable used to weight the trait values (e.g. abundance).
#' @param index Character vector of indices to compute. Options are "FRic", "FDiv", "FEve", "FDis", "RaoQ". Default is to compute all.
#'
#' @return A tibble with community coordinates and the selected functional diversity indices.
#' @export
tidy_calc_diversity <- function(df, comm_names, sp_names, trait_names, trait_value, weight, 
                                index = c("FRic", "FDiv", "FEve", "FDis", "RaoQ")) {
  
  # Convert to matrices
  mats <- tidy_to_matrices(df = df, 
                           comm_names = {{comm_names}}, 
                           sp_names = {{sp_names}}, 
                           trait_names = {{trait_names}}, 
                           trait_value = {{trait_value}}, 
                           weight = {{weight}})
                           
  site_sp <- mats$site_species
  sp_tr <- mats$species_traits
  
  res <- tibble::tibble(comm = rownames(site_sp))
  
  # Calculate requested indices
  if ("FRic" %in% index) {
    fric <- fundiversity::fd_fric(sp_tr, site_sp)
    res <- dplyr::left_join(res, fric, by = c("comm" = "site"))
  }
  if ("FDiv" %in% index) {
    fdiv <- fundiversity::fd_fdiv(sp_tr, site_sp)
    res <- dplyr::left_join(res, fdiv, by = c("comm" = "site"))
  }
  if ("FEve" %in% index) {
    feve <- fundiversity::fd_feve(sp_tr, site_sp)
    res <- dplyr::left_join(res, feve, by = c("comm" = "site"))
  }
  if ("FDis" %in% index) {
    fdis <- fundiversity::fd_fdis(sp_tr, site_sp)
    res <- dplyr::left_join(res, fdis, by = c("comm" = "site"))
  }
  if ("RaoQ" %in% index) {
    raoq <- fundiversity::fd_raoq(sp_tr, site_sp)
    res <- dplyr::left_join(res, raoq, by = c("comm" = "site"))
  }
  
  # Set community column name back to original
  names(res)[1] <- rlang::as_name(rlang::enquo(comm_names))
  
  return(tibble::as_tibble(res))
}
