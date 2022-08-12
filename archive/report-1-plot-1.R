# -------------------------------------------------------------------------
# input -------------------------------------------------------------------
# -------------------------------------------------------------------------
if (interactive()) {
    root <- here::here()
    infile <- file.path(root, "data", "clean", "monkeypox-outbreak-technical-briefing-1-data-england-10-june-2022.xls")
    outfile <- file.path(root, "output", "report-1-plot-1.svg")
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
library(magick)

# -------------------------------------------------------------------------
# main --------------------------------------------------------------------
# -------------------------------------------------------------------------

# load data
dat <- read_xls(path = infile, range = "A3:B45", sheet = "Fig1", col_names = TRUE)

# pivot longer
idx <- rep(seq.int(nrow(dat)), dat$count)
dat <- dat[idx,]
dat$count <- 1L

# convert to symptom_onset to date
dat$symptom_onset <- as.Date(dat$symptom_onset)

# make plot
p <- ggplot(dat, aes(x = symptom_onset, y = count)) +
    geom_col(color = "white", fill = "#007c91", position = "stack") +
    theme_minimal() +
    coord_equal() +
    scale_x_date(date_breaks = "2 days", date_labels = "%d-%b") +
    theme(
        axis.text.x = element_text(hjust = 1, angle = 45),
        axis.line = element_line(),
        axis.ticks.x = element_line(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
    ) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
    geom_vline(xintercept = as.Date("2022-05-22") - 0.5, linetype = "dashed") +
    xlab("Date of symptom onset") +
    ylab("Number of cases")

# save plot
svglite(outfile, width = 10, height = 3.5)
print(p)
dev.off()
