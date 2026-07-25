$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptRoot "..\..")
$BinPath = Join-Path $RepoRoot "bin"

Remove-Item -LiteralPath $BinPath -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $BinPath | Out-Null

$Classpath = @(
    Join-Path $RepoRoot "lib\cloudsim-7.0.0-alpha.jar"
    Join-Path $RepoRoot "lib\commons-math3-3.6.1.jar"
    Join-Path $RepoRoot "lib\colt.jar"
) -join ";"

javac -classpath $Classpath `
    -sourcepath (Join-Path $RepoRoot "src") `
    (Join-Path $RepoRoot "src\edu\boun\edgecloudsim\applications\ahp_rough\MainApp.java") `
    -d $BinPath
