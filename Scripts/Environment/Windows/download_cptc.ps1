param (
    [Parameter(Position = 0, Mandatory = $false)]
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
if (-not $outputDir) {
    Show-Help
    exit
}

# Trim trailing slashes from output directory argument
$outputDir = $outputDir.TrimEnd('\')

$url = "https://archive.wrccdc.org/images/2024/wrccdc-2024-invitationals-2/"
$pageContent = Invoke-WebRequest -Uri $url

# Filter the links to download based on extensions or specific filenames
$targets = $pageContent.Links.Href | Where-Object { $_ -match "\.ova$|\.txt$|\.png$|\.csv$+" }

foreach ($target in $targets) {
    # Skip if not 7z or txt file just in case
    if ($target -match "^/|^\?") {
        continue
    }

    $outputPath = Join-Path -Path $outputDir -ChildPath $target

    # Check if file already exists and skip
    if (Test-Path -Path $outputPath) {
        Write-Host -ForegroundColor Red -Object "$target already exists, skipping download."
    }
    else {
        Write-Host -ForegroundColor Green -Object "Downloading target $target..."
        $downloadUrl = "$url/$target"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
    }
}
