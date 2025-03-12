. (Join-Path -Path $PSScriptRoot -ChildPath "utilityFunctions.ps1")

$ServerUpdates = Get-Content -Raw -Path "/home/pault/mctools/updates/serverupdates.json" | ConvertFrom-Json
$downloadPath = "/home/pault/mctools/updates/servers/"
$UserAgent = "pturpie's Minecraft server updater"
$ProgressPreference = 'SilentlyContinue'

Write-Host "########################################################################"
Write-Host "######## Updating PaperMC, BungeeCord and BungeeCord plugins ###########"
Write-Host "########################################################################"


Write-Host "******** Discovering Latest PaperMC download due to v2 API being crapper than the nice v1 API ***********"
$PClatestVersion = (Invoke-RestMethod -Uri "https://papermc.io/api/v2/projects/paper").versions[-1]
$PClatestVersion = "1.20.1"
$PClatestBuild = (Invoke-RestMethod -Uri "https://papermc.io/api/v2/projects/paper/versions/$PClatestVersion").builds[-1]
$PClatestDownload = (Invoke-RestMethod -Uri "https://papermc.io/api/v2/projects/paper/versions/$PClatestVersion/builds/$PClatestBuild").downloads.application.name
$PClatestDownloadURL = "https://papermc.io/api/v2/projects/paper/versions/$PClatestVersion/builds/$PClatestBuild/downloads/$PClatestDownload"
$PClatestDownloadURL
($ServerUpdates | Where-Object Name -EQ "PaperMC").URL = $PClatestDownloadURL

Write-Host "******** Discovering Latest LuckPerms url ***********"
$URL = "https://ci.lucko.me/view/LuckPerms/job/LuckPerms/lastSuccessfulBuild/"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $URL
$URL = ($WebResponse.Links | Where-Object { $_.href -match "LuckPerms-Bungee" } | Select-Object -First 1).href
($ServerUpdates | Where-Object Name -EQ "LuckPerms").URL = "https://ci.lucko.me/view/LuckPerms/job/LuckPerms/lastSuccessfulBuild/" + $URL
($ServerUpdates | Where-Object Name -EQ "LuckPerms").URL

Write-Host "******** Updating Server jars ***********"
$ServerUpdates.GetEnumerator() | ForEach-Object {
    Write-Host "Updating:" $_.Name
    $OutFile = $downloadPath + $_.Name + ".jar"
    $downloaded = DownloadFile -UserAgent $UserAgent -Uri $_.URL -OutFile $OutFile -name $_.Name
    if ($downloaded) {
        $_.Destinations | ForEach-Object {
            Write-Host "    Copying to:" $_
            Copy-Item -Path $OutFile -Destination $_
        }
    }
}


# Manually get BungeeTabListPlus
$Name = "BungeeTabListPlus"
Write-Host "Updating:" $_.Name
$URL = "https://api.spiget.org/v2/resources/313/download"
$OutFile = $downloadPath + "BungeeTabListPlus.zip"
DownloadFile -UserAgent $UserAgent -Uri $URL -OutFile $OutFile -name $Name
Expand-Archive -LiteralPath $OutFile -DestinationPath $downloadPath -Force
Write-Host "     Copying : BungeeTabListPlus plugin for BungeeCord"
Copy-Item -Path "BungeeTabListPlus-*.jar" -Destination "/var/games/minecraft/servers/bungeecord/plugins/BungeeTabListPlus.jar"
Copy-Item -Path "BungeeTabListPlus-*.jar" -Destination "/var/games/minecraft/servers/bungeecordAuth/plugins/BungeeTabListPlus.jar"
Write-Host "     Copying : BungeeTabListPlus bridge plugin for MineCraft server"
Copy-Item -Path "BungeeTabListPlus_BukkitBridge*" -Destination "/home/pault/mctools/updates/plugins/BungeeTabListPlus_BukkitBridge.jar"

<#
# Manual Steps
echo * Plan plugin updated in the other plugin script
#>
