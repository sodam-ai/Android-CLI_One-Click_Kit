# selfcheck.ps1 - Android CLI One-Click Kit : 자가진단 (아무것도 설치하지 않음)
# 이 파일은 UTF-8 (BOM) 로 저장됩니다.
param([switch]$NoPause)
. (Join-Path $PSScriptRoot 'common.ps1')
Set-Utf8Console

Write-Host ''
Write-Host '======================================================'
Write-Host '   Android CLI 원클릭 키트 - 자가진단 (설치하지 않음)'
Write-Host '======================================================'
Write-Host ''

Write-Host '[1] 한글 표시 확인'
Write-Host '    아래 줄이 또렷하게 보이면 정상입니다:'
Write-Host '    >> 가나다라마바사 / 안녕하세요 / 설치·실행·제거'
Write-Host '    (네모(ㅁ)나 물음표(?)로 보이면 글꼴 문제입니다.)'
Write-Host ''

Write-Host '[2] 윈도우 / PowerShell'
Write-Host ('    Windows   : ' + [System.Environment]::OSVersion.VersionString)
Write-Host ('    PSVersion : ' + $PSVersionTable.PSVersion.ToString())
Write-Host ''

Write-Host '[3] 설치에 필요한 도구'
$curl   = Test-Path (Join-Path $env:SystemRoot 'System32\curl.exe')
$winget = Test-CommandExists 'winget'
Write-Host ('    curl.exe  : ' + $(if($curl){'있음 (OK)'}else{'없음 (!)'}))
Write-Host ('    winget    : ' + $(if($winget){'있음 -> winget 경로 사용'}else{'없음 -> curl 경로 사용'}))
if ((-not $curl) -and (-not $winget)) {
  Write-Host '    [경고] curl 도 winget 도 없어 설치가 불가할 수 있습니다.' -ForegroundColor Red
}
Write-Host ''

Write-Host '[4] 인터넷 연결 (dl.google.com)'
$net = $false
try {
  $tcp = New-Object System.Net.Sockets.TcpClient
  $iar = $tcp.BeginConnect('dl.google.com', 443, $null, $null)
  if ($iar.AsyncWaitHandle.WaitOne(8000, $false)) {
    try { $tcp.EndConnect($iar); $net = $tcp.Connected } catch { $net = $false }
  }
  $tcp.Close()
} catch { $net = $false }
Write-Host ('    연결 : ' + $(if($net){'성공 (OK)'}else{'실패 또는 시간초과 (!)'}))
Write-Host ''

Write-Host '[5] 현재 설치 상태'
$exe = Find-AndroidCli
Write-Host ('    android : ' + $(if($exe){'이미 설치됨 - ' + $exe}else{'아직 설치 안 됨'}))
Write-Host ''

Write-Host '------------------------------------------------------'
if ($exe) {
  Write-Host '결과: 이미 설치되어 있습니다.  ->  RUN.bat 을 더블클릭해 사용하세요.' -ForegroundColor Green
} elseif (($curl -or $winget) -and $net) {
  Write-Host '결과: 설치 준비 OK. 이제 INSTALL.bat 을 더블클릭하세요.' -ForegroundColor Green
} elseif (-not ($curl -or $winget)) {
  Write-Host '결과: 설치 도구(curl/winget)가 없어 설치가 어렵습니다.' -ForegroundColor Red
} else {
  Write-Host '결과: 인터넷 연결을 확인하세요. 그 외 환경은 정상입니다.' -ForegroundColor Yellow
}
Write-Host '------------------------------------------------------'

if (-not $NoPause) { Pause-Enter }
exit 0
