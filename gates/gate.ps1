# Parse arguments
param (
    [switch]$Encrypt,
    [switch]$Decrypt,
    [string]$Directory,
    [string]$Password,
    [switch]$Help
)
begin {
    # Check if OpenSSL is installed
    if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
        Write-Host "OpenSSL is not installed. Please install it and try again." -ForegroundColor Red
        exit 1
    }

    # Usage function
    function Show-Usage {
        Write-Host "Usage: gate.ps1 -e|-d -f <directory> -p <password>" -ForegroundColor Yellow
        Write-Host "  -e: Encrypt files"
        Write-Host "  -d: Decrypt files"
        Write-Host "  -f: Directory containing files"
        Write-Host "  -p: Password for encryption/decryption"
        Write-Host "  -h: Show this help message"
        exit 1
    }

    if ($Help) {
        Show-Usage
    }

    # Ensure -e and -d are not called together
    if ($Encrypt -and $Decrypt) {
        Write-Host "Error: -e and -d cannot be used together." -ForegroundColor Red
        Show-Usage
    }

    # Ensure either -e or -d is provided
    if (-not $Encrypt -and -not $Decrypt) {
        Write-Host "Error: Either -e or -d must be specified." -ForegroundColor Red
        Show-Usage
    }

    # Ensure all required arguments are provided
    if (-not $Directory -or -not $Password) {
        Show-Usage
    }

    # Ensure the directory exists
    if (-not (Test-Path -Path $Directory -PathType Container)) {
        Write-Host "Directory $Directory does not exist." -ForegroundColor Red
        exit 1
    }

    # Encrypt function
    function Encrypt-Files {
        Get-ChildItem -Path $Directory -File | ForEach-Object {
            $inputFile = $_.FullName
            $tempFile = "$inputFile.temp"
            & openssl enc -aes-256-cbc -salt -in $inputFile -out $tempFile -pass pass:"$Password"
            Move-Item -Force $tempFile $inputFile
            Write-Host "Encrypted: $inputFile" -ForegroundColor Green
        }
    }

    # Decrypt function
    function Decrypt-Files {
        Get-ChildItem -Path $Directory -File | ForEach-Object {
            $inputFile = $_.FullName
            $tempFile = "$inputFile.temp"
            & openssl enc -d -aes-256-cbc -in $inputFile -out $tempFile -pass pass:"$Password"
            Move-Item -Force $tempFile $inputFile
            Write-Host "Decrypted: $inputFile" -ForegroundColor Green
        }
    }

    # Perform the action
    if ($Encrypt) {
        Encrypt-Files
    } elseif ($Decrypt) {
        Decrypt-Files
    } else {
        Show-Usage
    }
}