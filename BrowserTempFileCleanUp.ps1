# Function to take ownership and grant full control
function Grant-FullControl {
    param (
        [string]$path
    )
    try {
        icacls $path /grant Everyone:F /T /C
        Write-Output "Granted full control to: $path"
    } catch {
        Write-Output "Failed to grant full control to: $path - $($_.Exception.Message)"
    }
}

# Function to clear temporary files
function Clear-TempFiles {
    param (
        [string]$dataPath
    )

    if (Test-Path -Path $dataPath) {
        Grant-FullControl -path $dataPath
        
        # Attempt to remove the files with error handling
        Remove-Item -Path $dataPath -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable removeError

        if ($removeError) {
            Write-Output "Failed to remove some items in: $dataPath - $($removeError.Exception.Message)"
            # Optionally, you could add a retry mechanism here
        } else {
            Write-Output "Temporary files cleared successfully from: $dataPath"
        }
    } else {
        Write-Output "Cache path not found: $dataPath"
    }
}

# Clear browser temporary files
function Clear-BrowserTempFiles {
    # Clear Internet Explorer temp files
    try {
        RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
        Write-Output "Internet Explorer temporary files cleared successfully."
    } catch {
        Write-Output "Failed to clear Internet Explorer temporary files - $($_.Exception.Message)"
    }

    # Define paths for Edge, Chrome, and Firefox
    $edgeDataPath = "$env:LocalAppData\Microsoft\Edge\User Data\Default\Cache"
    $chromeDataPath = "$env:LocalAppData\Google\Chrome\User Data\Default\Cache"
    $firefoxProfilePath = "$env:AppData\Mozilla\Firefox\Profiles"

    # Clear Edge temp files
    Clear-TempFiles -dataPath $edgeDataPath

    # Clear Chrome temp files
    Clear-TempFiles -dataPath $chromeDataPath

    # Clear Firefox temp files
    if (Test-Path -Path $firefoxProfilePath) {
        $firefoxCachePaths = Get-ChildItem -Path $firefoxProfilePath -Recurse -Filter "cache2"
        foreach ($cachePath in $firefoxCachePaths) {
            Clear-TempFiles -dataPath $cachePath.FullName
        }
    } else {
        Write-Output "Firefox profile path not found."
    }
}

# Start clearing temp files
Clear-BrowserTempFiles

Write-Output "Temporary internet files cleanup process completed."
