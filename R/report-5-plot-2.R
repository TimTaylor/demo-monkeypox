# -------------------------------------------------------------------------
# input -------------------------------------------------------------------
# -------------------------------------------------------------------------
if (interactive()) {
    root <- here::here()
    infile <- file.path(root, "data", "clean", "monkeypox-outbreak-technical-briefing-5-data-england-5-august-2022.xls")
    outfile <- file.path(root, "output", "report-5-plot-2.svg")
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
library(data.table)
library(patchwork)

# -------------------------------------------------------------------------
# main --------------------------------------------------------------------
# -------------------------------------------------------------------------

# load data
dat <- read_xls(
    path = infile,
    range = "A3:C863",
    sheet = "Fig2",
    col_names = TRUE,
    col_types = c("date", "text", "numeric")
)

# replace spaces with underscore and make lower case
names(dat) <- gsub(pattern = " ", replacement = "_", x = tolower(names(dat)), fixed = TRUE)

# convert to specimen_date to date
dat$specimen_date <- as.Date(dat$specimen_date)

# pull out non-london data
dat_not_london <- dat[dat$region != "London",]

# convert region to london or not
dat_london <- as.data.table(dat)
dat_london[region != "London", region := "Not London"]
dat_london <- dat_london[, .(count = sum(number_of_cumulative_cases)), by = c("specimen_date", "region")]

# make plot 1 (london)
p1 <- ggplot(dat_london, aes(x = specimen_date, y = count, colour = region)) +
    geom_line() +
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
    xlab(element_blank()) +
    ylab("Number of cases")

# make plot 2 (not london)
p2 <- ggplot(dat_not_london, aes(x = specimen_date, y = number_of_cumulative_cases, colour = region)) +
    geom_line() +
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
svglite(outfile, width = 10, height = 8)
print(p1 / p2)
dev.off()
