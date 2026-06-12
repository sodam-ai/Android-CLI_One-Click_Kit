# install.ps1 - Android CLI One-Click Kit : 설치
# 이 파일은 UTF-8 (BOM) 로 저장됩니다.
. (Join-Path $PSScriptRoot 'common.ps1')
Set-Utf8Console

Write-Host ''
Write-Host '======================================================'
Write-Host '   Android CLI 원클릭 설치'
Write-Host '======================================================'
Write-Host ''

# 1) 이미 설치되어 있는지 확인
$existing = Find-AndroidCli
if ($existing) {
    Write-Host "이미 'android' 가 설치되어 있습니다:" -ForegroundColor Green
    Write-Host "  $existing"
    Write-Host ''
    Write-Host '업데이트하려면 RUN.bat 을 열고 6) 업데이트 를 사용하세요.'
    Pause-Enter
    exit 0
}

# 2) 설치 방법 자동 선택 (winget 우선, 없으면 curl)
if (Test-CommandExists 'winget') {
    Write-Host 'winget(Windows 패키지 관리자)을 찾았습니다. 이 방법으로 설치합니다.'
    Write-Host '설치 중 Windows 권한 창이 한 번 뜰 수 있습니다(정상입니다).'
    $method = 'winget'
} else {
    Write-Host 'winget 이 없어 구글 공식 설치 스크립트(curl)로 설치합니다(관리자 권한 불필요).'
    $method = 'curl'
}
Write-Host ''
Write-Host '다운로드와 설치에 1~2분 정도 걸릴 수 있어요.'
Write-Host '진행 중에는 이 창을 닫지 말고 잠시 기다려 주세요.'
Write-Host ''

# 3) 설치 실행 (최대 2회 시도)
for ($try = 1; $try -le 2; $try++) {
    Write-Host ("설치 시도 {0}/2 ..." -f $try)
    try {
        if ($method -eq 'winget') {
            & winget install --id Google.AndroidCLI -e --accept-source-agreements --accept-package-agreements
        } else {
            # 구글이 안내하는 Windows 공식 한 줄 명령을 '진짜 cmd' 에서 실행합니다.
            # (PowerShell 직접 다운로드는 미지원이므로 cmd /c 로 감쌉니다.)
            & cmd /c 'curl.exe -fsSL https://dl.google.com/android/cli/latest/windows_x86_64/install.cmd -o "%TEMP%\aclisetup.cmd" && "%TEMP%\aclisetup.cmd"'
        }
    } catch {
        Write-Host ("  오류: " + $_.Exception.Message) -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 2
    if (Find-AndroidCli) { break }
    if ($try -lt 2) { Write-Host '  잠시 후 다시 시도합니다...'; Start-Sleep -Seconds 3 }
}

# 4) 결과 확인 + 기록
Write-Host ''
$found = Find-AndroidCli
if ($found) {
    Write-MarkerMethod $method
    Write-MarkerPath (Split-Path -Parent $found)
    Write-Host '설치 완료!' -ForegroundColor Green
    Write-Host "  위치: $found"
    Write-Host ''
    Write-Host '[중요] Windows 에서는 에뮬레이터(가상기기) 명령이 현재 비활성입니다.'
    Write-Host '       프로젝트 생성 / SDK 관리 / 스킬 추가 / 문서 검색 등은 사용할 수 있습니다.'
    Write-Host ''
    Write-Host '다음 단계: RUN.bat 을 더블클릭해 메뉴를 여세요.'
    $code = 0
} else {
    Write-MarkerMethod $method
    Write-Host '설치 여부를 이 창에서 확인하지 못했습니다.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '먼저: 이 창을 닫고 RUN.bat 을 새로 실행해 1) 상태 확인 을 눌러보세요.'
    Write-Host '      (설치는 됐지만 이 창이 PATH 변경을 아직 모를 수 있습니다.)'
    Write-Host '그래도 안 되면: 이 화면을 캡처해서 도움을 요청하세요.'
    $code = 1
}

Pause-Enter
exit $code
