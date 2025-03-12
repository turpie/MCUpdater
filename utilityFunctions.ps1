function DownloadFile() {
    # If the local directory exists and it gets a response from the url,
    # it checks the last modified date of the remote file. If the file
    # already exists it compares the date of the file to the file from
    # the url. If either the file doesn't exists or has a newer date, it
    # downloads the file and modifies the file's date to match.

    Param(
        [parameter(Mandatory = $true)] [String] $Uri,
        [parameter(Mandatory = $true)] [String] $OutFile,
        [parameter(Mandatory = $true)] [String] $UserAgent,
        [String] $Name
    )

    $webtest = try { [System.Net.WebRequest]::Create("$Uri").GetResponse() } catch [Net.WebException] {}
    if ( $webtest.LastModified ) {
        $download = 0
        if (-Not(Test-Path "$OutFile" -Ea 0)) {
            $download = 1
        }
        elseif ((Get-Item "$OutFile").LastWriteTime -ne $webtest.LastModified) {
            $download = 1
        }

    }
    else {
        Write-Host "WARNING *********** LastModified MISSING FROM WEBTEST for $Name."
        Write-Host "   = $Name - Need to update."
        $download = 1
    }

    if ( $download ) {
        Write-Host "   * $Name - Need to update."
        try{
            Invoke-WebRequest -UserAgent $UserAgent -Uri "$Uri" -OutFile "$OutFile" | Wait-Process

        } catch{
            Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
            Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
            $_.Exception.Response | Format-List
            $_.Exception | Format-List
            Write-Host $UserAgent
            Write-Host $Uri
            Write-Host $OutFile
            Invoke-WebRequest -UserAgent $UserAgent -Uri "$Uri" -OutFile "$OutFile" | Wait-Process
        }

        # Only set the new file's LastWriteTime if the $webtest.LastModified exists.
        if ( $webtest.LastModified ) {
            (Get-Item "$OutFile").LastWriteTime = $webtest.LastModified
        }
    }
    else {
        Write-Host "   - $Name - Already up to date."
    }
    $webtest.Close()
    return $download
}
