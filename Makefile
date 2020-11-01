# NOTE: not necessary when using vimtex
fname=main
${fname}.pdf: ${fname}.tex \
	00_abstract/abstract.tex \
	00_acknowledgments/acknowledgments.tex \
	00_committee/committee.tex \
	01_intro_chapter/intro_chapter.tex \
	01_intro_chapter/intro_chapter.bib \
	02_abf_background/abf_background.tex \
	02_abf_background/abf_background.bib \
	99_conclusion_chapter/conclusion_chapter.tex \
	99_conclusion_chapter/conclusion_chapter.bib
	if [ -e ${fname}.aux ]; \
	then \
	rm ${fname}.aux; \
	fi;
	pdflatex ${fname}
	bibtex ${fname}
	bibtex ${fname}1-blx
	bibtex ${fname}2-blx
	bibtex ${fname}3-blx
	# Add more if you have more chapters
	pdflatex ${fname}
clean:
	rm -f *.aux
	rm -f */*.aux
	rm -f *.bbl
	rm -f *.blg
	rm -f *.fls
	rm -f *.lof
	rm -f *.log
	rm -f *.lot
	rm -f *.toc
	rm -f *-blx.bib
	rm -f *.out
	rm -f *.run.xml
	rm -f pdfa.xmpi
	rm -f *.fdb_latexmk
	rm -f '${fname}.synctex(busy)'
	rm -f *.synctex.gz
	rm -f ${fname}.pdf
