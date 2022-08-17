# -------------------------------------------------------------------------
# SETUP -------------------------------------------------------------------
# -------------------------------------------------------------------------
.PHONY: data plots report

# container
CONTAINER = monkeypox
CONTAINERDIR := /${CONTAINER}

# directories
REFDIR := .
RAWDIR := ${REFDIR}/data/raw
CLEANDIR := ${REFDIR}/data/clean
OUTDIR := ${REFDIR}/output
REPORTDIR := ${REFDIR}/report

# url and raw/clean data files
URL := https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1096606/monkeypox-outbreak-technical-briefing-5-data-england-5-august-2022.ods
RAWDAT := ${RAWDIR}/$(notdir ${URL})
CLEANDAT := ${CLEANDIR}/$(basename $(notdir ${RAWDAT})).xls

# -------------------------------------------------------------------------
# helpers -----------------------------------------------------------------
# -------------------------------------------------------------------------

# make directory and parents for target
MKDIR = mkdir -p $(@D)

# use podman and mount volume
PODMAN = podman run --rm -v ${REFDIR}:${CONTAINERDIR}:z ${CONTAINER}

# run Rscript (${RS} myscript.R myinput1 myinput2 etc etc)
RS = Rscript --vanilla $^ $@

# -------------------------------------------------------------------------
# download data -----------------------------------------------------------
# -------------------------------------------------------------------------
${RAWDAT}:
	${MKDIR}
	wget -c -O $@ ${URL}


# -------------------------------------------------------------------------
# convert to xls ----------------------------------------------------------
# -------------------------------------------------------------------------
${CLEANDAT}: ${RAWDAT}
	${PODMAN} soffice --convert-to xls $< --outdir $(@D) --headless

data: ${CLEANDAT}

# -------------------------------------------------------------------------
# plots -------------------------------------------------------------------
# -------------------------------------------------------------------------
${OUTDIR}/report-5-plot-1.svg: R/report-5-plot-1.R ${CLEANDAT}
	${MKDIR}
	${PODMAN} ${RS}

${OUTDIR}/report-5-plot-2.svg: R/report-5-plot-2.R ${CLEANDAT}
	${MKDIR}
	${PODMAN} ${RS}

plots: ${OUTDIR}/report-5-plot-1.svg ${OUTDIR}/report-5-plot-2.svg


# -------------------------------------------------------------------------
# report ------------------------------------------------------------------
# -------------------------------------------------------------------------
report/report.html: report/report.qmd plots
	${PODMAN} quarto render $< -P cases:../${OUTDIR}/report-5-plot-1.svg
	xdg-open $@

report: report/report.html


# -------------------------------------------------------------------------
# cleanup -----------------------------------------------------------------
# -------------------------------------------------------------------------
clean:
	rm -f output/*
	rm -f data/clean/*
	rm -f report/report.html
