. ./bash-lib

chmod +x bash*

remove_not_existing_path ~/.bashrc
remove_not_existing_path ~/.bash_profile
echo

#################################

echo_title ~/.bashrc
# Non-Login / after the login process / bash sub-shell
# Aliases are not inherited by sub-shells

enable_ls_color

add_source_file bashrc

echo_cyan $(linesep -)
grep -vE '^\s*(#|$)' ~/.bashrc
echo_cyan $(linesep -)

#################################

echo_title ~/.bash_profile
# Login Shells : env

add_source_file bash_profile

echo_magenta $(linesep -)
grep -vE '^\s*(#|$)' ~/.bash_profile
echo_magenta $(linesep -)