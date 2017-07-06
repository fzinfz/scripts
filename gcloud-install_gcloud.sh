set -e

apt install -y python-dev || yum install -y python-dev

curl https://sdk.cloud.google.com | bash
export PATH="/root/google-cloud-sdk/bin/:$PATH"

gcloud auth application-default login
