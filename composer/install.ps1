$ErrorActionPreference = "Stop"

$InstallDir = if ($env:COMPOSER_INSTALL_DIR) { $env:COMPOSER_INSTALL_DIR } else { "C:\bin" }
$Filename = if ($env:COMPOSER_FILENAME) { $env:COMPOSER_FILENAME } else { "composer.bat" }

if (-not $env:COMPOSER_HOME) {
  $env:COMPOSER_HOME = Join-Path $env:APPDATA "Composer"
}

if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
  Write-Error "PHP is not installed or is not available on PATH."
}

if (-not (Test-Path $InstallDir)) {
  New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

$ComposerHome = $env:COMPOSER_HOME
try {
  if (-not (Test-Path $ComposerHome)) {
    New-Item -ItemType Directory -Path $ComposerHome | Out-Null
  }
  $Probe = Join-Path $ComposerHome ".write-test"
  New-Item -ItemType File -Path $Probe -Force | Out-Null
  Remove-Item $Probe -Force
}
catch {
  $ComposerHome = Join-Path $env:APPDATA "Composer"
  if (-not (Test-Path $ComposerHome)) {
    New-Item -ItemType Directory -Path $ComposerHome | Out-Null
  }
  $env:COMPOSER_HOME = $ComposerHome
}

$TempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid()))
$Installer = Join-Path $TempDir.FullName "composer-setup.php"
$SignatureFile = Join-Path $TempDir.FullName "installer.sig"

try {
  Invoke-WebRequest -Uri "https://getcomposer.org/installer" -OutFile $Installer
  Invoke-WebRequest -Uri "https://composer.github.io/installer.sig" -OutFile $SignatureFile

  $ExpectedSignature = (Get-Content $SignatureFile -Raw).Trim()
  $ActualSignature = (Get-FileHash -Path $Installer -Algorithm SHA384).Hash.ToLowerInvariant()

  if ($ActualSignature -ne $ExpectedSignature.ToLowerInvariant()) {
    throw "Composer installer signature mismatch."
  }

  php $Installer --install-dir=$InstallDir --filename=$Filename

  $ComposerPath = Join-Path $InstallDir $Filename
  & $ComposerPath --version
}
finally {
  Remove-Item $TempDir.FullName -Recurse -Force -ErrorAction SilentlyContinue
}
