# Usage for shell functions and alias

    [ -f ./init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"
    [ -f ./init.sh ] && my_functions && alias 

## Naming rules
`--`: followed by required parameter  
`---`: followed by optional parameter
Not working for `sh`, will remove!

# nbviewer
http://nbviewer.jupyter.org/github/fzinfz/scripts/tree/master/python/

# Folders
`docs`: Web code snippets ([Preview](https://html.ferro.pro/))  
`fork`: 3rd party code  

# Tools in `doc` folder
Plain Text or HTML Table To Markdown converter: https://html.ferro.pro/md.html
