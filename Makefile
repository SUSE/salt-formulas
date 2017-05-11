
LOCALE_VERSION=0.2


locale:: clean
	git archive --format=tar.gz --prefix=locale-formula-${LOCALE_VERSION}/ HEAD:locale/ >locale-formula-${LOCALE_VERSION}.tar.gz

clean::
	find . -name "*~" | xargs rm -f
