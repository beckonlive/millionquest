@echo off
cd /d "%~dp0"
echo サイトを更新しています...
git add .
git commit -m "サイト更新"
git push origin main
echo.
echo 完了！1〜2分でmillionquest.jpに反映されます。
pause
