$folder = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " ミリオンクエスト 自動更新ウォッチャー" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "フォルダを監視中: $folder" -ForegroundColor Green
Write-Host "ファイルを保存すると自動でサイトが更新されます。" -ForegroundColor Yellow
Write-Host "終了するにはこのウィンドウを閉じてください。" -ForegroundColor Gray
Write-Host ""

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$timer = $null
$pending = $false

$action = {
    $script:pending = $true
    if ($script:timer) { $script:timer.Stop() }
    $script:timer = New-Object System.Timers.Timer
    $script:timer.Interval = 3000
    $script:timer.AutoReset = $false
    $script:timer.add_Elapsed({
        $script:pending = $false
        Set-Location $folder
        $status = git status --porcelain
        if ($status) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 変更を検出。自動更新中..." -ForegroundColor Yellow
            git add .
            git commit -m "自動更新 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            git push origin main
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 完了！millionquest.jpに反映されます。" -ForegroundColor Green
            Write-Host ""
        }
    })
    $script:timer.Start()
}

Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
Register-ObjectEvent $watcher "Deleted" -Action $action | Out-Null

while ($true) { Start-Sleep -Seconds 1 }
