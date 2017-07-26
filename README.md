# Apktool-Downloader
Powershell script to download and install Apktool from the official repository

## Usage:
```powershell
# Make sure we can execute scripts
Set-ExecutionPolicy Unrestricted Process -Force
# Download apktool to default path: $env:HOMEDRIVE\Apktool\Apktool.jar, install it (adding it to PATH environment variable) and also download the wrapper script
.\ApktoolDownloader.ps1 -DownloadWrapper -Install
```
### Output sample:
```
[!] Latest version found: 2.2.3
[>] Downloading...
[+] From : https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.2.3.jar
[+] To   : C:\Apktool\Apktool.jar
[!] Done
[>] Downloading apktool wrapper...
[+] From : https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat
[+] To   : C:\Apktool\Apktool.bat
[!] Done
[!] Already added to the PATH environment variable
```
