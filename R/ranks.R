# Create rank columns for ordering languages
rank_by <- function(frame, values, rank_col_str = paste0(values, "_rank")) {
  frame[rank_col_str] <- rank(-frame[values], ties.method = "first")
  frame
}

# Order language by rank column
order_language_by <- function(frame, rank_col, levels_only = FALSE, reverse = FALSE, use_levels = NULL) {
  if(!is.null(use_levels)) {
    levels <- use_levels
  } else {
    levels <- frame %>%
      arrange_(.dots = list(rank_col)) %>%
      .$language_name
  }
  if(reverse) levels <- rev(levels)
  if(levels_only) return(levels)
  frame$language_ordered <- factor(frame$language_name, levels = levels)
  frame
}