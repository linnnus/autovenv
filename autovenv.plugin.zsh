_autovenv_update () {
	env_path="$(_autovenv_find_env_path)"

	if [ -n "$env_path" ]; then
		if [ -v VIRTUAL_ENV ]; then
			if [ "${env_path:P}" != "${VIRTUAL_ENV:P}" ]; then
				echo "autovenv: switching from $env_path -> $VIRTUAL_ENV"
				deactivate
				source "$env_path"/bin/activate
			fi
		else
			echo "autovenv: activating $env_path"
			source "$env_path"/bin/activate
		fi
	else
		if [ -v VIRTUAL_ENV ]; then
			echo "autovenv: leaving virtual environment"
			deactivate
		fi
	fi
}

# Find closest parent folder that contains a virtual environment
# FIXME: more robust path handling
_autovenv_find_env_path () (
	local dir="$PWD"
	while [ "$dir" != "/" ]; do
		for subdir in $(find "$dir" -maxdepth 1 -type d); do
			if [ -f "$subdir"/pyvenv.cfg ]; then
				echo "${subdir:P}"
				return
			fi
		done
		dir="${dir:h}"
	done
)

# add-zsh-hook chpwd  _autovenv_update
add-zsh-hook precmd _autovenv_update
