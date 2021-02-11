sed_replace_1st_line--NewStr--file(){ run "sed -i '1c\\$1' $2" ; }

# https://stackoverflow.com/questions/1935081/remove-leading-whitespace-from-file
sed_rm_top_blanks--file(){ run "sed -i '/./,\$!d' $1" ; }