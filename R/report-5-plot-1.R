# -------------------------------------------------------------------------
# input -------------------------------------------------------------------
# -------------------------------------------------------------------------
if (interactive()) {
    root <- here::here()
    infile <- file.path(root, "data", "clean", "monkeypox-outbreak-technical-briefing-5-data-england-5-august-2022.xls")
    outfile <- file.path(root, "output", "report-5-plot-1.svg")
} else {
    args <- commandArgs(trailingOnly = TRUE)
    infile <- args[1]
    outfile <- args[2]
}

# -------------------------------------------------------------------------
# packages ----------------------------------------------------------------
# -------------------------------------------------------------------------
library(readxl)
library(ggplot2)
library(svglite)

# -------------------------------------------------------------------------
# main --------------------------------------------------------------------
# -------------------------------------------------------------------------

# load data
dat <- read_xls(path = infile, range = "A4:B149", sheet = "Fig1", col_names = TRUE)

# replace spaces with underscore and make lower case
names(dat) <- gsub(pattern = " ", replacement = "_", x = tolower(names(dat)), fixed = TRUE)

# convert to specimen_date to date
dat$specimen_date <- as.Date(dat$specimen_date)

# calculate moving average
filter <- rep_len(1 / 7, 7L)
dat$moving_average <- filter(dat$number_of_cases, filter, sides = 2)

# make plot
p <- ggplot(dat, aes(x = specimen_date, y = number_of_cases)) +
    geom_col(color = "white", fill = "#007c91", position = "stack") +
    geom_line(aes(x = specimen_date, y = moving_average)) +
    theme_minimal() +
    scale_x_date(date_breaks = "1 week", date_labels = "%d-%b") +
    theme(
        axis.text.x = element_text(hjust = 1, angle = 45),
        axis.line = element_line(),
        axis.ticks.x = element_line(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
    ) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    xlab("Specimen date") +
    ylab("Number of cases")

# save plot
svglite(outfile, width = 10, height = 4)
print(p)
dev.off()
