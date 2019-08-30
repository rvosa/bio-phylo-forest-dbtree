# =============================================================================
# @file    Makefile
# @brief   Makefile for generating previews of the paper
# @author  Michael Hucka <mhucka@caltech.edu>
# @license Please see the file named LICENSE in the project directory
# @website https://github.com/casics/dassie
# =============================================================================

# Change the following values to match your configuration.
# .............................................................................

input	:= paper.md
output	:= paper.pdf
bib	:= paper.bib

# Main code -- no more customization variables after this point
# .............................................................................

title	:= $(shell grep title: $(input) | sed 's/title: *//' | tr -d "'")
authors := $(shell sed -n '/authors:/,/affiliations:/p' $(input) | grep name: | sed 's/- name: *//' | paste -d, -s - | sed 's/,/, /g')
repo	:= $(shell git remote get-url origin | sed 's|git@github.com:|https://github.com/|' | sed 's/\.git//')

$(output): $(input) $(bib) Makefile
	pandoc \
	-V paper_title="$(title)" \
	-V citation_author="$(authors)" \
	-V graphics="true" \
	-V geometry:margin=1in \
	-o $(output) \
	--pdf-engine=xelatex \
	--filter pandoc-citeproc $(input) \
	--from markdown+autolink_bare_uris \
	--template "whedon/resources/pretty.tex"

autorefresh:;
	((ls $(input) $(bib) | entr make $(output)) &)