param([string[]] $TestPaths = @('test'))
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    # The Rive installer invokes Windows PowerShell, which cannot load PS7's
    # Microsoft.PowerShell.Archive module inherited through PSModulePath.
    $env:PSModulePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules;$env:PSModulePath"
    & dart run rive_native:setup --platform windows
    if ($LASTEXITCODE -ne 0) { throw 'Rive native setup failed' }
    $packageConfig = Get-Content .dart_tool/package_config.json -Raw | ConvertFrom-Json
    $rivePackage = $packageConfig.packages | Where-Object name -eq 'rive_native'
    $packageRoot = ([Uri]$rivePackage.rootUri).LocalPath
    # Published debug binaries require nonredistributable debug CRTs. Use the
    # publisher's same-version release runtime for deterministic Windows tests.
    $releaseDll = Join-Path $packageRoot 'windows\bin\lib\release\rive_native.dll'
    $testDll = Join-Path $PWD 'build\rive_native\native\build\windows\bin\lib\debug\rive_native.dll'
    New-Item -ItemType Directory -Path (Split-Path $testDll -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $releaseDll -Destination $testDll -Force
    & flutter test --no-pub --reporter expanded @TestPaths
    $testExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $testExitCode
