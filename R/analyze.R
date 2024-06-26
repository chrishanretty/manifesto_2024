library(tidyverse)
library(arrow)
library(hrbrthemes)
library(ggrepel)
here::i_am("R/analyze.R")

### Read in the parquet files

infiles <- list.files(here::here("distilled"),
                      pattern = ".parquet",
                      full.names = TRUE)

abc <- function(..., desc = FALSE) {
  data <- tidyselect::peek_data()
  named_selection <- tidyselect::eval_select(rlang::expr(c(...)), data)
  named_selection[order(names(named_selection), named_selection, decreasing = desc)]
}

read_func <- function(x) {
    read_parquet(x) |>
        mutate(file = x,
               party = sub(".*/", "", file),
               party = sub(".parquet", "", party)) |>
        dplyr::select(sents, file, party,
                      abc(everything()))
}

dat <- lapply(infiles, read_func) |>
    bind_rows()

### At the moment, categories are on the columns
dat <- dat |>
    pivot_longer(cols = 4:last_col(),
                 names_to = "code") |>
    mutate(code.num = parse_number(code))

### Merge categories with RILE schema

left_codes <- c(103, 105, 106, 107, 202, 403, 404, 406, 412, 413, 504,
                506, 701)

right_codes <- c(104, 201, 203, 305, 401, 402, 407, 414, 505, 601,
                 603, 605, 606)

dat <- dat |>
    mutate(is_left = code.num %in% left_codes,
           is_right = code.num %in% right_codes)

smry <- dat |>
    group_by(party) |>
    summarize(rile = (sum(is_right * value) - sum(is_left * value)) / sum(value),
              rile = rile * 100)

lag <- data.frame(party = c("con", "green", "lab", "ldem", "plaid", "reform", "snp"),
                  lag_rile = c(6.2, -20.4, -31.8, -19.6, -18.7, NA, -24.5))

smry <- left_join(smry, lag, by = "party")

ggplot(smry, aes(x = rile, y = lag_rile, fill = party)) +
    geom_point(shape = 21) +
    scale_x_continuous("Left-right score 2024") +
    scale_x_continuous("Left-right score 2019") +
    geom_text_repel(aes(label = party)) + 
    scale_fill_manual("Party",
                      values = c("darkblue", "green", "red", "goldenrod", "forestgreen", "purple", "yellow"),
                      guide = "none") +
    theme_ipsum_rc()

cosmo_codes <- c(107, 108, 201, 503, 604, 607, 705)
trad_codes <- c(109, 110, 601, 603, 605.1, 606, 608)

dat <- dat |>
    mutate(is_cosmo = code.num %in% cosmo_codes,
           is_trad = code.num %in% trad_codes)




smry <- dat |>
    group_by(party) |>
    summarize(rile = (sum(is_right * value) - sum(is_left * value)) / sum(value),
              rile = rile * 100,
              costrad = (sum(is_cosmo * value) - sum(is_trad * value)) / sum(value),
              costrad = costrad * 100,
              sum_left = sum(is_left * value),
              sum_right = sum(is_right * value),
              log_rile = log(0.5 + sum_left) - log(0.5 + sum_right))


p <- ggplot(smry, aes(x = rile, y = costrad, fill = party)) +
    geom_point(shape = 21) +
    scale_x_continuous("Left-right score 2024") +
    scale_y_continuous("Cosmo-trad score 2024") +
    geom_text_repel(aes(label = party)) + 
    scale_fill_manual("Party",
                      values = c("darkblue", "green", "red", "goldenrod", "forestgreen", "purple", "yellow"),
                      guide = "none") +
    theme_ipsum_rc()

ggsave(p, file = "lr_costrad.png", bg = "white")

p2 <- ggplot(smry, aes(x = rile, y = log_rile, fill = party)) +
    geom_point(shape = 21) +
    scale_x_continuous("Left-right score 2024") +
    scale_y_continuous("Log ratio left-right score 2024") +
    geom_text_repel(aes(label = party)) + 
    scale_fill_manual("Party",
                      values = c("darkblue", "green", "red", "goldenrod", "forestgreen", "purple", "yellow"),
                      guide = "none") +
    theme_ipsum_rc()

###
left_props <- dat |> 
    group_by(party, code, code.num) |>
    summarize(value = sum(value)) |>
    group_by(party) |>
    mutate(share = value / sum(value)) |>
    filter(code.num %in% left_codes) |>
    arrange(party, desc(share))

dat |>
    filter(party == "con") |>
    group_by(code, code.num) |>
    summarize(sents = sum(value)) |>
    ungroup() |>
    mutate(share = sents / sum(sents)) |>
    arrange(desc(share))

### TODO:

## - Check how this works in previous years
## - Show proportions for rile categories for each party
## - Check what proportion of the welfare state expansion categories involve health
