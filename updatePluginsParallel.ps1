. (Join-Path -Path $PSScriptRoot -ChildPath "utilityFunctions.ps1")

$downloadPath = "/home/pault/mctools/updates/plugins/"
#$serverBasePath = "/var/games/minecraft/servers/"
$serverBasePathCrafty = "/var/opt/minecraft/crafty/crafty-4/servers/"
$UserAgent = "pturpie's Minecraft server updater"

Write-Host "#################################################################"
Write-Host "######## Updating Plugins for PaperMC                 ###########"
Write-Host "######## and some miscellaneous BungeeCord plugins    ###########"
Write-Host "#################################################################"


# TODO
# WorldGuard downloads, stable blocked by CAPTCHA on bukkit.org
#
# Note:
#     WorldBorder is no longer being updated.

$servers = @{
    "lobby"   = $serverBasePathCrafty + "9cee508d-347d-4c3c-a6e4-163541f9eba3"
    #"survival"  = "survival"
    #"survival2" = $serverBasePath + "survival2"
    #"creative"  = "creative"
    #"original"  = "original"
    #"Factions"  = "Factions"
    #"smp"       = "smp"
    #"smp2"      = $serverBasePath + "smp2"
    #"smp3"      = $serverBasePath + "smp3"
    #"smp4"      = $serverBasePath + "smp4"
    "smp2022" = $serverBasePathCrafty + "f2dffe4e-5aed-47a0-80f6-4edbf7350a6b"
}

# Populate plugins hashtable with plugins that have fixed URLs to latest downloads
$plugins = @{
    #Not needed now with legit accounts #"SkinsRestorer"   = "https://github.com/SkinsRestorer/SkinsRestorerX/releases/latest/download/SkinsRestorer.jar"
    "ajStartCommands"   = "http://api.spiget.org/v2/resources/31033/download"
    "ProtocolLib"       = "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/build/libs/ProtocolLib.jar"
    "Vault"             = "http://api.spiget.org/v2/resources/34315/download"
    #"Holograms"             = "http://api.spiget.org/v2/resources/4924/download"
    #Outdated link on Spiget?:
    "CoreProtect"       = "http://api.spiget.org/v2/resources/8631/download"
    #Outdated: "InventoryRollback" = "http://api.spiget.org/v2/resources/48074/download"
    "InventoryRollback" = "http://api.spiget.org/v2/resources/85811/download" # Forked continuation https://www.spigotmc.org/resources/inventory-rollback-plus-1-8-1-19-x.85811/
    "Denizen"           = "http://api.spiget.org/v2/resources/21039/download" #https://www.spigotmc.org/resources/denizen.21039/
    "TreeGravity"       = "http://api.spiget.org/v2/resources/59283/download" #https://www.spigotmc.org/resources/1-17-treegravity-tree-feller.59283/
    #    "WorldEdit"             = "https://dev.bukkit.org/projects/worldedit/files/latest"
    "WorldEditSUI"      = "http://api.spiget.org/v2/resources/60726/download/" #https://www.spigotmc.org/resources/worldeditsui-visualize-your-selection.60726/
    #    "WorldGuard"            = "https://dev.bukkit.org/projects/worldguard/files/latest"
    "ChunkLoader"       = "http://api.spiget.org/v2/resources/92834/download/"  # https://www.spigotmc.org/resources/chunkloader.92834/
    "AureliumSkills"    = "http://api.spiget.org/v2/resources/81069/download/"  # https://spigotmc.org/resources/81069
    "Sentinel"          = "http://api.spiget.org/v2/resources/22017/download/"  #https://www.spigotmc.org/resources/sentinel.22017/
    #2022-11-11 Need beta version currently "InteractionVisualizer" = "http://api.spiget.org/v2/resources/77050/download/"  #https://www.spigotmc.org/resources/interactionvisualizer-visualize-function-blocks-entities-like-crafting-tables-with-animations.77050/
    "LightAPIFork"      = "http://api.spiget.org/v2/resources/48247/download/"  #Needed by InteractionVisualizer - https://www.spigotmc.org/resources/lightapi-fork.48247/
    "PlaceholderAPI"    = "http://api.spiget.org/v2/resources/6245/download/"  #https://www.spigotmc.org/resources/placeholderapi.6245/
    #"HoloMobHealth"        = "http://api.spiget.org/v2/resources/75975/download/"  #https://www.spigotmc.org/resources/75975/
    #Beta version confuses result "DynMap"          = "http://api.spiget.org/v2/resources/274/download"
}

# plugins hashtable with plugins that we need to discover the direct download url
$indirectplugins = @{
    # Moved to Spigot version above    "DynMap"             = "http://dynmap.us/builds/dynmap/Dynmap-3.1-SNAPSHOT-spigot.jar"
    "LuckPerms-Bukkit" = "https://ci.lucko.me/view/LuckPerms/job/LuckPerms/lastSuccessfulBuild/"
    "AdvancedPortals"  = "https://github.com/sekwah41/Advanced-Portals/releases/latest"
    "EssentialsX"      = "https://github.com/EssentialsX/Essentials/releases/latest"
    "chunkmaster"      = "https://github.com/Trivernis/spigot-chunkmaster/releases/latest"
    "OpenInv"          = "https://github.com/lishid/OpenInv/releases/latest"
    "Harbor"           = "https://github.com/nkomarn/Harbor/releases/latest"
    "Plan"             = "https://github.com/plan-player-analytics/Plan/releases/latest"
    "Citizens"         = "https://ci.citizensnpcs.co/job/Citizens2/lastSuccessfulBuild/"
    #"Denizen"          = "https://ci.citizensnpcs.co/view/all/job/Denizen/lastSuccessfulBuild/"
    #    "FastAsyncWorldEdit" = "https://ci.athion.net/job/FastAsyncWorldEdit-1.17/lastSuccessfulBuild/artifact/artifacts/"
    # 2020-10-14 disabling ViaVersion until needed as it may be interfering with SkinsRestorer
    #"ViaVersion" = "https://ci.viaversion.com/job/ViaVersion/lastSuccessfulBuild/artifact/jar/target/"
    #"ViaBackwards" = "https://ci.viaversion.com/view/ViaBackwards/job/ViaBackwards/lastSuccessfulBuild/artifact/all/target/"
}


# Manually add EssentialsSpawn to plugins hashtable
Write-Host "Discovering EssentialsXSpawn download link"
$manualAddBase = "https://github.com/EssentialsX/Essentials/releases/latest"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $manualAddBase
$tempURI = ((Select-String '(http[s]?)(:\/\/)([^\s,]+)(?=")' -Input $WebResponse.Content -AllMatches).Matches.Value) | Select-String "expanded"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $tempURI.ToString()
$manualAddLatest = $WebResponse.Links | Where-Object { $_.href -match "EssentialsXSpawn" } | Select-Object -First 1
$manualAddURI = ("https://github.com" + $manualAddLatest.href)
Write-Host "  " $manualAddURI
$plugins.Add( "EssentialsSpawn" , $manualAddURI)

# Manually add BlueMap to plugins hashtable
Write-Host "Discovering BlueMap download link"
$manualAddBase = "https://github.com/BlueMap-Minecraft/BlueMap/releases/latest"
#$manualAddBase = "https://github.com/BlueMap-Minecraft/BlueMap/releases/"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $manualAddBase
$tempURI = ((Select-String '(http[s]?)(:\/\/)([^\s,]+)(?=")' -Input $WebResponse.Content -AllMatches).Matches.Value) | Select-String "expanded"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $tempURI.ToString()
$manualAddLatest = $WebResponse.Links | Where-Object { $_.href -match "spigot" } | Select-Object -First 1
$manualAddURI = ("https://github.com" + $manualAddLatest.href)
Write-Host "  " $manualAddURI
$plugins.Add( "BlueMap" , $manualAddURI)

# Manually add DynMap to plugins hashtable
Write-Host "Discovering DynMap download link"
$manualAddBase = "http://dynmap.us/builds/dynmap/?C=M;O=D"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $manualAddBase
$manualAddLatest = $WebResponse.Links | Where-Object { $_.href -match "spigot" } | Select-Object -First 1
$manualAddURI = ("http://dynmap.us/builds/dynmap/" + $manualAddLatest.href)
Write-Host "  " $manualAddURI
$plugins.Add( "DynMap" , $manualAddURI)

# Manually add WorldEdit to plugins hashtable
Write-Host "Discovering WorldEdit download link"
$manualAddBase = "https://dl.9minecraft.net/index.php?act=dl&id=1671409291"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $manualAddBase
$manualAddLatest = $WebResponse.Links | Where-Object { $_.href -match "download" } | Select-Object -First 1
$manualAddURI = ($manualAddLatest.href)
Write-Host "  " $manualAddURI
$plugins.Add( "WorldEdit" , $manualAddURI)

# Manually add WorldEdit to plugins hashtable
Write-Host "Discovering WorldGuard download link"
$manualAddBase = "https://dl5.9minecraft.net/index.php?act=dl&id=1666532752"
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $manualAddBase
$manualAddLatest = $WebResponse.Links | Where-Object { $_.href -match "download" } | Select-Object -First 1
$manualAddURI = ($manualAddLatest.href)
Write-Host "  " $manualAddURI
$plugins.Add( "WorldGuard" , $manualAddURI)
 

<#
 # Sample of Manually add a plugin to plugins hashtable
Write-Host "Discovering MANUALPLUGIN download link"
$manualAddBase =
$WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $manualAddBase
$manualAddLatest = $WebResponse.Links | Where-Object { $_.href -match "MANUALPLUGIN-Identifier" } | Select-Object -First 1
$manualAddURI = ("https://github.com" + $manualAddLatest.href)
Write-Host $manualAddURI
$plugins.Add( "MANUALPLUGIN" , $manualAddURI)

 #>



###########################################################################################
# Get all the urls for plugins with indirect urls
$indirectplugins.GetEnumerator() | ForEach-Object -Parallel {
    function Get-DownloadURL {
        # Some download URLs change and latest needs to be discovered

        param (
            $pluginName,
            $pluginBaseURL,
            $linkOrder = "first"
        )

        Write-Host " Discovering $pluginName download link"
        $WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $pluginBaseURL

        if ( $pluginBaseURL -like "*github*") {
            $tempURI = ((Select-String '(http[s]?)(:\/\/)([^\s,]+)(?=")' -Input $WebResponse.Content -AllMatches).Matches.Value) | Select-String "expanded"
            $WebResponse = Invoke-WebRequest -UserAgent $UserAgent -Uri $tempURI.ToString()
            $URLLatest = $WebResponse.Links | Where-Object { $_.href -match ".jar$" } | Select-Object -First 1
            $pluginURI = ("https://github.com" + $URLLatest.href)
            <#             Write-Host ":::::::::::::::::::::::::::::"
            Write-Host "pluginURI" $pluginURI
            Write-Host "URLLatest" $URLLatest.href
            Write-Host "pluginBaseURL" $pluginBaseURL
            #>        
        }
        else {
            $URLLatest = $WebResponse.Links | Where-Object { $_.href -match ".jar$" } | Select-Object -First 1
            $pluginURI = ($pluginBaseURL + $URLLatest.href)
        }
        Write-Host "  @ $pluginName is at $pluginURI"
        if ($null -ne $URLLatest.href) {
            ($using:plugins).Add( $pluginName , $pluginURI)

        }
        else {
            Write-Host " &&&&&&&&&& Empty href *&%^$& ignoring this plugin" $pluginName $pluginBaseURL
        }
    }
    Get-DownloadURL -pluginName $_.Key -pluginBaseURL $_.Value
} -ThrottleLimit 1


###########################################################################################
Write-Host "******** Downloading plugins: ********"
# For each plugin download to temporary download path
$downloadFuncDef = $function:DownloadFile.ToString() # prepare download function for importing into parallel runspace.

$plugins.GetEnumerator() | ForEach-Object -Parallel {
    $outfile = ($_.Key + ".jar")
    Write-Host "  " $_.Key ": Downloading from" $_.value "to" $outfile

    $function:DownloadFile = $using:downloadFuncDef
    DownloadFile -UserAgent $using:UserAgent -Uri $_.value -OutFile ($using:downloadPath + $_.Key + ".jar") -name $_.Key | Out-Null
} -ThrottleLimit 1 #5


Write-Host "******** Copying downloaded plugins to each server ********"
# For each server copy all plugins from temporary download path
$servers.GetEnumerator() | ForEach-Object {
    $copyFromPath = ($downloadPath + "*")
    $copyToPath = ($_.Value + "/plugins/")

    Write-Host "  - Copying plugins to" $_.Name
    #Write-Host "                        from $copyFromPath to $copyToPath"

    Copy-Item -Path $copyFromPath -Destination $copyToPath
}



###########################################################################################
Write-Host "******** Manual fixup steps."

#Write-Host "  Remove Plan from Factions server due to conflicts"
#Remove-Item -Path "/var/games/minecraft/servers/Factions/plugins/Plan.jar"

Write-Host "  Copy Plan to Bungeecord proxies"
Copy-Item -Path "/home/pault/mctools/updates/plugins/Plan.jar" -Destination "/var/games/minecraft/servers/bungeecord/plugins/Plan.jar"
Copy-Item -Path "/home/pault/mctools/updates/plugins/Plan.jar" -Destination "/var/games/minecraft/servers/bungeecordAuth/plugins/Plan.jar"
Copy-Item -Path "/home/pault/mctools/updates/plugins/Plan.jar" -Destination "/var/opt/minecraft/crafty/crafty-4/servers/58e6f207-7174-466a-8c3e-af31ac6068c7/plugins/Plan.jar"

Write-Host "  Fix Dynmap (using rsync)"
$servers.GetEnumerator() | ForEach-Object {
    Start-Process "rsync" -ArgumentList ("-av " + $_.Value + "/plugins/dynmap/web/ /var/www/html/maps/" + $_.Name + "/ --exclude tiles")
}


Write-Host "******* Updates completed ************************"

#Ping HealthCheck.io to track completion of updates
Invoke-RestMethod -Uri https://hc-ping.com/b7390183-c774-4043-895e-3418e307ed56
