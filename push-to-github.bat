@echo off
chcp 65001 >nul
title Đẩy HanLearn lên GitHub - Hiper2059
echo ============================================================
echo           CÔNG CỤ ĐẨY CODE HANLEARN LÊN GITHUB
echo ============================================================
echo.
echo Tài khoản GitHub của bạn: Hiper2059
echo Repository đích: https://github.com/Hiper2059/HanLearn.git
echo.

set "PATH=%PATH%;C:\Users\Admin\AppData\Local\Programs\Git\cmd"

echo [1/3] Đang kết nối với Repository...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/Hiper2059/HanLearn.git

echo [2/3] Cấu hình nhánh chính (main)...
git branch -M main

echo [3/3] Đang tải mã nguồn lên GitHub...
echo.
echo * CHÚ Ý: Nếu hệ thống yêu cầu:
echo   - Username: nhập Hiper2059
echo   - Password: nhập GitHub Personal Access Token (PAT) của bạn
echo.
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo [THÀNH CÔNG] Toàn bộ code Swift và bài test đã lên GitHub!
    echo Hãy mở trình duyệt xem kết quả test tự động tại:
    echo https://github.com/Hiper2059/HanLearn/actions
    echo ============================================================
) else (
    echo.
    echo [Lưu ý nếu gặp lỗi]:
    echo 1. Hãy đảm bảo bạn đã bấm "Create repository" trên GitHub với tên "HanLearn".
    echo 2. Khi Git hỏi Password, hãy dùng GitHub Token (PAT), không dùng mật khẩu thường.
)

echo.
pause
