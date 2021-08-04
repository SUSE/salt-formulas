#!/usr/bin/python3

from collections import MutableMapping
import json
from pathlib import Path
import shutil


pillar_paths = [Path('/srv/susemanager/formula_data/pillar'),
                Path('/srv/susemanager/formula_data/group_pillar')]
v05_keys = {'proxy_enabled', 'proxy_port'}
v1_keys = {'node_exporter', 'apache_exporter', 'postgres_exporter'}


class Migration:
    def __init__(self, path, filename):
        self.filepath = path / filename
        self.data = None

    def parse(self):
        with open(self.filepath) as formula_data:
            self.data = json.load(formula_data)

    def identify_schema_version(self):
        # schema 0.5 has no proxy support
        if set(self.data.keys()) & v05_keys != v05_keys:
            return 0.5
        # schema 1 has exporter names as keys
        if set(self.data.keys()) & v1_keys:
            return 1
        else:
            return 0

    # set default values for proxy configuration
    def migrate_from_version_05(self):
        if 'proxy_enabled' not in self.data:
            self.data['proxy_enabled'] = False
        if 'proxy_port' not in self.data:
            self.data['proxy_port'] = 9999

    # move `v1_keys` objects to `exporters` dictionary
    def migrate_from_version_1(self):
        exporters = self.data['exporters'] = {}
        for exporter in v1_keys:
            if exporter in self.data:
                exporters[exporter] = self.data.pop(exporter)

    def fix_schema(self):
        none_value_to_empty_string(self.data)

    def migrate(self):
        schema_version = self.identify_schema_version()

        if schema_version > 0:
            shutil.copy2(self.filepath, self.filepath.with_suffix(
                '.v{0}'.format(schema_version)))
            if schema_version <= 0.5:
                self.migrate_from_version_05()
            if schema_version <= 1:
                self.migrate_from_version_1()

    def dump(self):
        with open(self.filepath, 'w') as output:
            json.dump(self.data, output)


def none_value_to_empty_string(data):
    if isinstance(data, MutableMapping):
        for k, v in data.items():
            if v is None:
                data[k] = ''
            else:
                none_value_to_empty_string(v)


# Find all prometheus-exporters formula data files and migrate them to the
# current schema. Old versions stored for backup.
for pillar_path in pillar_paths:
    if pillar_path.exists():
        for formula_data_filename in pillar_path.iterdir():
            if formula_data_filename.name.endswith(
                    '_prometheus-exporters.json'):
                formula_migration = Migration(pillar_path,
                                              formula_data_filename)
                formula_migration.parse()
                formula_migration.fix_schema()
                formula_migration.migrate()
                formula_migration.dump()
