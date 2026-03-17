#' @title Calculate community weighted mean, variance, skewness, and kurtosis
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Calculates the community weighted mean, variance, skewness, and excess kurtosis of a given trait based on the moments described in Wieczynski et al. (2019).
#'
#' @param df A data frame containing the trait and community data.
#' @param trait_names Unquoted column name containing the trait IDs.
#' @param comm_names Unquoted column name containing the community names/IDs.
#' @param trait_value Unquoted column name containing the actual trait values.
#' @param weight Unquoted column name containing the variable used to weight the trait values (e.g. abundance).
#'
#' @return Returns a tibble with the columns comm, trait, cwm (mean), cwv (variance), cws (skewness), and cwk (excess kurtosis).
#' 
#' @references
#' Enquist, B. J., Norberg, J., Bonser, S. P., Violle, C., Webb, C. T., Henderson, A., ... & Savage, V. M. (2015). 
#' Scaling from traits to ecosystems. *Advances in Ecological Research*, 52, 249-318.
#' 
#' Metcalfe, R. J., Ozturk, M., & Pouteau, R. (2020). 
#' Using functional traits to model annual plant community dynamics. *Ecology*.
#' 
#' \enc{Šímová}{Simova}, I., Violle, C., Kraft, N. J., Storch, D., Svenning, J. C., Gallagher, R. V., ... & Enquist, B. J. (2018). 
#' Spatial patterns and climate relationships of major plant traits in the New World differ between woody and herbaceous species. *Global Ecology and Biogeography*, 27(8), 895-916.
#' 
#' Wieczynski, D. J., Boyle, B., Buzzard, V., Duran, S. M., Henderson, A. N., Hulshof, C. M., ... & Savage, V. M. (2019). 
#' Climate shapes and shifts functional biodiversity in forests worldwide. *Proceedings of the National Academy of Sciences*, 116(2), 587-592.
#'
#' @export
#'
#' @examples
#' df <- data.frame(trait = c("height", "height", "weight", "weight"),
#'                  trait_value = c(5, 10, 15, 12),
#'                  abundancia = c(1, 2, 1, 3),
#'                  comm = c("A", "A", "B", "B"))
#' tidy_calc_moment(df,
#' trait_names = trait,
#' comm_names = comm,
#' trait_value = trait_value,
#' weight = abundancia)
tidy_calc_moment  <- function(df, trait_names, comm_names, trait_value, weight) {
  # Argument validation
  if (!is.data.frame(df)) {
    cli::cli_abort(c(
      "x" = "{.arg df} must be a data frame or tibble.",
      "i" = "You supplied an object of class {.cls {class(df)}}."
    ))
  }
  
  # Calculate community weighted mean, variance, skewness, and kurtosis
  wm_trait <- df |>
    dplyr::filter(!is.na({{trait_value}}), !is.na({{weight}})) |>
    dplyr::group_by({{trait_names}}, {{comm_names}} ) |>
    dplyr::summarise(cwm = stats::weighted.mean({{trait_value}}, {{weight}},
                                                na.rm = TRUE),
                     cwv = sum(({{trait_value}} - cwm)^2 * {{weight}},
                               na.rm = TRUE)/ sum({{weight}}, na.rm = TRUE),
                     cws = sum((({{trait_value}} - cwm)/ sqrt(cwv))^3 * {{weight}},
                               na.rm = TRUE)/ sum({{weight}}, na.rm = TRUE),
                     cwk = (sum((({{trait_value}} - cwm)/sqrt(cwv))^4 * {{weight}},
                                na.rm = TRUE)/ sum({{weight}}, na.rm = TRUE)) - 3,
                    .groups = "drop"
    ) |>
    dplyr::distinct()
  return(wm_trait)
}
