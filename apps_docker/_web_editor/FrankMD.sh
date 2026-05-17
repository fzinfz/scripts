# https://github.com/akitaonrails/FrankMD
# AI provider: auto, ollama, openrouter, anthropic, gemini, openai

docker run -d --name frankmd -p 87:3000 -p 3000:3000 \
  -e PUID=1000 \
  -e PGID=1000 \
  -v /data/conf/docusaurus/docs:/rails/notes \
  --restart unless-stopped \
  akitaonrails/frankmd:latest