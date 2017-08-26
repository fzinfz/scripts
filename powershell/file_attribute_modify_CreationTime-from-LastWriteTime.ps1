$path = Read-Host "./"
pushd $path;
dir  |
foreach{
(Get-Item $_).CreationTime = (Get-Item $_).LastWriteTime
}
