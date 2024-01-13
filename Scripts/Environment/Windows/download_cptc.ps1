param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$url,

    [Parameter(Position = 1, Mandatory = $true)]
    [string]$outputDir,

    [switch]$help
)

function Show-Help {
    @"
    ____                                       __
   / __ \___ _   ____  ___________ _____  ____/ /___  ____ ___
  / / / / _ \ | / / / / / ___/ __ `/ __ \/ __  / __ \/ __ `__ \
 / /_/ /  __/ |/ / /_/ / /  / /_/ / / / / /_/ / /_/ / / / / / /
/_____/\___/|___/\__,_/_/   \__,_/_/ /_/\__,_/\____/_/ /_/ /_/ 

    ____                      __                __
   / __ \____ _      ______  / /___  ____ _____/ /__ _____
  / / / / __ \ | /| / / __ \/ / __ \/ __ `/ __  / _ \/ ___/
 / /_/ / /_/ / |/ |/ / / / / / /_/ / /_/ / /_/ /  __/ /    
/_____/\____/|__/|__/_/ /_/ /_/_/\____/\__,_/\__,_/\_/    

Usage: ./download_cptc.ps1 <output_directory>

Download files from a specified URL to the given output directory.

Arguments:
  url                   The URL to download files from.
  output_directory      The directory where files will be downloaded.

Options:
  -help                 Show this help message and exit.
"@
}

if ($help) {
    Show-Help
    exit
}

# If $outputDir is not provided or is empty, exit and show help
if (-not $url -or -not $outputDir) {
    Show-Help
    exit
}

# Trim trailing slashes from output directory argument
$outputDir = $outputDir.TrimEnd('\')
$url = $url.TrimEnd('/')

$pageContent = Invoke-WebRequest -Uri $url

# Filter the links to download based on extensions or specific filenames
$targets = $pageContent.Links.Href | Where-Object { $_ -match "\.ova$|\.txt$|\.png$|\.csv$+" }

$scriptBlock = {
    param($target, $url, $outputDir)

    # Skip if not a valid file just in case
    if ($target -match "^/|^\?") {
        return
    }

    $outputPath = Join-Path -Path $outputDir -ChildPath $target
    if (Test-Path -Path $outputPath) {
        Write-Host -ForegroundColor Red -Object "$target already exists, skipping download."
    }
    else {
        Write-Host -ForegroundColor Green -Object "Downloading target $target..."
        $downloadUrl = "$url/$target"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
    }
}

foreach ($target in $targets) {
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $target, $url, $outputDir
}

# Wait for all jobs to complete
Get-Job | Wait-Job

# Clean up
Get-Job | Remove-Job