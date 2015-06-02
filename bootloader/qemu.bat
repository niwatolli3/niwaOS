SET QEMU_DIR="V:\Program\qemu-0.9.0-windows"

%QEMU_DIR%\qemu-system-x86_64.exe -L %QEMU_DIR% -m 128 -fda floppy.img -soundhw all -localtime
