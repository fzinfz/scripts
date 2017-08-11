# http://stackoverflow.com/questions/35802939/install-only-available-packages-using-conda-install-yes-file-requirements-t
# one fails, all fail:
# conda install --yes --file requirements.txt

# fix
while read requirement; do conda install --yes $requirement; done < requirements.txt
while read requirement; do pip install $requirement; done < requirements.txt
