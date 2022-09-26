# generating text for README.md

leading_str="# Default Ports"

gen_text_ports(){    
    echo $leading_str
    grep -orP "^\w+_PORT=\d+" | grep -v ipynb | sort | uniq \
        | while read line; do echo "- ${line}"; done \
        | sed "s/:/ : /g"    
}

main(){
    perl -ne "print if 1 .. /$leading_str/" README.md  | head -n -1
    gen_text_ports
}

main >README.md.tmp
mv README.md.tmp README.md