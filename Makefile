# -------------------------------------------------------------------------
# SETUP -------------------------------------------------------------------
# -------------------------------------------------------------------------
.PHONY: data plots report

# directories
REFDIR := .
RAWDIR := ${REFDIR}/data/raw
CLEANDIR := ${REFDIR}/data/clean
OUTDIR := ${REFDIR}/output
REPORTDIR := ${REFDIR}/report

# url and raw/clean data files
URL := https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1096606/monkeypox-outbreak-technical-briefing-5-data-england-5-august-2022.ods
RAWDAT := ${RAWDIR}/$(notdir ${URL})
CLEANDAT := $(basename ${CLEANDIR}/$(notdir ${RAWDAT})).xls

# -------------------------------------------------------------------------
# helpers -----------------------------------------------------------------
# -------------------------------------------------------------------------

# make directory and parents for target
MKDIR = mkdir -p $(@D)

# run Rscript (${RS} myscript.R myinput1 myinput2 etc etc)
RS = Rscript --vanilla $^ $@

# -------------------------------------------------------------------------
# download data -----------------------------------------------------------
# -------------------------------------------------------------------------
${RAWDAT}:
	mkdir -p $(@D)
	wget -c -O $@ ${URL}


# -------------------------------------------------------------------------
# convert to xls ----------------------------------------------------------
# -------------------------------------------------------------------------
${CLEANDAT}: ${RAWDAT}
	soffice --convert-to xls $< --outdir $(@D) --headless


data: ${CLEANDAT}


# -------------------------------------------------------------------------
# plots -------------------------------------------------------------------
# -------------------------------------------------------------------------
${OUTDIR}/report-5-plot-1.svg: R/report-5-plot-1.R ${CLEANDAT}
	${MKDIR}
	${RS}

${OUTDIR}/report-5-plot-2.svg: R/report-5-plot-2.R ${CLEANDAT}
	${MKDIR}
	${RS}

plots: ${OUTDIR}/report-5-plot-1.svg ${OUTDIR}/report-5-plot-2.svg


# -------------------------------------------------------------------------
# report ------------------------------------------------------------------
# -------------------------------------------------------------------------
report/report.html: report/report.qmd ${OUTDIR}/report-5-plot-1.svg ${OUTDIR}/report-5-plot-2.svg
	quarto render $< -P cases:../${OUTDIR}/report-5-plot-1.svg
	xdg-open $@

report: report/report.html


# -------------------------------------------------------------------------
# cleanup -----------------------------------------------------------------
# -------------------------------------------------------------------------
clean:
	rm -f output/*
	rm -f data/clean/*
	rm -f report/report.html
