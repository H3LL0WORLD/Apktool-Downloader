<#
.SYNOPSIS
	Script to download and install Apktool from the official repository
.DESCRIPTION
	Crawl the official repository and search for the latest apktool version and download it
	Optionally:
		Download a wrapper to make your life easier
		Add the directory (extracted from the given target path for apktool) to the PATH environment variable
.PARAMETER TargetPath
	Target path where download apktool to
.PARAMETER DownloadWrapper
	Download the apktool wrapper?
	- "so you don’t have to type java -jar apktool.jar over and over."
.PARAMETER Install
	Add the apktool directory to the PATH environment variable
#>
Param (
	[Parameter(Mandatory = $False, Position = 0)]
	[String] $TargetPath = "$env:HOMEDRIVE\Apktool\Apktool.jar",
	
	[Parameter(Mandatory = $False, Position = 1)]
	[Switch] $DownloadWrapper,
	
	[Parameter(Mandatory = $False, Position = 2)]
	[Switch] $Install
)

# Download links
$ApktoolDownloadsRepository = 'https://bitbucket.org/iBotPeaches/apktool/downloads/'
$ApktoolWrapper = 'https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat'

# Add extension if not provided
if (!$TargetPath.Split('\')[-1].Contains('.')) {
	$TargetPath += '.jar'
}


$Pattern = 'apktool_\d.\d.\d' # Simple regex to match correct lines
$ApktoolVersions = @()
$WebClient = New-Object Net.WebClient

try {
	foreach ($Line in $WebClient.DownloadString($ApktoolDownloadsRepository).Split("`n")) {
		if ($Line -match $Pattern) {
			$ApktoolVersions += New-Object PSObject -Property @{
				Version = [Version][regex]::Matches($Line, $Pattern)[0].Value.Replace('apktool_', '')
				Link = 'https://bitbucket.org' + $Line.Split('"')[1]
			}
		}
	}
} catch {
	Write-Host '[!] There was an error crawling the apktool repository' 
}

# Sort versions and grab the latest one
$Latest = @($ApktoolVersions | Sort -Property Version)[-1]
Write-Host ('[!] Latest version found: ' + $Latest.Version)
Write-Host  '[>] Downloading...'
Write-Host ('[+] From : ' + $Latest.Link)
Write-Host ('[+] To   : ' + $TargetPath)

# If the target directory doesn't exist, create it
$TargetDirectory = Split-Path -Path $TargetPath
if (-not (Test-Path -Path $TargetDirectory)) {
	New-Item -Path $TargetDirectory -ItemType Directory -Force | Out-Null
}

try {
	$Apktool = $WebClient.DownloadFile($Latest.Link, $TargetPath)
	Write-Host '[!] Done'
} catch {
	Write-Host '[!] There was an error downloading apktool :('
}

if ($DownloadWrapper) {
	# Remove the extension from the apktool target path and add .bat instead
	$WrapperTargetPath = $TargetPath.Remove($TargetPath.LastIndexOf('.')) + '.bat'
	Write-Host  '[>] Downloading apktool wrapper...'
	Write-Host ('[+] From : ' + $ApktoolWrapper)
	Write-Host ('[+] To   : ' + $WrapperTargetPath)
	try {
		$Apktool = $WebClient.DownloadFile($ApktoolWrapper, $WrapperTargetPath)
		Write-Host '[!] Done'
	} catch {
		Write-Host '[!] There was an error downloading the apktool wrapper :('
	}
}

if ($Install) {
	<#
	Get the PATH env variable (user level):
	I use this method instead of $env:PATH because there may some cases where
	that variable could be outdated, because that is the "process level" variable
	#>
	$EnvPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
	$ApktoolDirectory = ([IO.FileInfo]$TargetPath).Directory.FullName
	if ($EnvPath.Contains($ApktoolDirectory)) {
		Write-Host '[!] Already added to the PATH environment variable'
	} else {
		Write-Host '[>] Adding it to the PATH environment variable'
		# Update the variable in both process and user "levels"
		[Environment]::SetEnvironmentVariable('Path', "$env:Path;$ApktoolDirectory", 'Process') # Current Process
		[Environment]::SetEnvironmentVariable('Path', "$EnvPath;$ApktoolDirectory", 'User') # Current User
		Write-Host '[!] Done'
	}
}

$WebClient.Dispose()
# That's it :)
