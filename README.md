Configurator
============

[Configurator] is a tool which installs configurations (features) for things like vim, tmux, & bash.


Features have the following attributes:

 * They are git repos.
 * They contain the configuration for a single application/tool (i.e. `.vimrc` & `.vim` for vim.)
 * They have an `install.sh` script to install the configuration.
 * The `install.sh` script creates links to the configuration files so that any updates to the repos are applied to the user's configuration.  For instance: `/home/boweevil/.vimrc: symbolic link to /home/boweevil/.configurator/vim_vundle/vimrc`

All repoistories are cloned to `$HOME/.configurator/`


[Configurator]: https://github.com/boweevil/configurator
[features_example.txt]: https://github.com/boweevil/configurator/blob/master/features_example.txt
[issue tracker]: https://github.com/boweevil/configurator/issues

## Why?!?!
[Configurator] was created to allow for quick and easy deployment of personal configurations to a new Linux installation.  With this tool there is no need to manually clone multiple repositories, keep them organized, move/copy the files into place, or update the files when changes are made to the repositories.

## Installation
* Clone this repository, <https://github.com/boweevil/configurator>, and navigate to the configurator directory.  I usually create `$HOME/opt` and clone configurator to `$HOME/opt/configurator`.

* Create the file `features.txt` and add the repos you want to install.  Use the [features_example.txt] file as a reference.  For instance, to install my configurations for vim, tmux, & bash, `features.txt` should contain the following:

```
https://boweevil::@bitbucket.org/boweevil/bash.git
https://boweevil::@github.com/boweevil/configurator-tmux.git
https://boweevil::@bitbucket.org/boweevil/vim_vundle.git
```

* Once `features.txt` has been created, you can run the `setup.sh` script to install the listed features.  Running `./setup.sh -i` will parse the `features.txt` file and clone each repository to `$HOME/.configurator/<repo>`.  It will then run the `install.sh` contained in the repo to perform the installation for that feature.

```
Usage: ./setup.sh [ARGUMENTS]...

The following arguments are available.
  -h, --help        Print this help and exit.
  -v, --version     Print the version and exit.
  -i, --install     Install features listed in features.txt.
                    Cannot be used with -u.
  -u, --update      Update all repositories.
                    Cannot be used with -i.

Examples:
./setup.sh -h
./setup.sh -v
./setup.sh -i
./setup.sh -u
```


## Feedback

Having issues with [configurator]? Report them in the [issue tracker].
