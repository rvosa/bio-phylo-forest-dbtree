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
pretty: $(input) $(bib) Makefile
	pandoc \
	-V graphics="true" \
	-V geometry:margin=1in \
	-o $(output) \
	--pdf-engine=xelatex \
	--filter pandoc-citeproc $(input) \
	--from markdown+autolink_bare_uris+superscript+tex_math_dollars \
	--template "whedon/resources/pretty.tex"

review: $(input) $(bib) Makefile
	pandoc \
	-V graphics="true" \
	-V geometry:margin=1in \
	-o $(output) \
	--pdf-engine=xelatex \
	--filter pandoc-citeproc $(input) \
	--from markdown+autolink_bare_uris+superscript+tex_math_dollars \
	--template "whedon/resources/review.tex"

autorefresh:;
	((ls $(input) $(bib) | entr make $(output)) &)