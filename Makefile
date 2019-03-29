
LOCALE_VERSION=0.2
PROMETHEUS_EXPORTERS_VERSION=0.2

locale:: clean
	git archive --format=tar.gz --prefix=locale-formula-${LOCALE_VERSION}/ HEAD:locale/ >locale-formula-${LOCALE_VERSION}.tar.gz

prometheus-exporters:: clean
	git archive --format=tar.gz --prefix=prometheus-exporters-formula-${PROMETHEUS_EXPORTERS_VERSION}/ HEAD:prometheus-exporters-formula/ >prometheus-exporters-formula-${PROMETHEUS_EXPORTERS_VERSION}.tar.gz

clean::
	find . -name "*~" | xargs rm -f
