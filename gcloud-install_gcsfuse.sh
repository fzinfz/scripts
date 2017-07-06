export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
	echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" |  tee /etc/apt/sources.list.d/gcsfuse.list && \
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add - && \
	apt-get update && \
	apt-get install -y gcsfuse
