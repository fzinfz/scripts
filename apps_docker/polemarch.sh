docker run -d --name polemarch --net host --restart always \
  -v polemarch_projects:/projects -v polemarch_hooks:/hooks \
  vstconsulting/polemarch

