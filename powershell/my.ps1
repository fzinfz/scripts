if (!(Test-Path $PROFILE.CurrentUserCurrentHost)){
    $folder_CurrentUserCurrentHost = Split-Path -parent $PROFILE.CurrentUserCurrentHost
    New-Item -ItemType Directory -Force -Path $folder_CurrentUserCurrentHost
    Copy-Item *profile.ps1 -Destination $folder_CurrentUserCurrentHost
}
dir $PROFILE.CurrentUserCurrentHost

. .\EnvPath.lib.ps1
Add-EnvPath  D:\sdk\flutter\bin

. .\check_env.ps1


