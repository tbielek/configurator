Configurator
============

Create the file `features.txt` and add the repos you want to install.  Use the `features_example.txt` as a reference.

```
Usage: ./setup.sh [ARGUMENTS]...

The following arguments are available.
  -h, --help        Print this help and exit.
  -v, --version     Print the version and exit.
  -i, --install     Install features from ${features_file}.
                    Cannot be used with -u.
  -u, --update      Update all repositories.
                    Cannot be used with -i.

Examples:
${SCRIPT_NAME} -h
${SCRIPT_NAME} -v
${SCRIPT_NAME} -i
${SCRIPT_NAME} -u
```

