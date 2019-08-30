#!/bin/bash

MS=paper.md
BIB=paper.bib

# variables for whedon / JOSS
latex_template_path=template.tex
csl_file=apa.csl

# TODO: Sanitize all the things!
# paper_title=paper.title.gsub!('_', '\_')
# plain_title=paper.plain_title.gsub('_', '\_').gsub('#', '\#')
paper_year ||= Time.now.strftime('%Y')
paper_issue ||= @current_issue
paper_volume ||= @current_volume
# FIXME - when the JOSS application has an actual API this could/should cleaned up
submitted = `curl #{ENV['JOURNAL_URL']}/papers/lookup/#{@review_issue_id}`
published = Time.now.strftime('%d %B %Y')

# TODO: may eventually want to swap out the latex template
pandoc \
      -V repository="#{repository_address}" \
      -V archive_doi="#{archive_doi}" \
      -V paper_url="#{paper.pdf_url}" \
      -V journal_name='#{ENV['JOURNAL_NAME']}' \
      -V formatted_doi="#{paper.formatted_doi}" \
      -V review_issue_url="#{paper.review_issue_url}" \
      -V graphics="true" \
      -V issue="#{paper_issue}" \
      -V volume="#{paper_volume}" \
      -V page="#{paper.review_issue_id}" \
      -V logo_path="#{Whedon.resources}/#{ENV['JOURNAL_ALIAS']}-logo.png" \
      -V year="#{paper_year}" \
      -V submitted="#{submitted}" \
      -V published="#{published}" \
      -V formatted_doi="#{paper.formatted_doi}" \
      -V citation_author="#{paper.citation_author}" \
      -V paper_title='#{paper.title}' \
      -V footnote_paper_title='#{plain_title}' \
      -o paper.pdf -V geometry:margin=1in \
      --pdf-engine=xelatex \
      --filter pandoc-citeproc #{File.basename(paper.paper_path)} \
      --from markdown+autolink_bare_uris \
      --csl=$csl_file \
      --template $latex_template_path
