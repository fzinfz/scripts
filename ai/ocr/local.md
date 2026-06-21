如果图片不在 `OCR_WORKDIR` 下，则退化为只保留文件名。

PowerShell 运行示例：

```powershell
$env:OCR_WORKDIR = "G:\_images"
$env:OCR_DIR_LIST = "G:\_images\OCR.TXT"
$env:OCR_OUTPUT = "G:\_images\OCR"
$env:AI_LOCAL_URL = "http://192.168.88.162:1234/v1"
uv run local.py
```
