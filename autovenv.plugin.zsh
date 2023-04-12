_autovenv_update () {
	env_path="$(_autovenv_find_env_path)"

	if [ -n "$env_path" ]; then
		if [ -v VIRTUAL_ENV ]; then
			if [ "${env_path:P}" != "${VIRTUAL_ENV:P}" ]; then
				echo "autovenv: switching from $VIRTUAL_ENV -> $env_path"
				deactivate
				source "$env_path"/bin/activate
				_autovenv_post-activate_sanity_check "$env_path"
			fi
		else
			echo "autovenv: activating $env_path"
			source "$env_path"/bin/activate
			_autovenv_post-activate_sanity_check "$env_path"
		fi
	else
		if [ -v VIRTUAL_ENV ]; then
			echo "autovenv: leaving virtual environment at $VIRTUAL_ENV"
			deactivate
		fi
	fi
}

_autovenv_post-activate_sanity_check () {
	local env_path="$1"

	# check that VIRTUAL_ENV was set
	if [ ! -v VIRTUAL_ENV ]; then
		cat >&2 <<-EOF
			autovenv: warning: $env_path/bin/activate did not set \$VIRTUAL_ENV.
			The autovenv plugin uses this variable to detect if it's inside a
			virtual environment and won't work without it.
		EOF
	fi

	# check if activation script has outdated location
	if [ "${env_path:P}" != "${VIRTUAL_ENV:P}" ]; then
		cat >&2 <<-EOF
			autovenv: warning: the activation script located at

			    $env_path/bin/activate

			set \$VIRTUAL_ENV to,

			    ${VIRTUAL_ENV:P}

			when the expected value was

			    ${env_path:P}

			If you moved the parent folder after creating the virtual environment,
			you must delete it and create it anew as the activation script still
			thinks it's in the old location. The autovenv plugin will behave
			strangely becuase of this.
		EOF
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
