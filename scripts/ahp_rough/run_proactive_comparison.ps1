param(
    [int]$Iterations = 50,
    [string]$OutputRoot = "",
    [string]$PythonExecutable = "python"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptRoot "..\..")

if ($Iterations -le 0) {
    throw "Iterations must be positive."
}

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $OutputRoot = Join-Path $ScriptRoot "output\proactive_comparison_$timestamp"
}

$OutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

& (Join-Path $ScriptRoot "compile.ps1")
if ($LASTEXITCODE -ne 0) {
    throw "Compilation failed."
}

$Classpath = @(
    Join-Path $RepoRoot "bin"
    Join-Path $RepoRoot "lib\cloudsim-7.0.0-alpha.jar"
    Join-Path $RepoRoot "lib\commons-math3-3.6.1.jar"
    Join-Path $RepoRoot "lib\colt.jar"
) -join ";"

$Scenarios = @("reactive_ahp_rough", "proactive_ahp_rough")
foreach ($scenario in $Scenarios) {
    $configFile = Join-Path $ScriptRoot "config\$scenario.properties"
    for ($iteration = 1; $iteration -le $Iterations; $iteration++) {
        $iterationOutput = Join-Path $OutputRoot "$scenario\ite$iteration"
        New-Item -ItemType Directory -Path $iterationOutput -Force | Out-Null
        Write-Host "[$scenario] iteration $iteration/$Iterations"
        & java -classpath $Classpath `
            edu.boun.edgecloudsim.applications.ahp_rough.MainApp `
            $configFile `
            $iterationOutput `
            $iteration
        if ($LASTEXITCODE -ne 0) {
            throw "Simulation failed: $scenario iteration $iteration"
        }
    }
}

& $PythonExecutable (Join-Path $ScriptRoot "analyze_run.py") $OutputRoot
if ($LASTEXITCODE -ne 0) {
    throw "Analysis failed."
}

$Report = Join-Path $OutputRoot "comparison\scenario_comparison.md"
Write-Host ""
Write-Host "Comparison completed."
Write-Host "Output: $OutputRoot"
Write-Host "Report: $Report"
Get-Content -Raw -Encoding UTF8 $Report
