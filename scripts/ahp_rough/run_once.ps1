param(
    [string]$ScenarioName = "default_config",
    [int]$IterationNumber = 1,
    [string]$OutputRoot = ""
)

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptRoot "..\..")

if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $ScriptRoot "output\manual"
}

$ConfigFile = Join-Path $ScriptRoot "config\$ScenarioName.properties"
$ScenarioOutput = Join-Path $OutputRoot $ScenarioName
New-Item -ItemType Directory -Path $ScenarioOutput -Force | Out-Null

$Classpath = @(
    Join-Path $RepoRoot "bin"
    Join-Path $RepoRoot "lib\cloudsim-7.0.0-alpha.jar"
    Join-Path $RepoRoot "lib\commons-math3-3.6.1.jar"
    Join-Path $RepoRoot "lib\colt.jar"
) -join ";"

java -classpath $Classpath `
    edu.boun.edgecloudsim.applications.ahp_rough.MainApp `
    $ConfigFile `
    $ScenarioOutput `
    $IterationNumber
