py_pip_install--packages--proxy--port() {
    pip install $1 --proxy http://$2:$3
}

conda_env_create--env() {
    conda create -y --name $1
    source activate $1
}

pypi_upload_test() {
    echo doc: https://packaging.python.org/tutorials/distributing-packages/
    twine upload --repository testpypi dist/*
}


py_install---requirements.txt() {

# http://stackoverflow.com/questions/35802939/install-only-available-packages-using-conda-install-yes-file-requirements-t
# one fails, all fail:
# conda install --yes --file requirements.txt

# fix

    if [ -z ${1+x} ]; then
      file=requirements.txt
     else
      file=$1
    fi

    while read requirement; do conda install --yes $requirement; done < $file
    while read requirement; do pip install $requirement; done < $file

}