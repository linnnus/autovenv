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
