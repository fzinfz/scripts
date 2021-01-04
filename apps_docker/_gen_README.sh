# generating text for README.md

main(){

echo "# Default Ports"
grep -orP "^\w+_PORT=\d+" | grep -v ipynb | sort | uniq \
    | while read line; do echo "- ${line}"; done \
    | sed "s/:/ : /g"
    
}

main | tee -a README.md