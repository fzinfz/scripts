# http://stackoverflow.com/questions/35802939/install-only-available-packages-using-conda-install-yes-file-requirements-t
# one fail, all fail:
# conda install --yes --file requirements.txt

# fix
while read requirement; do conda install --yes $requirement; done < requirements.txt
