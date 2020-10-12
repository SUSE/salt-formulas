# SUSE Salt Formulas

This repository contains [Salt Formulas](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html) to be shipped for `openSUSE` and `SUSE Linux Enterprise Server`. Formulas can be used with stand-alone Salt or within [Uyuni](https://github.com/uyuni-project/uyuni) / [SUSE Manager](https://www.suse.com/products/suse-manager/) offering UI support for configuration through Pillar data.

## Repository Structure

For each Formula there is a separate directory where the directory name consists of the Formula name and a `-formula` suffix. Each of these directories should be mostly consistent with the [Salt Formulas conventions](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#repository-structure), while additional metadata files (`form.yml`, `metadata.yml`) should go to a separate `metadata` directory, for example:

```
example-formula
|-- example/
|   |-- files/
|   |   |-- foo.conf
|   |-- bar.sls
|   |-- init.sls
|   |-- map.jinja
|-- metadata/
|   |-- form.yml
|   |-- metadata.yml
|-- example-formula.changes
|-- example-formula.spec
|-- LICENSE
|-- README.md
```

## Packaging Information

For information about packaging Formulas as RPM packages (including a `spec` file template) please refer to the [packaging guide](https://github.com/SUSE/salt-formulas/wiki/Packaging-Guide).

## Stable branches

The repository includes stable branches for maintaining bug-fixes of released versions.
When submitting a bug-fix, please consider if it needs a cherry-pick to stable branch,
e.g. `Manager-4.0`.
