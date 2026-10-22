param([switch]$SkipBuild)

$ErrorActionPreference = 'Stop'
if (-not $SkipBuild) { & "$PSScriptRoot\build.ps1" }
$script:checks = 0

function Run-Exercise([string]$Name, [string]$Text = '') {
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = Join-Path $PSScriptRoot "bin\$Name.exe"
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $info
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $process.StandardInput.Write($Text)
    $process.StandardInput.Close()
    if (-not $process.WaitForExit(10000)) {
        $process.Kill()
        throw "Timeout: $Name"
    }
    $result = [pscustomobject]@{
        Output = $stdout.Result.Replace("`r`n", "`n")
        Error = $stderr.Result.Replace("`r`n", "`n")
        Code = $process.ExitCode
    }
    $process.Dispose()
    return $result
}

function Assert-Equal($Actual, $Expected, [string]$Label) {
    if ($Actual -cne $Expected) {
        throw "$Label`nExpected: <$Expected>`nActual: <$Actual>"
    }
    $script:checks++
}

function Test-Output([string]$Name, [string]$Text, [string]$Expected) {
    $result = Run-Exercise $Name $Text
    Assert-Equal $result.Code 0 "$Name exit code"
    Assert-Equal $result.Output $Expected "$Name output"
}

Test-Output 'exercise_1_01' '' "hello, world`n"
$result = Run-Exercise 'exercise_1_02'
Assert-Equal $result.Code 0 'Escape example exit code'
Assert-Equal ($result.Output.Contains('Backslash: \')) $true 'Backslash example'

# Check every numeric row in all four temperature tables.
foreach ($name in @('exercise_1_03', 'exercise_1_04', 'exercise_1_05', 'exercise_1_15')) {
    $result = Run-Exercise $name
    Assert-Equal $result.Code 0 "$name exit code"
    $rows = @($result.Output.TrimEnd().Split("`n") | Select-Object -Skip 2)
    Assert-Equal $rows.Count 16 "$name row count"
    for ($i = 0; $i -lt 16; ++$i) {
        $x = if ($name -eq 'exercise_1_05') { 300 - 20 * $i } else { 20 * $i }
        $y = if ($name -eq 'exercise_1_04') { 9.0 / 5.0 * $x + 32 } else { 5.0 / 9.0 * ($x - 32) }
        $columns = $rows[$i].Trim() -split '\s+'
        Assert-Equal ([int]$columns[0]) $x "$name input temperature"
        $actual = [double]::Parse($columns[1], [Globalization.CultureInfo]::InvariantCulture)
        Assert-Equal ([math]::Abs($actual - $y) -le 0.051) $true "$name conversion"
    }
}

Test-Output 'exercise_1_08' "a  b`t`n`t " "Blanks: 3`nTabs: 2`nNewlines: 1`n"
Test-Output 'exercise_1_08' '' "Blanks: 0`nTabs: 0`nNewlines: 0`n"
Test-Output 'exercise_1_09' "  a   b`t  c`n " " a b`t c`n "
Test-Output 'exercise_1_10' ("a`t" + [char]8 + '\' + "`n") "a\t\b\\`n"
Test-Output 'exercise_1_11' '' "Lines: 0`nWords: 0`nCharacters: 0`n"
Test-Output 'exercise_1_11' 'one' "Lines: 0`nWords: 1`nCharacters: 3`n"
Test-Output 'exercise_1_11' " one`t two`n" "Lines: 1`nWords: 2`nCharacters: 10`n"
Test-Output 'exercise_1_11' " `t`n" "Lines: 1`nWords: 0`nCharacters: 3`n"
Test-Output 'exercise_1_11' "a`n`nb`t c" "Lines: 2`nWords: 3`nCharacters: 7`n"

$eighty = 'x' * 80
Test-Output 'exercise_1_17' ("short`n$eighty`n" + $eighty + 'y') ($eighty + 'y')
Test-Output 'exercise_1_17' (('a' * 10000) + "`n") (('a' * 10000) + "`n")
Test-Output 'exercise_1_18' "abc `t`n `t`n`n x  `nlast`t " "abc`n x`nlast"
Test-Output 'exercise_1_18' (('x' * 10000) + " `t`n") (('x' * 10000) + "`n")
Test-Output 'exercise_1_19' "abc`n`na b`nlast" "cba`n`nb a`ntsal"
Test-Output 'exercise_1_19' (('a' * 10000) + "z`n") ('z' + ('a' * 10000) + "`n")
Test-Output 'exercise_1_20' "a`tb`n`tend" ("a       b`n" + (' ' * 8) + 'end')
Test-Output 'exercise_1_21' ((' ' * 8) + 'x' + (' ' * 7) + 'y  ') "`tx`ty  "
Test-Output 'exercise_1_21' '1234567 x' '1234567 x'
Test-Output 'exercise_1_21' "a  `tb" "a`tb"

# Verify the visual columns survive entab followed by detab.
foreach ($text in @('  a        b ', "a `t b`n        c", (' ' * 1000), "1234567 `tX")) {
    $entab = Run-Exercise 'exercise_1_21' $text
    $roundtrip = Run-Exercise 'exercise_1_20' $entab.Output
    $expanded = Run-Exercise 'exercise_1_20' $text
    Assert-Equal $roundtrip.Output $expanded.Output 'entab/detab visual equivalence'
}

Test-Output 'exercise_1_22' 'short' 'short'
Test-Output 'exercise_1_22' ($eighty + "`n") ($eighty + "`n")
Test-Output 'exercise_1_22' (('a' * 170) + "`n") ((('a' * 80) + "`n") * 2 + ('a' * 10) + "`n")
Test-Output 'exercise_1_22' (('a' * 75) + ' ' + ('b' * 10)) (('a' * 75) + "`n" + ('b' * 10))
Test-Output 'exercise_1_22' "a`tb`n`n" "a       b`n`n"
$folded = Run-Exercise 'exercise_1_22' (('word ' * 1000) + "`n")
Assert-Equal (@($folded.Output.Split("`n") | Where-Object Length -gt 80).Count) 0 'Folded width limit'
Assert-Equal (($folded.Output -split '\s+' | Where-Object { $_ }).Count) 1000 'Folding preserves all words'

Test-Output 'exercise_1_23' "int/**/x; // hi`n/* a`nb */x++;`n" "int x;  `n `nx++;`n"
$quoted = 'char *s = "/* text */ // \" still string"; char c = ''/'';'
Test-Output 'exercise_1_23' ($quoted + '/*end*/') ($quoted + ' ')
Test-Output 'exercise_1_23' '/"/*literal*/"' '/"/*literal*/"'
Test-Output 'exercise_1_23' 'a/b/' 'a/b/'
Test-Output 'exercise_1_23' ("a/\`n*comment*/b") 'a b'
Test-Output 'exercise_1_23' ("a//comment\`ncontinued`nb") "a `nb"
Assert-Equal (Run-Exercise 'exercise_1_23' '/* unfinished').Code 1 'Unclosed comment'

foreach ($text in @('', 'int main(void) { return (1 + 2); }', $quoted, '/* {[ */', '// [', 'x/(y)', "// x\`n{`n()")) {
    Assert-Equal (Run-Exercise 'exercise_1_24' $text).Code 0 'Valid delimiter input'
}
foreach ($text in @('([)]', '}', '{', '/*', '"abc', "'a", ('"abc' + "`n"), ('(' * 1001))) {
    Assert-Equal (Run-Exercise 'exercise_1_24' $text).Code 1 "Invalid delimiter input: <$text>"
}

# Compare header limits against the separately computed integer limits.
$ranges = Run-Exercise 'exercise_2_01'
Assert-Equal $ranges.Code 0 'Ranges exit code'
$parts = $ranges.Output -split "`n`n"
$fromHeaders = ($parts[0] -split "`n" | Select-Object -Skip 1) -join "`n"
$computed = ($parts[1] -split "`n" | Select-Object -Skip 1) -join "`n"
Assert-Equal $computed $fromHeaders 'Calculated ranges match limits.h'
Test-Output 'exercise_2_03' '' "htoi('84ada') = 543450`nhtoi('f') = 15`nhtoi('F0') = 240`nhtoi('12fab') = 77739`nhtoi('0x2A') = 42`nhtoi('0Xff') = 255`n"

foreach ($name in @('exercise_1_09', 'exercise_1_10', 'exercise_1_17', 'exercise_1_18', 'exercise_1_19', 'exercise_1_20', 'exercise_1_21', 'exercise_1_22', 'exercise_1_23')) {
    Test-Output $name '' ''
}

# Compile a small harness for invalid values and INT_MAX boundaries.
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$vcvars = Join-Path $installation 'VC\Auxiliary\Build\vcvars64.bat'
$batch = Join-Path $PSScriptRoot 'obj\test_htoi.cmd'
$commands = @('@echo off', ('call "{0}" >nul' -f $vcvars), 'if errorlevel 1 exit /b 1')
$commands += 'cl /nologo /TC /std:c17 /W4 /WX "{0}\tests\test_htoi.c" /Fo"{0}\obj\test_htoi.obj" /Fe"{0}\bin\test_htoi.exe" /link /INCREMENTAL:NO' -f $PSScriptRoot
$commands += 'exit /b %errorlevel%'
Set-Content -LiteralPath $batch -Value $commands -Encoding ascii
& $env:ComSpec /d /c "`"$batch`""
if ($LASTEXITCODE -ne 0) { throw 'htoi test compilation failed.' }
Test-Output 'test_htoi' '' "18 htoi checks passed.`n"
Write-Host "PASS: $script:checks assertions, plus 18 htoi checks."
