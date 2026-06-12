# welcome.ps1 - Android CLI One-Click Kit : 시작 안내 (아무것도 설치하지 않음)
# 이 파일은 UTF-8 (BOM) 로 저장됩니다.
param([switch]$NoPause)
. (Join-Path $PSScriptRoot 'common.ps1')
Set-Utf8Console

Write-Host ''
Write-Host '======================================================'
Write-Host '   Android CLI 원클릭 키트 - 처음 오셨나요?'
Write-Host '======================================================'
Write-Host ''
Write-Host '이 키트는 구글 "Android CLI" 도구를 더블클릭만으로'
Write-Host '설치 / 사용 / 제거할 수 있게 해줍니다. (명령어 외울 필요 없음)'
Write-Host ''
Write-Host '아래 순서대로 파일을 더블클릭하면 됩니다:'
Write-Host ''
Write-Host '   [1] 자가진단.bat    - (선택) 설치 안 하고 환경만 점검'
Write-Host '   [2] INSTALL.bat     - 설치하기'
Write-Host '   [3] RUN.bat         - 메뉴 열어서 사용하기'
Write-Host '   [4] UNINSTALL.bat   - 다 쓰면 깨끗이 지우기'
Write-Host ''

$exe = Find-AndroidCli
if ($exe) {
    Write-Host '지금 상태: 이미 설치되어 있습니다.  ->  RUN.bat 을 더블클릭하세요.' -ForegroundColor Green
} else {
    Write-Host '지금 상태: 아직 설치 안 됨.  ->  먼저 INSTALL.bat 을 더블클릭하세요.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '----- 처음이면 꼭 알아두세요 -----'
Write-Host ' - 파란 경고창("Windows의 PC 보호")이 뜨면?'
Write-Host '     -> "추가 정보" 클릭 -> "실행" 클릭 (구글 공식 도구라 안전합니다)'
Write-Host ' - "관리자 권한으로 실행" 하지 말고, 그냥 더블클릭하세요.'
Write-Host ' - lib 폴더는 지우지 마세요 (키트가 작동하지 않습니다).'
Write-Host ' - 막히면 그 화면을 캡처해서 도움을 요청하세요.'
Write-Host ''
Write-Host '자세한 설명: "왕초보_시작_가이드.md" 파일을 메모장으로 열어보세요.'
Write-Host ''
Write-Host '======================================================'
Write-Host ' 바로 시작하려면 번호를 누르세요 (해당 파일을 엽니다):'
Write-Host '   1) 설치하기    (INSTALL)'
Write-Host '   2) 사용하기    (RUN - 메뉴)'
Write-Host '   3) 제거하기    (UNINSTALL)'
Write-Host '   4) 환경 점검   (자가진단)'
Write-Host '   0) 그냥 닫기'
Write-Host '======================================================'

if ($NoPause) { exit 0 }   # 테스트 모드: 입력 대기/실행 안 함

$choice = (Read-Host ' 번호 입력 (0~4)').Trim()
$kitRoot = Split-Path -Parent $PSScriptRoot
$map = @{ '1' = 'INSTALL.bat'; '2' = 'RUN.bat'; '3' = 'UNINSTALL.bat'; '4' = '자가진단.bat' }
if ($map.ContainsKey($choice)) {
    $target = Join-Path $kitRoot $map[$choice]
    if (Test-Path $target) {
        Write-Host ('새 창에서 "' + $map[$choice] + '" 을(를) 엽니다...') -ForegroundColor Green
        Start-Process -FilePath $target
    } else {
        Write-Host ('파일을 찾을 수 없습니다: ' + $target) -ForegroundColor Red
        Pause-Enter
    }
} elseif ($choice -eq '0' -or $choice -eq '') {
    Write-Host '닫습니다. (필요하면 시작하기.bat 을 다시 더블클릭하세요.)'
} else {
    Write-Host '잘못된 입력입니다. 닫습니다.'
}
exit 0
