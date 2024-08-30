#!/bin/bash

function detect_shell(){
	if [ -n "$BASH_VERSION" ]; then
		echo "bash"
	elif [ -n "$ZSH_VERSION" ]; then
		echo "zsh"
	else
		echo ""
	fi
}

function get_env_value(){
	local name="$1"
	local current_shell=$(detect_shell)

	if [ "$current_shell" = "bash" ] || [ -z "$current_shell" ]; then
		echo "${!name}"
	elif [ "$current_shell" = "zsh" ]; then
		echo "${(P)name}"
	fi
}

function env_push_front() {
    local env_var_name="$1"
    local new_value="$2"
    local env_var_old_value=$(get_env_value $env_var_name)

    if [[ -z "$env_var_old_value" ]]; then
        export "$env_var_name=$new_value"
    else
        export "$env_var_name=$new_value:$env_var_old_value"
    fi
}

function export_toolchains(){
	local directory="$1"

	for dir in "$directory"/*/; do
		if [ -d "$dir/bin" ]; then
			export PATH="$dir/bin:$PATH"
			env_push_front PATH "$dir/bin"
			env_push_front LD_LIBRARY_PATH "$dir/lib64"
			env_push_front LD_LIBRARY_PATH "$dir/lib"
		fi
	done
}

# gcc_toolchains
export_toolchains "$TOOLCHAINSPATH/x86_64-pc-linux-gnu/"
# clang
export_toolchains "$TOOLCHAINSPATH/llvm/x86_64-generic-linux-gnu"

env_push_front PATH "$HOME/softwares/wine/x86_64-pc-linux-gnu/wine/bin"