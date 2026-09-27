@echo off
chcp 65001 >nul
title Đẩy HanLearn lên GitHub
echo ============================================================
echo           CÔNG CỤ ĐẨY CODE HANLEARN LÊN GITHUB
echo ============================================================
echo.
set "PATH=%PATH%;C:\Users\Admin\AppData\Local\Programs\Git\cmd"

set /p REPO_URL="Nhập hoặc dán link GitHub Repo của bạn (VD: https://github.com/.../HanLearn.git): "

if "%REPO_URL%"=="" (
    echo.
    echo [Lỗi] Bạn chưa nhập link. Vui lòng chạy lại file.
    echo.
    pause
    exit /b
)

echo.
echo [1/3] Đang kết nối với Repository...
git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%

echo [2/3] Cấu hình nhánh chính (main)...
git branch -M main

echo [3/3] Đang tải mã nguồn lên GitHub...
echo (Nếu đây là lần đầu, một cửa sổ trình duyệt sẽ hiện lên để bạn bấm "Sign in with browser" xác thực)
echo.
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo [THÀNH CÔNG] Toàn bộ code Swift và bài test đã lên GitHub!
    echo Bây giờ bạn hãy mở GitHub lên và bấm vào tab "Actions" để xem
    echo máy chủ macOS tự động build và chạy test!
    echo ============================================================
) else (
    echo.
    echo [Thông báo] Nếu gặp lỗi xác thực hoặc quyền hạn, hãy kiểm tra lại
    echo xem link Repo đã chính xác chưa hoặc bạn đã đăng nhập đúng tài khoản chưa.
)

echo.
pause
