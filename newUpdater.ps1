. (Join-Path -Path $PSScriptRoot -ChildPath "utilityFunctions.ps1")

#Script to read config2.json and find if there are updates to Minecraft server plugins on Modrinth
# It will check the version of each server and then check if the plugins are available for that version and if they need upgrading.

$config = Get-Content -Raw -Path "config2.json" | ConvertFrom-Json
$logFilePath = (Join-Path -Path $PSScriptRoot -ChildPath "Errors.log")
$UserAgent = "pturpie's Minecraft server updater"

$config.Plugins | ForEach-Object {
    $currentPlugin = $_
    if ($currentPlugin.Name -eq "xTEMPLATExTEMPLATExTEMPLATExTEMPLATEx" ) {
        #skip this object and continue with next item in the Foreach loop
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
                $latestVersion.files[0].url
                $destinationPath = [IO.Path]::Combine($PSScriptRoot, 'Cache', $currentPlugin.Name, $latestVersion.version_number)
                # does $destinationPath exist? check path and create it if need be.
                if (-not (Test-Path -Path $destinationPath)) {
                    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                    Write-Output ("* Created directory: " + $destinationPath)
                }
                else {
                    #Write-Output ("* Directory already exists: " + $destinationPath)
                }
                $destinationFile = (Join-Path $destinationPath -ChildPath ($currentPlugin.Name + ".jar"))
                if (-not (Test-Path -Path $destinationFile)) {
                    Write-Output (" + Downloading: " + $currentPlugin.Name)
                    DownloadFile -Uri $latestVersion.files[0].url -OutFile $destinationFile -UserAgent $UserAgent
                }
                else {
                    Write-Output (" - plugin version already exists: " + $currentPlugin.Name)
                }

                # loop through $currentPlugin.DestinationServers and check the versions in $config.Servers
                Write-Output (" - Copying $($currentPlugin.Name) to servers")
                foreach ($server in $currentPlugin.DestinationServers) {
                    $serverConfig = $config.Servers | Where-Object { $_.Name -eq $server }
                    if ($serverConfig) {
                        if ($pluginData.game_versions -contains $serverConfig.Version) {
                            Write-Output ("   - Copying to server: " + $server)
                            Copy-Item -Path $destinationFile -Destination (Join-Path -Path $serverConfig.Path -ChildPath "plugins" -AdditionalChildPath ($currentPlugin.Name + ".jar"))
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

                $destinationPath = [IO.Path]::Combine($PSScriptRoot, 'Cache', $currentPlugin.Name, $latestVersion.name)
                # does $destinationPath exist? check path and create it if need be.
                if (-not (Test-Path -Path $destinationPath)) {
                    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                    Write-Output ("* Created directory: " + $destinationPath)
                }
                else {
                    #Write-Output ("* Directory already exists: " + $destinationPath)
                }
                $destinationFile = (Join-Path $destinationPath -ChildPath ($currentPlugin.Name + ".jar"))
                if (-not (Test-Path -Path $destinationFile)) {
                    Write-Output (" + Downloading: " + $currentPlugin.Name)
                    DownloadFile -Uri "http://api.spiget.org/v2/resources/$($currentPlugin.identifier)/download/" -OutFile $destinationFile -UserAgent $UserAgent
                }
                else {
                    Write-Output (" - plugin version already exists: " + $currentPlugin.Name)
                }

                # loop through $currentPlugin.DestinationServers and check the versions in $config.Servers
                Write-Output (" - Copying $($currentPlugin.Name) to servers")
                foreach ($server in $currentPlugin.DestinationServers) {
                    $serverConfig = $config.Servers | Where-Object { $_.Name -eq $server }
                    if ($serverConfig) {
                        if (($pluginData.testedVersions -contains $serverConfig.Version) -or ($currentPlugin.IgnoreVersion -eq $true)) {
                            Write-Output ("   - Copying to server: " + $server)
                            Copy-Item -Path $destinationFile -Destination (Join-Path -Path $serverConfig.Path -ChildPath "plugins" -AdditionalChildPath ($currentPlugin.Name + ".jar"))
                        }
                        else {
                            Write-Output (" ! Plugin is NOT compatible with $server server version: " + $serverConfig.Version)
                            $serverConfig
                            $currentPlugin |Format-List
                        }
                    }
                    else {
                        Write-Output ("*** Server configuration not found for: " + $server)
                    }
                }

            }
            catch {
                Write-Error ("Failed to retrieve plugin data for: " + $currentPlugin.Name + ". Error: " + $_.Exception.Message)
                $currentPlugin
                Add-Content -Path $logFilePath -Value ("Failed to retrieve plugin data for: " + $currentPlugin.Name + ". Error: " + $_.Exception.Message)
            }
        }
        "GitHub"{

        }
        Default {
            Write-Output "#######################################################"
            Write-Output "  TODO: write handler for $($currentPlugin.Source)"
        }
    }
    #break
}