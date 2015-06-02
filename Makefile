.PHONY:	default analyzer extra pdf clean

default: analyzer

analyzer:
	dartanalyzer --no-hints example/syntax.dart

extra: generated
	pandoc -f markdown_github -s --toc --toc-depth=5 proposal.md \
		-o generated/proposal.html
	pandoc -s -t markdown_github generated/proposal.html \
		-o generated/proposal-from-html.md

pdf:
	pandoc -f markdown_github proposal.md --atx-headers \
		-o generated/proposal.pdf

generated:
	-mkdir generated

clean:
	-@rm .*~ *~ generated/*
	-@rmdir generated

