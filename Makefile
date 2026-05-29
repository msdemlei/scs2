# ivoatex Makefile.  See http://ivoa.net/documents/notes/IVOATexDoc
# for the targets available.

# short name of your document (edit $DOCNAME.tex; would be like RegTAP)
DOCNAME = SCS2

# count up; you probably do not want to bother with versions <1.0
DOCVERSION = 2.0

# Publication date, ISO format; update manually for "releases"
DOCDATE = 2026-05-29

# What is it you're writing: NOTE, WD, PR, REC, PEN, or EN
DOCTYPE = WD

# An e-mail address of the person doing the submission to the document
# repository (can be empty until a make upload is being made)
AUTHOR_EMAIL=msdemlei@ari.uni-heidelberg.de

# Source files for the TeX document (but the main file must always
# be called $(DOCNAME).tex)
SOURCES = $(DOCNAME).tex gitmeta.tex role_diagram.pdf

# List of image files to be included in submitted package (anything that
# can be rendered directly by common web browsers)
FIGURES = role_diagram.svg timeline.tikz.tex

# List of PDF figures (figures that must be converted to pixel images to
# work in web browsers).
VECTORFIGURES = timeline.tikz.svg

# Additional files to distribute (e.g., CSS, schema files, examples...)
AUX_FILES = ConeSearch-v1.1.xsd sample-response.xml sample-record-single.xml

-include ivoatex/Makefile

ivoatex/Makefile:
	@echo "*** ivoatex submodule not found.  Initialising submodules."
	@echo
	git submodule update --init

timeline.tikz.pdf: timeline.tikz.tex
	pdflatex -jobname=timeline.tikz '\documentclass{article}\usepackage[active,tightpage]{preview}\usepackage{chronology}\PreviewEnvironment{chronology}\begin{document}\input '$<'\end{document}'

sample-response.xml:
	curl -s -FRA=145.1 -FDEC=-78.2 -FSR=0.01\
		http://dc.g-vo.org/gaia/q3/cone2/scs2.xml | xmlstarlet fo > $@

sample-record-single.xml:
	curl -s "http://dc.g-vo.org/oai.xml?verb=GetRecord&metadataPrefix=ivo_vor&identifier=ivo://org.gavo.dc/gaia/q3/cone" \
		| xmlstarlet sel --indent -N ri=http://www.ivoa.net/xml/RegistryInterface/v1.0 -t -c //ri:Resource \
		| xmlstarlet fo > $@

STILTS ?= stilts
SCHEMA_FILE=ConeSearch-v1.1.xsd

test:
	@$(STILTS) xsdvalidate $(SCHEMA_FILE)
	@$(STILTS) votlint sample-response.xml
	@$(STILTS) xsdvalidate \
		schemaloc="http://www.ivoa.net/xml/ConeSearch/v1.0=$(SCHEMA_FILE)" \
		sample-record-single.xml
