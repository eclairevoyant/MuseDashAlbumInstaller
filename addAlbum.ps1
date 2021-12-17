Using module vdf/VdfDeserializer.psm1;

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

# Get Muse Dash's custom albums directory
$_steamDir = Get-ItemPropertyValue Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Valve\Steam -Name InstallPath

$_steamLibraryConfig = $vdf.Deserialize((Get-Content ($_steamDir + "\config\libraryfolders.vdf")));
for ($_i = 0; ; $_i++) {
    if (Get-Member -inputobject $_steamLibraryConfig.libraryfolders.$_i.apps -name $MuseDashAppId -Membertype Properties) {
        break;
    }
}
$_museDashSteamLibPath = $_steamLibraryConfig.libraryfolders.$_i.path
$_museDashSteamLibConfigFile = $_museDashSteamLibPath + "\steamapps\appmanifest_" + $MuseDashAppId + ".acf"
$_museDashSteamLibConfig = $vdf.Deserialize((Get-Content $_museDashSteamLibConfigFile));

$_museDashGamePath = $_museDashSteamLibPath + "\steamapps\common\" + $_museDashSteamLibConfig.AppState.installdir

$_customAlbumsDir = $_museDashGamePath + "\" + $CustomAlbumDirName

# Create the custom albums directory if it doesn't exist
if (!(Test-Path $_customAlbumsDir -PathType Container)) {
    New-Item -ItemType Directory $_customAlbumsDir;
}