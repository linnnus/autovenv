# FIXME: direnv messes this up
# FIXME: sometimes VIRTUAL_ENV is set when we aren't in virtual env, like with 'nix shell' or subshells (?). maybe use deactivate function as signifier instead?

# Perform an update (leaving, entering, switching virtual environments).
_autovenv_update () {
	env_path="$(_autovenv_find_env_path)"

	if [ -n "$env_path" ]; then
		if _autovenv_in_virtual_env; then
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
		if _autovenv_in_virtual_env; then
			echo "autovenv: leaving virtual environment at $VIRTUAL_ENV"
			deactivate
		fi
	fi
}

# Check wether a virtual environment is currently active.
_autovenv_in_virtual_env () {
	typeset -f deactivate >/dev/null && [ -v VIRTUAL_ENV ]
	return $?
}

_autovenv_post-activate_sanity_check () {
	local env_path="$1"

	# Check that $VIRTUAL_ENV was set.
	if [ ! -v VIRTUAL_ENV ]; then
		cat >&2 <<-EOF
			autovenv: warning: $env_path/bin/activate did not set \$VIRTUAL_ENV.
			The autovenv plugin uses this variable to detect if it's inside a
			virtual environment and won't work without it.
		EOF
		return
	fi

	# Check if activation script has outdated location.
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
		return
	fi

	# Check that deactivate function was defined.
	if ! typeset -f deactivate >/dev/null; then
		cat >&2 <<-EOF
			autovenv: warning: $env_path/bin/activate did not define the shell
			function \`disable\`. The autovenv plugin uses this variable to detect
			if it's inside a virtual environment and won't work without it.
		EOF
		return
	fi
}

# Find closest parent folder that contains a virtual environment.
#
# A directory is said to contain a virtual environment if it contains a child
# directory which contains a file named `pyvenv.cfg`. This function prints the
# name of that child directory.
_autovenv_find_env_path () {
	local dir="$PWD"
	while [ "$dir" != "/" ]; do
		find "$dir" -maxdepth 1 -type d -print0 | while IFS= read -r -d '' subdir; do
			if [ -f "$subdir"/pyvenv.cfg ]; then
				echo "${subdir:P}"
				return
			fi
		done
		dir="${dir:h}"
	done
}

# Update between prompts. This allows us to elegantly handle file system
# changes (as opposed to the chpwd-hook).
add-zsh-hook precmd _autovenv_update
