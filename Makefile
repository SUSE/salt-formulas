
LOCALE_VERSION=0.2
CPU_MITIGATIONS_VERSION=0.1
PROMETHEUS_EXPORTERS_VERSION=0.3
VIRTUALIZATION_HOST_VERSION=0.1

locale:: clean
	git archive --format=tar.gz --prefix=locale-formula-${LOCALE_VERSION}/ HEAD:locale/ >locale-formula-${LOCALE_VERSION}.tar.gz

cpu-mitigations:: clean
	git archive --format=tar.gz --prefix=cpu-mitigations-formula-${CPU_MITIGATIONS_VERSION}/ HEAD:cpu-mitigations-formula/ >cpu-mitigations-formula-${CPU_MITIGATIONS_VERSION}.tar.gz

prometheus-exporters:: clean
	git archive --format=tar.gz --prefix=prometheus-exporters-formula-${PROMETHEUS_EXPORTERS_VERSION}/ HEAD:prometheus-exporters-formula/ >prometheus-exporters-formula-${PROMETHEUS_EXPORTERS_VERSION}.tar.gz

virtualization-host:: clean
	git archive --format=tar.gz --prefix=virtualization-host-formula-${VIRTUALIZATION_HOST_VERSION}/ HEAD:virtualization-host-formula/ >virtualization-host-formula-${VIRTUALIZATION_HOST_VERSION}.tar.gz

clean::
	find . -name "*~" | xargs rm -f
