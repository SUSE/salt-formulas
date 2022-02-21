
LOCALE_VERSION=0.2
CPU_MITIGATIONS_VERSION=0.4.0
PROMETHEUS_VERSION=0.6.0
PROMETHEUS_EXPORTERS_VERSION=1.1.0
GRAFANA_VERSION=0.7.0
VIRTUALIZATION_VERSION=0.6.1
SYSTEM_LOCK_VERSION=0.1
UYUNI_CONFIG_VERSION=0.2

locale:: clean
	git archive --format=tar.gz --prefix=locale-formula-${LOCALE_VERSION}/ HEAD:locale-formula/ >locale-formula-${LOCALE_VERSION}.tar.gz

cpu-mitigations:: clean
	git archive --format=tar.gz --prefix=cpu-mitigations-formula-${CPU_MITIGATIONS_VERSION}/ HEAD:cpu-mitigations-formula/ >cpu-mitigations-formula-${CPU_MITIGATIONS_VERSION}.tar.gz

prometheus:: clean
	git archive --format=tar.gz --prefix=prometheus-formula-${PROMETHEUS_VERSION}/ HEAD:prometheus-formula/ >prometheus-formula-${PROMETHEUS_VERSION}.tar.gz

prometheus-exporters:: clean
	git archive --format=tar.gz --prefix=prometheus-exporters-formula-${PROMETHEUS_EXPORTERS_VERSION}/ HEAD:prometheus-exporters-formula/ >prometheus-exporters-formula-${PROMETHEUS_EXPORTERS_VERSION}.tar.gz

grafana:: clean
	git archive --format=tar.gz --prefix=grafana-formula-${GRAFANA_VERSION}/ HEAD:grafana-formula/ >grafana-formula-${GRAFANA_VERSION}.tar.gz

virtualization:: clean
	git archive --format=tar.gz --prefix=virtualization-formulas-${VIRTUALIZATION_VERSION}/ HEAD:virtualization-formulas/ >virtualization-formulas-${VIRTUALIZATION_VERSION}.tar.gz

system-lock:: clean
	git archive --format=tar.gz --prefix=system-lock-formula-${SYSTEM_LOCK_VERSION}/ HEAD:system-lock-formula/ >system-lock-formula-${SYSTEM_LOCK_VERSION}.tar.gz

uyuni-config:: clean
	git archive --format=tar.gz --prefix=uyuni-config-formula-${UYUNI_CONFIG_VERSION}/ HEAD:uyuni-config-formula/ >uyuni-config-formula-${UYUNI_CONFIG_VERSION}.tar.gz

clean::
	find . -name "*~" | xargs rm -f
