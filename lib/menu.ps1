# menu.ps1 - Android CLI One-Click Kit : 메뉴
# 이 파일은 UTF-8 (BOM) 로 저장됩니다.
. (Join-Path $PSScriptRoot 'common.ps1')
Set-Utf8Console

function Show-Status {
    $p = Find-AndroidCli
    if ($p) { return "설치됨  ($p)" }
    return '설치 안 됨  (먼저 INSTALL.bat 실행)'
}

function Invoke-Android {
    param([string[]]$ArgList)
    $exe = Find-AndroidCli
    if (-not $exe) {
        Write-Host "'android' 를 찾을 수 없습니다. 먼저 INSTALL.bat 을 실행하세요." -ForegroundColor Red
        return
    }
    Write-Host (">> android " + ($ArgList -join ' ')) -ForegroundColor DarkGray
    & $exe @ArgList
}

:menu while ($true) {
    Clear-Host
    Write-Host '======================================================'
    Write-Host '   Android CLI 원클릭 메뉴'
    Write-Host '======================================================'
    Write-Host ("   상태: " + (Show-Status))
    Write-Host '------------------------------------------------------'
    Write-Host '   1) 설치 / 상태 확인'
    Write-Host '   2) 새 프로젝트 만들기'
    Write-Host '   3) Android SDK 관리'
    Write-Host '   4) 스킬(skills) 추가'
    Write-Host '   5) 문서 검색'
    Write-Host '   6) 업데이트'
    Write-Host '   7) 도움말 (개발자용, 영어)'
    Write-Host '   8) [안내] 가상 폰 화면(에뮬레이터)은 10번(Android Studio)에서'
    Write-Host '   9) 쉬운 설명 (이게 다 뭔가요?)'
    Write-Host '  10) Android Studio 받기 (선택, 화면 보며 개발용)'
    Write-Host '   0) 종료'
    Write-Host '======================================================'
    Write-Host '   처음이면 9) 쉬운 설명 을, 그다음 1) 을 눌러보세요.'
    $sel = (Read-Host ' 원하는 번호를 입력하고 Enter 를 누르세요').Trim()

    switch ($sel) {
        '1' {
            $p = Find-AndroidCli
            if ($p) {
                Write-Host '설치 정상 확인됨!' -ForegroundColor Green
                Write-Host ("위치: " + $p)
                Write-Host '환경 정보(SDK 위치 / 버전):'
                Invoke-Android @('info')
                Write-Host ''
                Write-Host '(전체 명령 목록/도움말이 필요하면 7번을 누르세요.)'
            } else {
                Write-Host '설치되어 있지 않습니다. INSTALL.bat 을 먼저 실행하세요.' -ForegroundColor Red
            }
            Pause-Enter
        }
        '2' {
            $name = (Read-Host ' 앱(프로젝트) 이름 (그냥 Enter 치면 MyAndroidApp)').Trim()
            if (-not $name) { $name = 'MyAndroidApp'; Write-Host ('이름을 ' + $name + ' 로 정했습니다.') }
            $prompt = ' 만들 폴더 경로 (그냥 Enter 치면 현재 폴더 아래 "' + $name + '")'
            $out = (Read-Host $prompt).Trim()
            if (-not $out) { $out = (Join-Path (Get-Location) $name) }
            Invoke-Android @('create','empty-activity',"--name=$name","--output=$out")
            Pause-Enter
        }
        '3' {
            Write-Host ' a) 설치 가능한/설치된 SDK 목록 보기'
            Write-Host ' b) SDK 패키지 설치'
            Write-Host ' c) SDK 업데이트'
            $s = (Read-Host ' 선택 (a/b/c, 그 외 키 = 취소)').Trim().ToLower()
            switch ($s) {
                'a' { Invoke-Android @('sdk','list','--all') }
                'b' {
                    $pkg = (Read-Host ' 설치할 패키지 (예: platforms/android-34)').Trim()
                    if ($pkg) { Invoke-Android @('sdk','install',$pkg) } else { Write-Host '취소' }
                }
                'c' { Invoke-Android @('sdk','update') }
                default { Write-Host '취소' }
            }
            Pause-Enter
        }
        '4' {
            Write-Host '모든 공식 스킬을 현재 폴더 프로젝트(.)에 추가합니다.'
            $ok = (Read-Host ' 진행할까요? (y/N)').Trim().ToLower()
            if ($ok -eq 'y') { Invoke-Android @('skills','add','--all','--project=.') } else { Write-Host '취소' }
            Pause-Enter
        }
        '5' {
            $q = (Read-Host ' 검색할 내용').Trim()
            if ($q) { Invoke-Android @('docs','search',$q) } else { Write-Host '취소' }
            Pause-Enter
        }
        '6' { Invoke-Android @('update'); Pause-Enter }
        '7' { Invoke-Android @('help'); Pause-Enter }
        '8' {
            Write-Host ''
            Write-Host '오해 방지: Windows 에서 에뮬레이터(가상 폰)가 "불가능"한 게 아닙니다.'
            Write-Host '이 Android CLI 의 에뮬레이터 "명령"만 Windows 에서 현재 비활성일 뿐이고,'
            Write-Host '가상 폰 화면 자체는 Android Studio 로 Windows 에서 정상 작동합니다.'
            Write-Host ''
            Write-Host ' -> 가상 폰 화면을 쓰려면: 10) Android Studio 받기 (에뮬레이터 포함)'
            Write-Host ' -> 또는 실제 안드로이드 폰을 USB 로 연결'
            Pause-Enter
        }
        '9' {
            Write-Host ''
            Write-Host '== 이게 다 뭔가요? (쉬운 설명) =='
            Write-Host 'Android CLI = 구글이 만든, 안드로이드 앱 개발을 도와주는 도구입니다.'
            Write-Host '이 메뉴에서 할 수 있는 일:'
            Write-Host '  1) 잘 깔렸는지 확인   2) 연습용 앱(프로젝트) 폴더 만들기'
            Write-Host '  3) 개발 부품(SDK) 관리   4) 도움 자료(스킬) 추가'
            Write-Host '  5) 공식 문서 검색   6) 도구 최신으로   7) 영어 도움말'
            Write-Host ' 10) Android Studio(화면 보며 개발하는 큰 프로그램) 받기 - 선택'
            Write-Host '잘 모르면 1) 부터 눌러보세요.'
            Write-Host '안심하세요: 이 메뉴엔 무언가 지우는 기능이 없습니다.'
            Write-Host '       (지우기는 UNINSTALL.bat 이 따로, yes 를 물어본 뒤에만 실행합니다.)'
            Write-Host '윈도우에선 이 CLI 로 "에뮬레이터"만 아직 안 되지만, 10) Android Studio 로는 됩니다.'
            Pause-Enter
        }
        '10' {
            Write-Host ''
            Write-Host 'Android Studio = 화면 보며 개발하는 큰 프로그램(선택 사항)입니다.'
            Write-Host '(Windows 에서 "가상 폰 화면(에뮬레이터)"을 쓰려면 이게 필요합니다.)'
            Write-Host '항상 "최신 안정 버전"을 받는 공식 다운로드 페이지를 엽니다...'
            try {
                Start-Process 'https://developer.android.com/studio?hl=ko'
                Write-Host '브라우저가 열렸습니다.' -ForegroundColor Green
            } catch {
                Write-Host '브라우저를 자동으로 못 열었습니다. 아래 주소를 직접 여세요:' -ForegroundColor Yellow
                Write-Host '   https://developer.android.com/studio?hl=ko'
            }
            Write-Host ''
            Write-Host '----- 페이지에서 받는 순서 (왕초보용) -----'
            Write-Host ' 1. 큰 파란 "Download Android Studio ..." 버튼을 누릅니다.'
            Write-Host ' 2. 두 종류가 보이면 -> ".exe (권장 / Recommended)" 를 고르세요.'
            Write-Host '    (.zip 말고 .exe! .exe 가 설치가 훨씬 쉽습니다.)'
            Write-Host ' 3. 약관 창이 뜨면 -> 맨 아래 "...읽었으며 이에 동의합니다" 를 체크'
            Write-Host '    -> 그 아래 파란 다운로드 버튼을 누릅니다.'
            Write-Host ' 4. 받아지는 파일: android-studio-...-windows.exe (약 1.5GB)'
            Write-Host ' 5. 다 받으면 그 .exe 를 더블클릭 -> Next / Install 계속 -> Finish.'
            Write-Host ''
            Write-Host '참고:'
            Write-Host ' - 약 1.5GB 라 인터넷 속도에 따라 시간이 걸립니다(멈춘 게 아닙니다).'
            Write-Host ' - 이 키트의 UNINSTALL.bat 으로는 지워지지 않습니다(Studio 자체 제거 사용).'
            Write-Host ' - Android CLI 와는 별개이며, 이 키트 사용에 꼭 필요하진 않습니다.'
            Pause-Enter
        }
        '0' { break menu }
        default { Write-Host '잘못된 입력입니다.'; Pause-Enter }
    }
}

Write-Host ''
Write-Host '메뉴를 종료했습니다.'

exit 0
