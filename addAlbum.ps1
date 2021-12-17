Using module vdf/VdfDeserializer.psm1;

if ($args.length -eq 0) {
	throw "At least one file must be specified";
}

# Constants
if (!(Test-Path variable:Vdf)) {
	Set-Variable Vdf -Option Constant -Value ([VdfDeserializer]::new());
}
if (!(Test-Path variable:MuseDashAppId)) {
	Set-Variable MuseDashAppId -Option Constant -Value 774171;
}
if (!(Test-Path variable:CustomAlbumDirName)) {
	Set-Variable CustomAlbumDirName -Option Constant -Value "Custom_Albums";
}
if (!(Test-Path variable:ChartExtension)) {
	Set-Variable ChartExtension -Option Constant -Value ".mdm";
}

# Get Muse Dash's custom albums directory
$_steamDir = Get-ItemPropertyValue Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam -Name InstallPath;

$_steamLibraryConfig = $vdf.Deserialize((Get-Content ($_steamDir + "\config\libraryfolders.vdf")));
for ($_i = 0; ; $_i++) {
	if (Get-Member -inputobject $_steamLibraryConfig.libraryfolders.$_i.apps -name $MuseDashAppId -Membertype Properties) {
		break;
	}
}
$_museDashSteamLibPath = $_steamLibraryConfig.libraryfolders.$_i.path.replace("\\", "\");
$_museDashSteamLibConfigFile = $_museDashSteamLibPath + "\steamapps\appmanifest_" + $MuseDashAppId + ".acf";
$_museDashSteamLibConfig = $vdf.Deserialize((Get-Content $_museDashSteamLibConfigFile));

$_museDashGamePath = $_museDashSteamLibPath + "\steamapps\common\" + $_museDashSteamLibConfig.AppState.installdir;

$_customAlbumsDir = $_museDashGamePath + "\" + $CustomAlbumDirName;

Write-Information ("Album directory: " + $_customAlbumsDir);

# Create the custom albums directory if it doesn't exist
if (!(Test-Path $_customAlbumsDir -PathType Container)) {
	New-Item -ItemType Directory $_customAlbumsDir | Out-Null;
	Write-Debug "Created Custom_Albums folder";
}

# Copy all files specified in cmd args to the custom album folder
foreach ($_arg in $args) {
	# TODO add support for copying folders?
	# TODO check if it's a true zip file
	# TODO check zip contents for required files

	if (!(Test-Path $_arg -PathType Leaf)) {
		Write-Error ($_arg + " does not exist");
		continue;
	}

	if ($ChartExtension -ne [System.IO.Path]::GetExtension($_arg) ) {
		Write-Error ($_arg + " should have .mdm extension");
		continue;
	}

	Copy-Item $_arg $_customAlbumsDir;
	Write-Debug ("Copied " + $_arg);
}