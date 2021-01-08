#!/usr/bin/python3

import json
import shutil
from pathlib import Path

pillar_paths = [Path('/srv/susemanager/formula_data/pillar'),
                Path('/srv/susemanager/formula_data/group_pillar')]
v1_keys = {'node_exporter', 'apache_exporter', 'postgres_exporter'}


class Migration:
    def __init__(self, path, filename):
        self.filepath = path / filename
        self.data = None

    def parse(self):
        with open(self.filepath) as formula_data:
            self.data = json.load(formula_data)

    def identify_schema_version(self):
        if set(self.data.keys()) & v1_keys:
            return 1
        else:
            return 0

    # move `v1_keys` objects to `exporters` dictionary
    def migrate_from_version_1(self):
        exporters = self.data['exporters'] = {}
        for exporter in v1_keys:
            exporters[exporter] = self.data.pop(exporter)

    def migrate(self):
        self.parse()
        schema_version = self.identify_schema_version()

        if schema_version > 0:
            shutil.copy2(self.filepath, self.filepath.with_suffix(
                '.v{0}'.format(schema_version)))
            if schema_version == 1:
                self.migrate_from_version_1()
            with open(self.filepath, 'w') as output:
                json.dump(self.data, output)


# Find all prometheus-exporters formula data files and migrate them to the
# current schema. Old versions stored for backup.
for pillar_path in pillar_paths:
    if pillar_path.exists():
        for formula_data_filename in pillar_path.iterdir():
            if formula_data_filename.name.endswith(
                    '_prometheus-exporters.json'):
                Migration(pillar_path, formula_data_filename).migrate()
