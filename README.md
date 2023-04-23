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

|                                | No active venv (`$VIRTUAL_ENV` is unset) | Active venv (`$VIRTUAL_ENV` is set) |
|-------------------------------:|------------------------------------------|-------------------------------------|
| PWD has virtual environment    | Activate it                              | Switch if they aren't the same      |
| PWD has no virtual environment | Do nothing                               | Deactivate it                       |

The rest of the logic should be pretty clear from the source code (as clear as
shell script can be, that is).
