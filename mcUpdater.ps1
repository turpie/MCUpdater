. (Join-Path -Path $PSScriptRoot -ChildPath "utilityFunctions.ps1")

#Script to read config2.json and find if there are updates to Minecraft server plugins on Modrinth
# It will check the version of each server and then check if the plugins are available for that version and if they need upgrading.

$config = Get-Content -Raw -Path "config2.json" | ConvertFrom-Json
$logFilePath = (Join-Path -Path $PSScriptRoot -ChildPath "Errors.log")
$UserAgent = "pturpie's MC server updater"

function Get-Plugin {
    param (
        [string]$name,
        [string]$url,
        [array]$testedVersions,
        [array]$destinationServers,
        [bool]$IgnoreVersion
    )

    $destinationPath = [IO.Path]::Combine($PSScriptRoot, 'Cache', $name, $latestVersion.version_number)
    if (-not (Test-Path -Path $destinationPath)) {
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
        Write-Output ("* Created directory: " + $destinationPath)
    }
    $destinationFile = (Join-Path $destinationPath -ChildPath ($name + ".jar"))
    if (-not (Test-Path -Path $destinationFile)) {
        Write-Output (" + Downloading: " + $name)
        DownloadFile -Uri $url -OutFile $destinationFile -UserAgent $UserAgent
    }
    else {
        Write-Output (" - plugin version already exists: " + $name)
    }

    Write-Output (" - Copying $name to servers")
    foreach ($server in $destinationServers) {
        $serverConfig = $config.Servers | Where-Object { $_.Name -eq $server }
        if ($serverConfig) {
            if (($testedVersions -contains $serverConfig.Version) -or ($IgnoreVersion -eq $true)) {
                Write-Output ("   - Copying to server: " + $server)
                Copy-Item -Path $destinationFile -Destination (Join-Path -Path $serverConfig.Path -ChildPath "plugins" -AdditionalChildPath ($name + ".jar"))
            }
            else {
                Write-Output (" ! Plugin is NOT compatible with $server server version: " + $serverConfig.Version)
            }
        }
        else {
            Write-Output ("*** Server configuration not found for: " + $server)
        }
    }
}

$config.Plugins | ForEach-Object {
    $currentPlugin = $_

    if ($currentPlugin.IgnoreVersion) {
        $IgnoreVersion = $true
    }else{
        $IgnoreVersion = $false
    }
    if ($currentPlugin.Name -eq "xTEMPLATExTEMPLATExTEMPLATExTEMPLATEx") {
        break
    }
    Write-Output "--------------------------------------------------------------------------------------"
    Write-Output ("* Checking plugin:" + $currentPlugin.Name)
    switch ($currentPlugin.Source) {
        "Modrinth" {
            try {
                $pluginData = Invoke-RestMethod -Uri ("https://api.modrinth.com/v2/project/" + $currentPlugin.identifier)
                Write-Output (" - Plugin data retrieved: ")
                $pluginData | Select-Object title, game_versions | Format-List

                $version = Invoke-RestMethod -Uri ("https://api.modrinth.com/v2/project/" + $currentPlugin.identifier + "/version")
                $latestVersion = $version | Where-Object { $_.loaders -contains "paper" } | Sort-Object -Property version_number -Descending | Select-Object -First 1

                Download-Plugin -name $currentPlugin.Name -url $latestVersion.files[0].url -testedVersions $pluginData.game_versions -destinationServers $currentPlugin.DestinationServers -IgnoreVersion $IgnoreVersion
            }
            catch {
                Write-Error ("Failed to retrieve plugin data for: " + $currentPlugin.Name + ". Error: " + $_.Exception.Message)
                $currentPlugin
                Add-Content -Path $logFilePath -Value ("Failed to retrieve plugin data for: " + $currentPlugin.Name + ". Error: " + $_.Exception.Message)
            }
        }
        "Spigot" {
            Write-Output "Spigot/Spiget"
            try {
                $pluginData = Invoke-RestMethod -Uri ("http://api.spiget.org/v2/resources/$($currentPlugin.identifier)")
                Write-Output (" - Plugin data retrieved: ")
                $pluginData | Select-Object title, testedVersions | Format-List
                $version = Invoke-RestMethod -Uri "https://api.spiget.org/v2/resources/$($currentPlugin.identifier)/versions?size=99&sort=%2B"
                $latestVersion = $version | Sort-Object releasedate | Select-Object -Last 1

                Download-Plugin -name $currentPlugin.Name -url "http://api.spiget.org/v2/resources/$($currentPlugin.identifier)/download/" -testedVersions $pluginData.testedVersions -destinationServers $currentPlugin.DestinationServers -IgnoreVersion $IgnoreVersion
            }
            catch {
                Write-Error ("Failed to retrieve plugin data for: " + $currentPlugin.Name + ". Error: " + $_.Exception.Message)
                $currentPlugin
                Add-Content -Path $logFilePath -Value ("Failed to retrieve plugin data for: " + $currentPlugin.Name + ". Error: " + $_.Exception.Message)
            }
        }
        "GitHub" {
            # Handle GitHub source
        }
        Default {
            Write-Output "#######################################################"
            Write-Output "  TODO: write handler for $($currentPlugin.Source)"
            Write-Output "#######################################################"
        }
    }
}