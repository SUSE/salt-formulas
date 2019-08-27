# SUSE Salt Formulas

This repository contains Salt Formulas to be shipped for `openSUSE` and `SUSE Linux Enterprise Server`. The Formulas can be used with stand-alone Salt or within [Uyuni](https://github.com/uyuni-project/uyuni) / [SUSE Manager](https://www.suse.com/products/suse-manager/) offering UI support for configuring the states.

## Repository Structure

There is a separate directory for each Formula where the directory name consists of the Formula name and a `-formula` suffix. Each of these directories should be mostly consistent with the [Salt Formulas conventions](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#repository-structure), while additional metadata files (`form.yml`, `metadata.yml`) should go to a separate `metadata` directory, for example:

```
foo-formula
|-- foo/
|   |-- files/
|   |   |-- foo.conf
|   |-- bar.sls
|   |-- init.sls
|   |-- map.jinja
|-- metadata/
|   |-- form.yml
|   |-- metadata.yml
|-- foo-formula.changes
|-- foo-formula.spec
|-- LICENSE
|-- README.md
```
