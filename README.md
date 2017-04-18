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
[installpkg]: https://github.com/boweevil/installpkg
[features_example.txt]: https://github.com/boweevil/configurator/blob/master/features_example.txt
[issue tracker]: https://github.com/boweevil/configurator/issues
[feature template]: https://github.com/boweevil/configurator/tree/master/feature_template
[vundle]: https://github.com/VundleVim/Vundle.vim

## Why?!?!
[Configurator] was created to allow for quick and easy deployment of personal configurations to a new Linux installation.  With this tool there is no need to manually clone multiple repositories, keep them organized, move/copy the files into place, or update the files when changes are made to the repositories.

## Installation
* Clone this repository, <https://github.com/boweevil/configurator>, and navigate to the configurator directory.  I usually create `$HOME/opt` and clone configurator to `$HOME/opt/configurator`.

* Create the file `features.txt` and add the repos you want to install.  Use the [features_example.txt] file as a reference.  For instance, to install my configurations for vim, tmux, & bash, `features.txt` should contain the following:

```
https://boweevil::@github.com/boweevil/configurator-bash.git
https://boweevil::@github.com/boweevil/configurator-tmux.git
https://boweevil::@github.com/boweevil/configurator-vim.git
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

## Creating Your Own Features
Take a look at the [feature template] to implement your own configurator feature.

```
feature_template/
├── config_files.sh
├── custom.sh
├── install.sh
├── mock_config
└── packages
    └── vim.txt
```

The `install.sh` script will do the following:

* Install packages from the packages directory using [installpkg].
* Parse the `config_files.sh` script for the configuration files to link and perform the linking.
* Source the `custom.sh` script to perform any additional tasks.

The `install.sh` script should not be modified.  It is designed to look for what it needs in the `config_files.sh`, `custom.sh` scripts and the `packages` directory.


__Installing packages:__

Any packages required by the feature can be added as text files to the `packages` directory.  For example, to install `vim`, create the file `vim.txt` in the `packages` directory.  The file should look something like this:

```
arch:vim
debian,ubuntu14.04,ubuntu16.04,ubuntu16.10:vim
fedora24,fedora25,el6,el7:vim-enhanced
```

As you can see here, if the package is named similarly across multiple distributions, it is safe to have these on the same or differnt lines.  Distributions should be comma delimited.  The version should be appended to the distro name with no spaces.  For instance, when Ubuntu 20.04 is released, it could be listed as `ubuntu20.04`.  Multiple packages can be listed as space delimited.  For instance the following is for installing the man pages packages.

```
arch:man-db man-pages
debian,ubuntu14.04,ubuntu16.04,ubuntu16.10:man-db manpages manpages-dev
el5,el6:man
fedora24,fedora25,el6,el7:man-db man-pages
```

The short story for how this works is installPkg "greps" for the distro and release number then installs those packages.  See [installpkg] to get a better idea of how this works.


__Installing configuration files:__

`config_files.sh` contains an associative array where the key is the target file and the value is the link which will be created.

```
#!/bin/bash

# The key is the target configration file in the feature directory.
# The value is the path of the symlink for the configuration.
configs=(
  ["${SCRIPT_DIR}"]="$HOME/.vim"
  ["${SCRIPT_DIR}/vimrc"]="$HOME/.vimrc"
)

export configs
```

This will create two symlinks.  One for `~/.vim` and one for `~/.vimrc`.  These will point to the "key" listed in the `config_files.sh` script.  Notice that `~/.vim` will point to the root of the feature.


__Perform custom actions:__

`custom.sh` should be tailored to the feature's needs.  For instance, I configure and run [vundle] when installing my vim configuration.

```
#!/bin/bash

# the following are the additions steps needed by my vim configuration.
# this custom.sh script should be used to execute additional steps other than the linking of configuration files.
plugins_dir="${SCRIPT_DIR}/bundle"

if [ ! -d "${plugins_dir}" ]; then
  mkdir "${plugins_dir}"
fi

if [ ! -d "${plugins_dir}/Vundle.vim" ]; then
  cd "${plugins_dir}" \
    && git clone https://github.com/VundleVim/Vundle.vim.git

  cd "${SCRIPT_DIR}"
fi

vim +PluginInstall +qall

echo "Finished running custom.sh for ${SCRIPT_DIR}."
```

__Final note on creating features:__

Setting up a feature this way allows it to be installed from configurator but it can also be manually installed by simply running the `install.sh` script.

## Feedback

Having issues with [configurator]? Report them in the [issue tracker].
