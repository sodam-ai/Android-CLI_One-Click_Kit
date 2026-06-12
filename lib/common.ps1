# common.ps1 - Android CLI One-Click Kit : shared helpers
# 이 파일은 UTF-8 (BOM) 로 저장됩니다. (한글이 깨지지 않도록)

function Set-Utf8Console {
    # 콘솔에 한글이 제대로 보이도록 출력 인코딩을 UTF-8 로 맞춥니다.
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $global:OutputEncoding = [System.Text.Encoding]::UTF8
    } catch { }
}

function Get-KitDataDir {
    # 설치 방법 기록 / PATH 백업을 저장할 폴더
    $d = Join-Path $env:LOCALAPPDATA 'android-cli-one-click-kit'
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    return $d
}

function Update-SessionPath {
    # 설치 직후에는 현재 창의 PATH 에 새 경로가 아직 없을 수 있습니다.
    # 레지스트리(시스템+사용자)에서 최신 PATH 를 읽어 현재 세션에 반영합니다.
    $m = [System.Environment]::GetEnvironmentVariable('Path','Machine')
    $u = [System.Environment]::GetEnvironmentVariable('Path','User')
    $joined = @($m, $u) | Where-Object { $_ }
    $env:Path = ($joined -join ';')
}

function Find-AndroidCli {
    # 'android' 실행 파일의 전체 경로를 반환 (없으면 $null)
    Update-SessionPath
    $cmd = Get-Command android -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }
    $w = & where.exe android 2>$null | Select-Object -First 1
    if ($w) { return $w }
    return $null
}

function Test-CommandExists {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Write-MarkerMethod {
    # 어떤 방법(winget/curl)으로 설치했는지 기록 -> 제거 시 사용
    param([string]$Method)
    $f = Join-Path (Get-KitDataDir) 'install-method.txt'
    Set-Content -Path $f -Value $Method -Encoding ASCII
}

function Read-MarkerMethod {
    $f = Join-Path (Get-KitDataDir) 'install-method.txt'
    if (Test-Path $f) { return (Get-Content -Path $f -Raw).Trim() }
    return $null
}

function Write-MarkerPath {
    # 설치한 '정확한 폴더 경로'를 기록 -> 제거 시 이 폴더만 안전하게 삭제
    param([string]$Path)
    $f = Join-Path (Get-KitDataDir) 'install-path.txt'
    Set-Content -Path $f -Value $Path -Encoding UTF8
}

function Read-MarkerPath {
    $f = Join-Path (Get-KitDataDir) 'install-path.txt'
    if (Test-Path $f) { return (Get-Content -Path $f -Raw).Trim() }
    return $null
}

function Remove-FromUserPath {
    # 사용자 PATH 에서 특정 폴더 항목만 제거 (삭제 전 백업 저장)
    param([string]$DirToRemove)
    $u = [System.Environment]::GetEnvironmentVariable('Path','User')
    if (-not $u) { return }
    $backup = Join-Path (Get-KitDataDir) 'path-backup.txt'
    Set-Content -Path $backup -Value $u -Encoding UTF8
    $target = $DirToRemove.TrimEnd('\')
    $parts = $u -split ';' | Where-Object { $_ -and ($_.TrimEnd('\') -ne $target) }
    $new = ($parts -join ';')
    [System.Environment]::SetEnvironmentVariable('Path', $new, 'User')
}

function Pause-Enter {
    Read-Host "`n계속하려면 Enter 키를 누르세요"
}
