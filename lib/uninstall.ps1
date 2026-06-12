# uninstall.ps1 - Android CLI One-Click Kit : 제거
# 이 파일은 UTF-8 (BOM) 로 저장됩니다.
. (Join-Path $PSScriptRoot 'common.ps1')
Set-Utf8Console

Write-Host ''
Write-Host '======================================================'
Write-Host '   Android CLI 원클릭 제거'
Write-Host '======================================================'
Write-Host ''

$method = Read-MarkerMethod
$exe = Find-AndroidCli

if (-not $exe -and -not $method) {
    Write-Host '설치 흔적을 찾지 못했습니다. 이미 제거되었을 수 있습니다.' -ForegroundColor Yellow
    Pause-Enter
    exit 0
}

$methodLabel = if ($method) { $method } else { '알 수 없음' }
Write-Host ("설치 방법 기록: " + $methodLabel)
if ($exe) { Write-Host ("현재 위치: " + $exe) }
Write-Host ''
$go = (Read-Host '정말 제거할까요? 제거하려면 yes 를 입력하세요').Trim().ToLower()
if ($go -ne 'yes') {
    Write-Host '취소했습니다.'
    Pause-Enter
    exit 0
}
Write-Host ''

$removed = $false

# 1) winget 으로 설치했으면 winget 으로 깔끔하게 제거
if ($method -eq 'winget' -and (Test-CommandExists 'winget')) {
    Write-Host 'winget 으로 제거합니다...'
    & winget uninstall --id Google.AndroidCLI -e --accept-source-agreements
    Start-Sleep -Seconds 2
    if (-not (Find-AndroidCli)) { $removed = $true }
}

# 2) curl 설치였거나 winget 제거가 안 됐으면 -> 위치를 찾아 수동 제거
if (-not $removed) {
    # 지울 폴더를 '키트가 기록한 설치 경로' 기준으로 결정 (가장 안전)
    $recorded = Read-MarkerPath
    $exe2 = Find-AndroidCli
    $dir = $null
    if ($recorded -and (Test-Path (Join-Path $recorded 'android.exe'))) {
        $dir = $recorded
    } elseif ($exe2) {
        $cand = Split-Path -Parent $exe2
        if ($recorded -and ($cand.TrimEnd('\') -ine $recorded.TrimEnd('\'))) {
            Write-Host '현재 android 위치가 키트가 기록한 설치 위치와 달라 자동 삭제하지 않습니다.' -ForegroundColor Yellow
            Write-Host ('  기록한 위치: ' + $recorded)
            Write-Host ('  현재 위치  : ' + $cand)
            Write-Host '직접 확인 후 수동으로 삭제하세요.'
        } else {
            $dir = $cand   # 기록 없음(구버전 설치) -> 기존 방식 폴백
        }
    }

    if ($dir) {
        # 2차 안전망: 드라이브 루트/Windows 폴더가 아니고 'android' 포함, 경로 길이 확인
        $isRoot = ($dir -match '(?i)^[A-Za-z]:\\?$')
        $isWin  = ($dir -match '(?i)\\Windows($|\\)')
        $safe = ($dir -match '(?i)android') -and (-not $isRoot) -and (-not $isWin) -and ($dir.Length -gt 10)
        if ($safe) {
            Write-Host ("삭제 대상 폴더: " + $dir)
            Write-Host '삭제하는 중...'
            try {
                Get-Process -Name 'android' -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Kill() } catch {} }
                Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction Stop
                Remove-FromUserPath $dir
                $removed = $true
            } catch {
                Write-Host ("삭제 중 오류: " + $_.Exception.Message) -ForegroundColor Red
            }
        } else {
            Write-Host ("안전 검사를 통과하지 못해 자동 삭제하지 않습니다: " + $dir) -ForegroundColor Yellow
            Write-Host '직접 확인 후 수동으로 삭제하세요.'
        }
    } elseif (-not $exe2) {
        Write-Host "'android' 실행 파일을 현재 찾을 수 없어 폴더 삭제는 건너뜁니다."
    }
}

Write-Host ''
if ($removed) {
    Write-Host '제거 완료!' -ForegroundColor Green
} else {
    Write-Host '완전히 제거되지 않았을 수 있습니다. 위 안내를 확인하세요.' -ForegroundColor Yellow
}
Write-Host ''
Write-Host '참고: android sdk 로 내려받은 SDK 데이터는 별도이며, 이 도구는 건드리지 않았습니다.'
Write-Host '      PATH 를 바꿨다면 원래 값은 다음 파일에 백업되어 있습니다:'
Write-Host ('      ' + (Join-Path $env:LOCALAPPDATA 'android-cli-one-click-kit\path-backup.txt'))
Pause-Enter
exit 0
