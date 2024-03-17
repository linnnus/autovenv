Autovenv
========

This repostory contains a ZSH plugin which automatically activates Python
virtual environments when entering their parent directory.

The script `create_examples.sh` can generate some example directories which
also act as test cases. Try doing something like this:

```zsh
source autovenv.plugin.zsh
./create_examples.sh
cd example-basic/
cd ..
```

How it works
-------------

The heart of this plugin is the following table, corresponding to the logic in
`_autovenv_update`.

|                                | No active venv (`deactivate` is unset)\*\* | Active venv (`deactivate` is set)\*\* |
|-------------------------------:|--------------------------------------------|---------------------------------------|
| PWD has virtual environment    | Activate it                                | Switch if they aren't the same\*      |
| PWD has no virtual environment | Do nothing                                 | Deactivate it                         |

\* The path of the virtual environment discovered from `$PWD` is compared to
the one specified by `$VIRTUAL_ENV`. If they are dissimilar, the latter is
deactivated and the former is activated.

\*\* `deactivate` is the shell function which the setup script in `.venv/bin/activate` defines.
We use it as an indicator of whether there is an active virtual environment.
See [this commit][commit-deactivate] if you're curious about why we don't just use `$VIRTUAL_ENV`.

The rest of the logic should be pretty clear from the source code (as clear as
shell script can be, that is).

[commit-deactivate]: https://github.com/linnnus/autovenv/commit/4ee196dbcc834a9343d6aa6dd37e011b8509539f
