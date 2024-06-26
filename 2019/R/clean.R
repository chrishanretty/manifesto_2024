library(tidyverse)
library(tidytext)
library(arrow)
here::i_am("R/clean.R")

files <- list.files(here::here("cleaned"),
                    pattern = "*.txt",
                    full.names = TRUE)

tidy_func <- function(infile) { 
    text <- readLines(infile)
    text_df <- tibble(text = str_c(text, collapse = " ")) |>
        unnest_tokens(sents, text,
                      "sentences",
                      to_lower = FALSE,
                      drop = TRUE) |>
        mutate(sents = str_squish(sents))
    
    outfile <- sub("cleaned", "working", infile)
    outfile <- sub(".txt", ".rds", outfile)
    
    saveRDS(text_df, outfile)
}
lapply(files, tidy_func)
