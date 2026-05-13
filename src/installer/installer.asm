bits 64
default rel

; ============================================================
; extern declarations
; ============================================================
extern printf
extern fprintf
extern fputs
extern fgets
extern fflush
extern fopen
extern fclose
extern puts
extern perror
extern exit
extern malloc
extern free
extern strdup
extern strcpy
extern strncpy
extern strcmp
extern strncmp
extern strcspn
extern strstr
extern strrchr
extern strtoll
extern snprintf
extern sscanf
extern system
extern execl
extern execv
extern access
extern read
extern write
extern open
extern close
extern opendir
extern readdir
extern closedir
extern ioctl
extern tcgetattr
extern tcsetattr
extern mount
extern umount2
extern sync
extern reboot
extern sleep
extern chmod
extern mkdir
extern stat
; (major/minor implemented inline)
extern stdin
extern stdout
extern stderr

; ============================================================
; constants
; ============================================================
%define BLUE        94
%define RED         91
%define YELLOW      93
%define GREEN       92
%define RESET       0
%define WHITE       97
%define DEBUG       0

%define STDIN_FILENO    0
%define STDOUT_FILENO   1

; termios offsets (Linux x86_64 struct termios)
; c_iflag=0, c_oflag=4, c_cflag=8, c_lflag=12, c_cc=17
%define TERMIOS_C_LFLAG 12
%define TERMIOS_C_CC    17
%define TERMIOS_SIZE    60
%define ECHO_FLAG       0x8
%define ICANON_FLAG     0x2
%define VMIN_IDX        6
%define VTIME_IDX       5
%define TCSANOW         0

%define TIOCGWINSZ      0x5413
; winsize: ws_row(u16 off0), ws_col(u16 off2)
%define WINSIZE_COL     2

%define RB_AUTOBOOT     0x01234567
%define RB_POWER_OFF    0x4321fedc
%define MNT_DETACH      2

%define KEY_UP      0
%define KEY_DOWN    1
%define KEY_ENTER   2
%define KEY_J       3
%define KEY_K       4
%define KEY_NONE    5

%define F_OK        0

; ============================================================
; .data section
; ============================================================
section .data

; set_text_color format
fmt_color           db `\x1b[%um`, 0

; clear
str_clear           db `\033[2J\033[H`, 0

; cursor
str_save_cursor     db `\033[s`, 0
str_restore_cursor  db `\033[u`, 0
str_clear_to_end    db `\033[0J`, 0

; separator char (UTF-8 box drawing - = E2 94 80)
sep_char            db 0xE2, 0x94, 0x80, 0
sep_newline         db `\n`, 0

; enter_continue
str_press           db "Press", 0
str_enter_word      db " ENTER ", 0
str_to_continue     db "to continue...", 0

; no_drives_repl
str_no_drives       db "- no drives found!", 0Ah, 0
str_no_drives_help  db "enter exit to remove this shell and bypass the warning. enter docs if you believe you do have a drive. otherwise, you can repair through commands.", 0Ah, 0
str_prompt_gt       db `\n> `, 0
str_exit_cmd        db "exit", 0
str_docs_cmd        db "docs", 0
str_docs1           db "If you believe a drive is present, follow these steps:", 0Ah, 0Ah, 0
str_docs2           db "1) Firmware / BIOS checks:", 0Ah, 0
str_docs3           db "   - Reboot into firmware setup (BIOS/UEFI).", 0Ah, 0
str_docs4           db "   - Ensure the drive is detected by the firmware.", 0Ah, 0
str_docs5           db "   - Disable Intel RST / RAID / VMD and use AHCI mode.", 0Ah, 0
str_docs6           db "   - For NVMe systems, disable VMD if enabled.", 0Ah, 0Ah, 0
str_docs7           db "2) Virtual machines:", 0Ah, 0
str_docs8           db "   - Ensure a virtual disk is attached to the VM.", 0Ah, 0

; list_devices
str_dev_dir         db "/dev", 0
str_sd_pfx          db "sd", 0
str_nvme_pfx        db "nvme", 0
str_mmcblk_pfx      db "mmcblk", 0
str_dev_fmt         db "/dev/%s", 0
str_mountinfo       db "/proc/self/mountinfo", 0
str_mountinfo_fmt   db "%*d %*d %u:%u %*s %*s %*[^-]- %127s", 0
str_r_mode          db "r", 0
str_w_mode          db "w", 0
str_dash_fmt        db "- %s", 0Ah, 0
str_total_fmt       db "total %d", 0Ah, 0

; get_partition
str_nvme_pfx9       db "/dev/nvme", 0
str_mmcblk_pfx11    db "/dev/mmcblk", 0
str_part_p_fmt      db "%sp%d", 0
str_part_fmt        db "%s%d", 0

; wipe_drive
str_sgdisk_zap      db "sgdisk --zap-all %s", 0
str_cmd_echo        db "> %s", 0Ah, 0

; makefs
str_sgdisk_bios     db "sgdisk -n 1:1M:+1M -t 1:ef02 -c 1:\"BIOS boot\" %s", 0
str_sgdisk_efi      db "sgdisk -n 2:0:+512M -t 2:ef00 -c 2:\"EFI System\" %s", 0
str_sgdisk_root     db "sgdisk -n 3:0:0 -t 3:8300 -c 3:\"Redrose Linux\" %s", 0
str_partprobe       db "busybox partprobe %s", 0
str_mkfat           db "mkfs.vfat -F32 %s", 0
str_mke2fs          db "busybox mke2fs -F %s", 0
str_sys_firmware    db "/sys/firmware/efi", 0

; copy_root
str_mounting_fmt    db "  Mounting %s", 0Ah, 0
str_copy_cmd        db "busybox gzip -dc rootfs.tar.gz | busybox tar -xf - -C /mnt --strip-components=1", 0
str_copy_echo       db "> busybox gzip -dc rootfs.tar.gz | busybox tar -xf - -C /mnt --strip-components=1", 0Ah, 0
str_ext2            db "ext2", 0

; install_grub
str_grub_chroot     db "busybox chroot /mnt /bin/sh -c 'export LD_LIBRARY_PATH=/usr/lib:/lib:/usr/lib64:/lib64 &&busybox mkdir -p /proc &&mount -t proc proc /proc && busybox mkdir -p /sys &&mount -t sysfs sys /sys && busybox mkdir -p /dev &&mount -t devtmpfs dev /dev && grub-install", 0
str_grub_efi_args   db " --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck %s --directory=/lib/grub/x86_64-efi'", 0
str_grub_bios_args  db " --target=i386-pc --recheck %s' --directory=/lib/grub/i386-pc", 0
str_mkdir_boot      db "busybox mkdir -p /boot/", 0
str_mkdir_bootefi   db "busybox mkdir -p /boot/efi", 0
str_mounting_esp    db "Mounting ESP", 0Ah, 0
str_vfat            db "vfat", 0
str_boot_efi        db "/boot/efi", 0

; patch
str_rcS_path        db "/mnt/etc/init.d/rcS", 0

; localhost
str_default_host    db "iuseredrosebtw", 0
str_hostname_file   db "/mnt/etc/hostname", 0
str_hostname_fmt    db "%s", 0Ah, 0
str_fopen_err       db "fopen", 0

; umount_detach
str_mnt             db "/mnt", 0

; chroot_
str_chroot_q1       db "Do you wish to chroot into the mounted system before it's unmounted? [N/y] ", 0
str_chroot_q2       db "Do you wish to run /bin/sh in this live enviroment? [N/y] ", 0
str_chroot_cmd      db "busybox chroot /mnt /bin/sh", 0
str_sh_cmd          db "/bin/sh", 0

; create_users
str_default_user    db "redrose", 0
str_mnt_root        db "/mnt/root", 0
str_mnt_home        db "/mnt/home", 0
str_home_fmt        db "/mnt/home/%s", 0
str_useradd_fmt     db "busybox chroot /mnt /bin/adduser -D -h /home/%s %s", 0
str_chpasswd_fmt    db "busybox chroot /mnt /bin/sh -c 'echo \"%s:%s\" | busybox chpasswd'", 0
str_root_chpasswd   db "busybox chroot /mnt /bin/sh -c 'echo \"root:%s\" | busybox chpasswd'", 0

; install_busybox
str_mnt_sbin        db "/mnt/sbin", 0
str_busybox_install db "busybox chroot /mnt /bin/sh -c '/bin/busybox --install'", 0

; propriertary_
str_prop_lock       db "/mnt/etc/car_propiertary.lock", 0
str_prop_fail       db "Enabling propriertary software failed", 0

; init_car
str_car_init        db "busybox yes 1 | busybox chroot /mnt /bin/sh -c '/bin/car init'", 0

; main.c strings
str_running_checks  db "Running checks...", 0Ah, 0
str_no_drive        db "No drive selected. Exiting installer.", 0Ah, 0
str_remember_pass   db "REMEMBER THE DEFAULT PASSWORD ABOVE!", 0Ah, 0
str_installing_to   db `\nInstalling to %s. Are you sure? (Y/n): `, 0
str_restart_q       db "Restart installer? [Y/n]: ", 0
str_reboot_q        db "Reboot or shutdown? [R/s]: ", 0
str_shutdown_msg    db "Shutting down in 5 seconds...", 0
str_reboot_msg      db "Rebooting in 5 seconds...", 0
str_install_bin     db "/bin/install", 0
str_install_arg     db "install", 0
str_newline         db `\n`, 0
str_star            db "* ", 0
str_bold_fmt        db `\e[1m%s\e[0m\n`, 0
str_setup_users     db `\e[1mSetting up user accounts!\e[0m\n`, 0
str_install_fail_msg db `\nInstallation has failed. `, 0
str_report_err      db "Please report the error at our Github Issues: ", 0
str_issues_url      db "https://github.com/redroselinux/redroselinux/issues", 0Ah, 0
str_issues_url2     db "https://github.com/redroselinux/redroselinux/issues", 0Ah, 0Ah, 0
str_thank_you       db "Thank you for installing the Redrose Linux alpha! Reboot to your new system.", 0Ah, 0Ah, 0
str_report_bugs     db "Please report errors on Github Issues: ", 0
str_vm_warning      db "If you are on a VM, after the VM restarts, pick \"Boot existing OS\"", 0Ah, "You can also remove the CD-ROM from the VM. If you see no such option, you can ignore this warning.", 0Ah, 0Ah, 0

; sys/block size path
str_sysblock_fmt    db "/sys/block/%s/size", 0

; tui strings
str_step1           db "step 1/6", 0
str_step2           db "step 2/6", 0
str_step3           db "step 3/6", 0
str_step4           db "step 4/6", 0
str_step5           db "step 5/6", 0
str_step6           db "step 6/6", 0

str_main_hdr_red    db "       _                      _     _                  ", 0Ah
                    db "|  _ \\ ___  __| |_ __ ___  ___  ___  | |   (_)_ __  _   ___  __", 0Ah
                    db "| |_) / _ \\/ _` | '__/ _ \\/ __|/ _ \\ | |   | | '_ \\| | | \\ \\/ /", 0Ah
                    db "|  _ <  __/ (_| | | | (_) \\__ \\  __/ | |___| | | | | |_| |>  < ", 0Ah
                    db "|_| \\_\\___|\\__,_|_|  \\___/|___/\\___| |_____|_|_| |_|\\__,_/_/\\_\\", 0Ah, 0

str_main_hdr_yel    db " ___           _        _ _           ", 0Ah
                    db "|_ _|_ __  ___| |_ __ _| | | ___ _ __ ", 0Ah
                    db " | || '_ \\/ __| __/ _` | | |/ _ \\ '__|  ", 0Ah
                    db " | || | | \\__ \\ || (_| | | |  __/ |   ", 0Ah
                    db "|___|_| |_|___/\\__\\__,_|_|_|\\___|_|   ", 0Ah
                    db "                                      ", 0Ah, 0

str_welcome         db "Welcome to the Redrose Linux Installer!", 0Ah
                    db "Please note that Redrose is still in alpha (alpha-0.5).", 0Ah
                    db "You can report bugs at ", 0

str_issues_nodot    db "https://github.com/redroselinux/redroselinux/issues", 0
str_dot_nl          db ".", 0Ah, 0Ah, 0

str_sel_mode        db "Select installation mode. Use ", 0
str_up_down         db "UP/DOWN", 0
str_or_word         db " or ", 0
str_jk              db "j/k", 0
str_to_move         db " to move, ", 0
str_enter_word2     db "ENTER", 0
str_to_select       db " to select.", 0Ah, 0Ah, 0

str_arrow_sel       db "  > ", 0
str_four_spaces     db "    ", 0

str_opt_guided      db "Guided install", 0
str_opt_manual      db "Manual install (drop to shell)", 0

str_sh_path         db "/bin/sh", 0
str_sh_arg          db "/bin/sh", 0

; localization header
str_loc_hdr         db "              _ _          _   _", 0Ah
                    db "| |    ___   ___ __ _| (_)______ _| |_(_) ___  _ __", 0Ah
                    db "| |   / _ \\ / __/ _` | | |_  / _` | __| |/ _ \\| '_ \\", 0Ah
                    db "| |__| (_) | (_| (_| | | |/ / (_| | |_| | (_) | | | |", 0Ah
                    db "|_____\\___/ \\___\\__,_|_|_/___\\__,_|\\__|_|\\___/|_| |_|", 0Ah, 0Ah, 0

str_loc_note        db `\nPicking a keyboard layout or language would NOT change anything in\nthe current live enviroment. They only affect the installed system.\n\n`, 0
str_kb_prompt       db `\nKeyboard layout [us]: `, 0
str_us_default      db "us", 0

str_lang_prompt     db "Language [us]: ", 0
str_tz_prompt       db "Timezone (enter name of your city or country or UTC+/-*) [UTC+0]: ", 0

; disk_header
str_disk_hdr        db "       _        _ _       _   _               ____       _", 0Ah
                    db "|_ _|_ __  ___| |_ __ _| | | __ _| |_(_) ___  _ __   |  _ \\ _ __(_)_   _____", 0Ah
                    db " | || '_ \\/ __| __/ _` | | |/ _` | __| |/ _ \\| '_ \\  | | | | '__| \\ \\ / / _ \\", 0Ah
                    db " | || | | \\__ \\ || (_| | | | (_| | |_| | (_) | | | | | |_| | |  | |\\  V /  __/", 0Ah
                    db "|___|_| |_|___/\\__\\__,_|_|_|\\__,_|\\__|_|\\___/|_| |_| |____/|_|  |_| \\_/ \\___|  ", 0Ah, 0Ah, 0

str_disk_warning    db `\nPlease be extremely careful. This operation is NOT reversible!\n`, 0

; user_creation header
str_user_hdr        db "                ____                _   _", 0Ah
                    db "| | | |___  ___ _ __   / ___|_ __ ___  __ _| |_(_) ___  _ __", 0Ah
                    db "| | | / __|/ _ \\ '__| | |   | '__/ _ \\/ _` | __| |/ _ \\| '_ \\", 0Ah
                    db "| |_| \\__ \\  __/ |    | |___| | |  __/ (_| | |_| | (_) | | | |", 0Ah
                    db " \\___/|___/\\___|_|     \\____|_|  \\___|\\__,_|\\__|_|\\___/|_| |_|", 0Ah, 0Ah, 0

str_user_note       db `\nSet up the user. Make a memorizable password or leave blank\nfor the defaults.\n\n`, 0
str_username_prompt db "Your username [redrose]: ", 0
str_userpass_prompt db "Password to this account [redrose]: ", 0
str_rootpass_prompt db "Password to root [redrose]: ", 0
str_hostname_prompt db "Hostname [iuseredrosebtw]: ", 0
str_prop_prompt     db "BTW, enable proprietary software? (y/n) [n]: ", 0

; installing_header
str_inst_hdr        db "       _        _ _ _", 0Ah
                    db "|_ _|_ __  ___| |_ __ _| | (_)_ __   __ _", 0Ah
                    db " | || '_ \\/ __| __/ _` | | | | '_ \\ / _` |", 0Ah
                    db " | || | | \\__ \\ || (_| | | | | | | | (_| |", 0Ah
                    db "|___|_| |_|___/\\__\\__,_|_|_|_|_| |_|\\__, |", 0Ah
                    db "                                    |___/", 0Ah, 0

; installed_header
str_insted_hdr      db "       _        _ _          _ ", 0Ah
                    db "|_ _|_ __  ___| |_ __ _| | | ___  __| |", 0Ah
                    db " | || '_ \\/ __| __/ _` | | |/ _ \\/ _` |", 0Ah
                    db " | || | | \\__ \\ || (_| | | |  __/ (_| |", 0Ah
                    db "|___|_| |_|___/\\__\\__,_|_|_|\\___|\\__,_|", 0Ah, 0Ah, 0

; install_failed
str_failed_hdr      db " _____     _ _          _ ", 0Ah
                    db "|  ___|_ _(_) | ___  __| |", 0Ah
                    db "| |_ / _` | | |/ _ \\/ _` |", 0Ah
                    db "|  _| (_| | | |  __/ (_| |", 0Ah
                    db "|_|  \\__,_|_|_|\\___|\\__,_|", 0Ah, 0Ah, 0

; misc
str_fflush_null     db "", 0

; run_installation_step
str_choose_opt      db "Choose an option!", 0
str_erase_drive     db "Erasing the drive!", 0
str_make_fs         db "Making filesystems!", 0
str_copy_root_s     db "Copying root!", 0
str_setup_user_s    db "Setting up user accounts!", 0
str_inst_grub       db "Installing GRUB!", 0
str_prop_s          db "Enabling propriertary software!", 0
str_hostname_s      db "Setting hostname!", 0
str_init_car_s      db "Initializing Car!", 0
str_inst_bb         db "Installing BusyBox!", 0
str_unmount_s       db "Unmounting root!", 0
str_patches_s       db "Running patches!", 0
str_empty           db "", 0

; ============================================================
; .bss section
; ============================================================
section .bss

get_partition_buf   resb 64
orig_term           resb 60          ; struct termios
winsize_buf         resb 8           ; struct winsize (4 x u16)
cur_dev_buf         resb 128
cur_dev_line        resb 512
cmd_buf_256         resb 256
cmd_buf_1024        resb 1024
home_dir_buf        resb 50
useradd_buf         resb 256
sanitized_buf       resb 128
drives_arr          resq 64          ; char* drives[64]
size_str_buf        resb 64
sysblock_path_buf   resb 256
command_buf_4096    resb 4096
mountinfo_line      resb 512

; ============================================================
; .text section
; ============================================================
section .text

; ============================================================
; set_text_color(unsigned color) -> int
; rdi = color
; ============================================================
global set_text_color
set_text_color:
    push    rbp
    mov     rbp, rsp
    mov     rsi, rdi
    lea     rdi, [fmt_color]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

; ============================================================
; clear() -> int
; ============================================================
global clear
clear:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_clear]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

save_cursor:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_save_cursor]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

restore_cursor:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_restore_cursor]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

clear_to_end:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_clear_to_end]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

; ============================================================
; separator()
; ============================================================
global separator
separator:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rdi, STDOUT_FILENO
    mov     rsi, TIOCGWINSZ
    lea     rdx, [winsize_buf]
    call    ioctl
    movzx   ecx, word [winsize_buf + WINSIZE_COL]
    test    ecx, ecx
    jnz     .got_width
    mov     ecx, 80
.got_width:
    mov     ebx, ecx
.loop:
    test    ebx, ebx
    jz      .done
    lea     rdi, [sep_char]
    xor     eax, eax
    call    printf
    dec     ebx
    jmp     .loop
.done:
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; disable_echo()
; ============================================================
global disable_echo
disable_echo:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 64
    mov     rdi, STDIN_FILENO
    lea     rsi, [orig_term]
    call    tcgetattr
    test    eax, eax
    jge     .ok
    lea     rdi, [str_tcgetattr_err]
    call    perror
    mov     rdi, 1
    call    exit
.ok:
    lea     rsi, [orig_term]
    lea     rdi, [rsp]
    mov     ecx, TERMIOS_SIZE
    rep     movsb
    and     dword [rsp + TERMIOS_C_LFLAG], 0xFFFFFFF7
    mov     rdi, STDIN_FILENO
    mov     rsi, TCSANOW
    lea     rdx, [rsp]
    call    tcsetattr
    test    eax, eax
    jge     .out
    lea     rdi, [str_tcsetattr_err]
    call    perror
    mov     rdi, 1
    call    exit
.out:
    add     rsp, 64
    pop     rbp
    ret

; ============================================================
; enable_echo()
; ============================================================
global enable_echo
enable_echo:
    push    rbp
    mov     rbp, rsp
    mov     rdi, STDIN_FILENO
    mov     rsi, TCSANOW
    lea     rdx, [orig_term]
    call    tcsetattr
    test    eax, eax
    jge     .ok
    lea     rdi, [str_tcsetattr_restore_err]
    call    perror
    mov     rdi, 1
    call    exit
.ok:
    pop     rbp
    ret

; ============================================================
; read_key() -> int
; ============================================================
read_key:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 136
    mov     rdi, STDIN_FILENO
    lea     rsi, [rsp]
    call    tcgetattr
    test    eax, eax
    jnz     .ret_none
    lea     rsi, [rsp]
    lea     rdi, [rsp+60]
    mov     ecx, TERMIOS_SIZE
    rep     movsb
    and     dword [rsp+60 + TERMIOS_C_LFLAG], 0xFFFFFFF5
    mov     byte [rsp+60 + TERMIOS_C_CC + VMIN_IDX], 1
    mov     byte [rsp+60 + TERMIOS_C_CC + VTIME_IDX], 0
    mov     rdi, STDIN_FILENO
    mov     rsi, TCSANOW
    lea     rdx, [rsp+60]
    call    tcsetattr
    test    eax, eax
    jnz     .restore_none
    lea     r12, [rsp+120]
    mov     rdi, STDIN_FILENO
    mov     rsi, r12
    mov     rdx, 1
    call    read
    cmp     rax, 1
    jne     .restore_none
    movzx   ebx, byte [r12]
    cmp     bl, 27
    je      .escape
    mov     rdi, STDIN_FILENO
    mov     rsi, TCSANOW
    lea     rdx, [rsp]
    call    tcsetattr
    cmp     bl, 10
    je      .ret_enter
    cmp     bl, 13
    je      .ret_enter
    cmp     bl, 'j'
    je      .ret_down
    cmp     bl, 'J'
    je      .ret_down
    cmp     bl, 'k'
    je      .ret_up
    cmp     bl, 'K'
    je      .ret_up
    jmp     .ret_none_val
.escape:
    mov     rdi, STDIN_FILENO
    mov     rsi, r12
    mov     rdx, 1
    call    read
    cmp     rax, 1
    jne     .restore_none
    movzx   ecx, byte [r12]
    cmp     cl, '['
    je      .bracket
    cmp     cl, 'O'
    je      .bracket
    jmp     .restore_none
.bracket:
    mov     rdi, STDIN_FILENO
    mov     rsi, r12
    mov     rdx, 1
    call    read
    cmp     rax, 1
    jne     .restore_none
    movzx   ecx, byte [r12]
    mov     rdi, STDIN_FILENO
    mov     rsi, TCSANOW
    lea     rdx, [rsp]
    call    tcsetattr
    cmp     cl, 'A'
    je      .ret_up
    cmp     cl, 'B'
    je      .ret_down
    jmp     .ret_none_val
.restore_none:
    mov     rdi, STDIN_FILENO
    mov     rsi, TCSANOW
    lea     rdx, [rsp]
    call    tcsetattr
    jmp     .ret_none_val
.ret_up:
    mov     eax, KEY_UP
    jmp     .done
.ret_down:
    mov     eax, KEY_DOWN
    jmp     .done
.ret_enter:
    mov     eax, KEY_ENTER
    jmp     .done
.ret_none:
.ret_none_val:
    mov     eax, KEY_NONE
.done:
    add     rsp, 136
    pop     rbx
    pop     rbp
    ret

; ============================================================
; enter_continue()
; ============================================================
global enter_continue
enter_continue:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 256
    lea     rdi, [str_press]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_enter_word]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_to_continue]
    xor     eax, eax
    call    printf
    call    disable_echo
    lea     rdi, [rsp]
    mov     rsi, 256
    mov     rdx, [stdin]
    call    fgets
    call    enable_echo
    call    clear
    add     rsp, 256
    pop     rbp
    ret

; ============================================================
; no_drives_repl() [static]
; ============================================================
no_drives_repl:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    sub     rsp, 4120
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_no_drives]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_no_drives_help]
    xor     eax, eax
    call    printf
.loop:
    mov     rdi, GREEN
    call    set_text_color
    lea     rdi, [str_prompt_gt]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [rsp]
    mov     rsi, 4096
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jz      .break
    lea     rdi, [rsp]
    lea     rsi, [sep_newline]
    call    strcspn
    mov     byte [rsp + rax], 0
    lea     rdi, [rsp]
    lea     rsi, [str_exit_cmd]
    call    strcmp
    test    eax, eax
    jz      .break
    lea     rdi, [rsp]
    lea     rsi, [str_docs_cmd]
    call    strcmp
    test    eax, eax
    jnz     .run_cmd
    lea     rdi, [str_docs1]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs2]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs3]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs4]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs5]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs6]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs7]
    xor     eax, eax
    call    printf
    lea     rdi, [str_docs8]
    xor     eax, eax
    call    printf
    jmp     .loop
.run_cmd:
    lea     rdi, [rsp]
    call    system
    jmp     .loop
.break:
    add     rsp, 4120
    pop     r12
    pop     rbx
    pop     rbp
    ret

section .data
str_tcgetattr_err       db "tcgetattr", 0
str_tcsetattr_err       db "tcsetattr", 0
str_tcsetattr_restore_err db "tcsetattr restore", 0

section .text

; ============================================================
; list_devices(char *drives[64], int max) -> int
; rdi = drives[], rsi = max
; ============================================================
global list_devices
list_devices:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp, 40
    mov     r12, rdi
    mov     r13d, esi
    lea     rdi, [str_dev_dir]
    call    opendir
    test    rax, rax
    jnz     .dir_ok
    lea     rdi, [str_dev_dir]
    call    perror
    xor     eax, eax
    jmp     .ret
.dir_ok:
    mov     r14, rax
    sub     rsp, 160
    lea     rdi, [dot_str]
    lea     rsi, [rsp]
    call    stat
    mov     rax, [rsp]
    mov     rcx, rax
    shr     rcx, 8
    and     ecx, 0xfff
    mov     rdx, rax
    shr     rdx, 32
    and     edx, 0xfffff000
    or      ecx, edx
    mov     r15d, ecx
    mov     rcx, rax
    and     ecx, 0xff
    mov     rdx, rax
    shr     rdx, 12
    and     edx, 0xffffff00
    or      ecx, edx
    mov     ebx, ecx
    add     rsp, 160
    lea     rdi, [str_mountinfo]
    lea     rsi, [str_r_mode]
    call    fopen
    test    rax, rax
    jz      .no_mountinfo
    push    rax
    lea     rdi, [cur_dev_buf]
    xor     eax, eax
    mov     ecx, 128
    rep     stosb
.mi_loop:
    mov     rax, [rsp]
    lea     rdi, [mountinfo_line]
    mov     rsi, 512
    mov     rdx, rax
    call    fgets
    test    rax, rax
    jz      .mi_done
    sub     rsp, 160
    lea     rdi, [mountinfo_line]
    lea     rsi, [str_mountinfo_fmt]
    lea     rdx, [rsp]
    lea     rcx, [rsp+4]
    lea     r8, [rsp+8]
    xor     eax, eax
    call    sscanf
    cmp     eax, 3
    jne     .mi_next
    mov     eax, [rsp]
    cmp     eax, r15d
    jne     .mi_next
    mov     eax, [rsp+4]
    cmp     eax, ebx
    jne     .mi_next
    lea     rdi, [cur_dev_buf]
    lea     rsi, [rsp+8]
    mov     rdx, 127
    call    strncpy
    add     rsp, 160
    jmp     .mi_done
.mi_next:
    add     rsp, 160
    jmp     .mi_loop
.mi_done:
    pop     rdi
    call    fclose
.no_mountinfo:
    mov     r13d, [rbp-24]
    xor     r15d, r15d
.readdir_loop:
    cmp     r15d, r13d
    jge     .readdir_done
    mov     rdi, r14
    call    readdir
    test    rax, rax
    jz      .readdir_done
    lea     rbx, [rax + 19]
    mov     rdi, rbx
    lea     rsi, [str_sd_pfx]
    mov     rdx, 2
    call    strncmp
    test    eax, eax
    jz      .name_ok
    mov     rdi, rbx
    lea     rsi, [str_nvme_pfx]
    mov     rdx, 4
    call    strncmp
    test    eax, eax
    jz      .name_ok
    mov     rdi, rbx
    lea     rsi, [str_mmcblk_pfx]
    mov     rdx, 6
    call    strncmp
    test    eax, eax
    jnz     .readdir_loop
.name_ok:
    cmp     byte [cur_dev_buf], 0
    jz      .no_cur_dev_check
    lea     rdi, [cur_dev_buf]
    mov     rsi, rbx
    call    strstr
    test    rax, rax
    jnz     .readdir_loop
.no_cur_dev_check:
    push    rbx
    push    r15
    mov     rdi, 32
    call    malloc
    pop     r15
    pop     rbx
    test    rax, rax
    jz      .readdir_done
    mov     [r12 + r15*8], rax
    push    rax
    push    r15
    mov     rdi, rax
    mov     rsi, 32
    lea     rdx, [str_dev_fmt]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    pop     r15
    pop     rax
    inc     r15d
    jmp     .readdir_loop
.readdir_done:
    mov     rdi, r14
    call    closedir
    test    r15d, r15d
    jnz     .has_drives
    call    no_drives_repl
.has_drives:
    mov     eax, r15d
.ret:
    add     rsp, 40
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

section .data
dot_str     db ".", 0
section .text

; ============================================================
; list_dev() -> int
; ============================================================
global list_dev
list_dev:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    sub     rsp, 520
    lea     rdi, [rsp]
    mov     rsi, 64
    call    list_devices
    mov     r12d, eax
    test    r12d, r12d
    jz      .done
    xor     ebx, ebx
.loop:
    cmp     ebx, r12d
    jge     .print_total
    mov     rax, [rsp + rbx*8]
    lea     rdi, [str_dash_fmt]
    mov     rsi, rax
    xor     eax, eax
    call    printf
    mov     rdi, [rsp + rbx*8]
    call    free
    inc     ebx
    jmp     .loop
.print_total:
    mov     rdi, GREEN
    call    set_text_color
    lea     rdi, [str_total_fmt]
    mov     esi, r12d
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    mov     eax, r12d
.done:
    add     rsp, 520
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================
; get_partition(const char* drive, int partnum) -> char*
; ============================================================
global get_partition
get_partition:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    sub     rsp, 8
    mov     rbx, rdi
    mov     r12d, esi
    mov     rdi, rbx
    lea     rsi, [str_nvme_pfx9]
    mov     rdx, 9
    call    strncmp
    test    eax, eax
    jz      .use_p
    mov     rdi, rbx
    lea     rsi, [str_mmcblk_pfx11]
    mov     rdx, 11
    call    strncmp
    test    eax, eax
    jz      .use_p
    lea     rdi, [get_partition_buf]
    mov     rsi, 64
    lea     rdx, [str_part_fmt]
    mov     rcx, rbx
    mov     r8d, r12d
    xor     eax, eax
    call    snprintf
    jmp     .done
.use_p:
    lea     rdi, [get_partition_buf]
    mov     rsi, 64
    lea     rdx, [str_part_p_fmt]
    mov     rcx, rbx
    mov     r8d, r12d
    xor     eax, eax
    call    snprintf
.done:
    lea     rax, [get_partition_buf]
    add     rsp, 8
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================
; detect_efi() -> int   (64=UEFI, 32=BIOS)
; ============================================================
global detect_efi
detect_efi:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_sys_firmware]
    mov     esi, F_OK
    call    access
    test    eax, eax
    jnz     .bios
    mov     eax, 64
    pop     rbp
    ret
.bios:
    mov     eax, 32
    pop     rbp
    ret

; ============================================================
; wipe_drive(char* drive) -> int
; ============================================================
global wipe_drive
wipe_drive:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 264
    mov     rbx, rdi
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_sgdisk_zap]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    lea     rdi, [str_cmd_echo]
    lea     rsi, [rsp]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    lea     rdi, [rsp]
    call    system
    add     rsp, 264
    pop     rbx
    pop     rbp
    ret

; ============================================================
; makefs(char* drive) -> int
; ============================================================
global makefs
makefs:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    sub     rsp, 264
    mov     rbx, rdi
    call    detect_efi
    cmp     eax, 32
    jne     .efi_mode
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_sgdisk_bios]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    jmp     .run_first
.efi_mode:
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_sgdisk_efi]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
.run_first:
    lea     rdi, [str_cmd_echo]
    lea     rsi, [rsp]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    lea     rdi, [rsp]
    call    system
    test    eax, eax
    jnz     .fail1
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_sgdisk_root]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    lea     rdi, [str_cmd_echo]
    lea     rsi, [rsp]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    lea     rdi, [rsp]
    call    system
    test    eax, eax
    jnz     .fail1
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_partprobe]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    lea     rdi, [str_cmd_echo]
    lea     rsi, [rsp]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    lea     rdi, [rsp]
    call    system
    test    eax, eax
    jnz     .fail1
    mov     rdi, rbx
    mov     esi, 2
    call    get_partition
    mov     r12, rax
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_mkfat]
    mov     rcx, r12
    xor     eax, eax
    call    snprintf
    lea     rdi, [str_cmd_echo]
    lea     rsi, [rsp]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    lea     rdi, [rsp]
    call    system
    test    eax, eax
    jnz     .fail1
    mov     rdi, rbx
    mov     esi, 3
    call    get_partition
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_mke2fs]
    mov     rcx, rax
    xor     eax, eax
    call    snprintf
    lea     rdi, [str_cmd_echo]
    lea     rsi, [rsp]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    lea     rdi, [rsp]
    call    system
    jmp     .out
.fail1:
    mov     eax, 1
.out:
    add     rsp, 264
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================
; copy_root(char* drive) -> int
; ============================================================
global copy_root
copy_root:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rbx, rdi
    mov     rdi, rbx
    mov     esi, 3
    call    get_partition
    lea     rdi, [str_mounting_fmt]
    mov     rsi, rax
    xor     eax, eax
    call    printf
    mov     rdi, rbx
    mov     esi, 3
    call    get_partition
    mov     rdi, rax
    lea     rsi, [str_mnt]
    lea     rdx, [str_ext2]
    xor     ecx, ecx
    xor     r8d, r8d
    call    mount
    lea     rdi, [str_copy_echo]
    xor     eax, eax
    call    printf
    lea     rdi, [str_copy_cmd]
    call    system
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; install_grub(char* drive) -> int
; ============================================================
global install_grub
install_grub:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    sub     rsp, 1032
    mov     rbx, rdi
    call    detect_efi
    cmp     eax, 64
    jne     .bios_grub
    lea     rdi, [str_mounting_esp]
    xor     eax, eax
    call    printf
    lea     rdi, [str_mkdir_boot]
    call    system
    lea     rdi, [str_mkdir_bootefi]
    call    system
    mov     rdi, rbx
    mov     esi, 2
    call    get_partition
    mov     rdi, rax
    lea     rsi, [str_boot_efi]
    lea     rdx, [str_vfat]
    xor     ecx, ecx
    xor     r8d, r8d
    call    mount
    lea     rdi, [rsp]
    mov     rsi, 1024
    lea     rdx, [str_grub_efi_full_fmt]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    jmp     .run_grub
.bios_grub:
    lea     rdi, [rsp]
    mov     rsi, 1024
    lea     rdx, [str_grub_bios_full_fmt]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
.run_grub:
    lea     rdi, [rsp]
    call    system
    add     rsp, 1032
    pop     r12
    pop     rbx
    pop     rbp
    ret

section .data
str_grub_efi_full_fmt   db "busybox chroot /mnt /bin/sh -c 'export LD_LIBRARY_PATH=/usr/lib:/lib:/usr/lib64:/lib64 &&busybox mkdir -p /proc &&mount -t proc proc /proc && busybox mkdir -p /sys &&mount -t sysfs sys /sys && busybox mkdir -p /dev &&mount -t devtmpfs dev /dev && grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck %s --directory=/lib/grub/x86_64-efi'", 0
str_grub_bios_full_fmt  db "busybox chroot /mnt /bin/sh -c 'export LD_LIBRARY_PATH=/usr/lib:/lib:/usr/lib64:/lib64 &&busybox mkdir -p /proc &&mount -t proc proc /proc && busybox mkdir -p /sys &&mount -t sysfs sys /sys && busybox mkdir -p /dev &&mount -t devtmpfs dev /dev && grub-install --target=i386-pc --recheck %s' --directory=/lib/grub/i386-pc", 0
section .text

; ============================================================
; patch(char* drive) -> int
; ============================================================
global patch
patch:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_rcS_path]
    mov     rsi, 0o755
    call    chmod
    xor     eax, eax
    pop     rbp
    ret

; ============================================================
; localhost(char* name) -> int
; ============================================================
global localhost
localhost:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rbx, rdi
    movzx   eax, byte [rbx]
    cmp     al, 10
    je      .use_default
    cmp     al, 0
    je      .use_default
    mov     rdi, rbx
    lea     rsi, [sep_newline]
    call    strcspn
    mov     byte [rbx + rax], 0
    jmp     .open_file
.use_default:
    lea     rbx, [str_default_host]
.open_file:
    lea     rdi, [str_hostname_file]
    lea     rsi, [str_w_mode]
    call    fopen
    test    rax, rax
    jnz     .write_host
    lea     rdi, [str_fopen_err]
    call    perror
    mov     eax, -1
    jmp     .done
.write_host:
    mov     [rsp], rax
    mov     rdi, rax
    lea     rsi, [str_hostname_fmt]
    mov     rdx, rbx
    xor     eax, eax
    call    fprintf
    mov     rdi, [rsp]
    call    fclose
    xor     eax, eax
.done:
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; umount_detach(char* path) -> int
; ============================================================
global umount_detach
umount_detach:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rbx, rdi
    call    sync
    mov     rdi, rbx
    mov     esi, MNT_DETACH
    call    umount2
    test    eax, eax
    jz      .ok
    mov     eax, -1
    jmp     .done
.ok:
    xor     eax, eax
.done:
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; chroot_(char* h) -> int
; ============================================================
global chroot_
chroot_:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16
    lea     rdi, [str_chroot_q1]
    xor     eax, eax
    call    printf
    lea     rdi, [rsp]
    mov     rsi, 8
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jz      .q2
    movzx   eax, byte [rsp]
    cmp     al, 'y'
    je      .do_chroot
    cmp     al, 'Y'
    je      .do_chroot
    jmp     .q2
.do_chroot:
    lea     rdi, [str_chroot_cmd]
    call    system
.q2:
    lea     rdi, [str_chroot_q2]
    xor     eax, eax
    call    printf
    lea     rdi, [rsp]
    mov     rsi, 8
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jz      .done
    movzx   eax, byte [rsp]
    cmp     al, 'y'
    je      .do_sh
    cmp     al, 'Y'
    je      .do_sh
    jmp     .done
.do_sh:
    lea     rdi, [str_sh_cmd]
    call    system
.done:
    xor     eax, eax
    add     rsp, 16
    pop     rbp
    ret

; ============================================================
; sanitize_input(char* input) -> int
; ============================================================
global sanitize_input
sanitize_input:
    push    rbp
    mov     rbp, rsp
    mov     rax, rdi
.loop:
    movzx   ecx, byte [rax]
    test    cl, cl
    jz      .done
    cmp     cl, '$'
    je      .replace
    cmp     cl, '('
    je      .replace
    cmp     cl, ')'
    je      .replace
    cmp     cl, ';'
    je      .replace
    cmp     cl, 0x27
    je      .replace
    jmp     .next
.replace:
    mov     byte [rax], '_'
.next:
    inc     rax
    jmp     .loop
.done:
    xor     eax, eax
    pop     rbp
    ret

; ============================================================
; create_users(char* username, char* password, char* root_password) -> int
; ============================================================
global create_users
create_users:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp, 312
    mov     rbx, rdi
    mov     r12, rsi
    mov     r13, rdx
    mov     rdi, rbx
    lea     rsi, [sep_newline]
    call    strcspn
    mov     byte [rbx + rax], 0
    cmp     byte [rbx], 0
    jne     .user_ok
    mov     rdi, rbx
    lea     rsi, [str_default_user]
    call    strcpy
.user_ok:
    mov     rdi, r12
    lea     rsi, [sep_newline]
    call    strcspn
    mov     byte [r12 + rax], 0
    cmp     byte [r12], 0
    jne     .pass_ok
    mov     rdi, r12
    lea     rsi, [str_default_user]
    call    strcpy
.pass_ok:
    lea     rdi, [str_mnt_root]
    mov     esi, 0o755
    call    mkdir
    mov     rdi, r13
    lea     rsi, [sep_newline]
    call    strcspn
    mov     byte [r13 + rax], 0
    cmp     byte [r13], 0
    jne     .rpass_ok
    mov     rdi, r13
    lea     rsi, [str_default_user]
    call    strcpy
.rpass_ok:
    lea     rdi, [str_mnt_home]
    mov     esi, 0o755
    call    mkdir
    lea     rdi, [rsp+256]
    mov     rsi, 50
    lea     rdx, [str_home_fmt]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    lea     rdi, [rsp+256]
    mov     esi, 0o755
    call    mkdir
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_useradd_fmt]
    mov     rcx, rbx
    mov     r8, rbx
    xor     eax, eax
    call    snprintf
    lea     rdi, [rsp]
    call    system
    test    eax, eax
    jz      .useradd_ok
    mov     eax, 1
    jmp     .create_done
.useradd_ok:
    lea     rdi, [sanitized_buf]
    mov     rsi, r12
    mov     rdx, 127
    call    strncpy
    mov     byte [sanitized_buf + 127], 0
    lea     rdi, [sanitized_buf]
    call    sanitize_input
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_chpasswd_fmt]
    mov     rcx, rbx
    lea     r8, [sanitized_buf]
    xor     eax, eax
    call    snprintf
    lea     rdi, [rsp]
    call    system
    test    eax, eax
    jz      .user_pass_ok
    mov     eax, 1
    jmp     .create_done
.user_pass_ok:
    lea     rdi, [sanitized_buf]
    mov     rsi, r13
    mov     rdx, 127
    call    strncpy
    mov     byte [sanitized_buf + 127], 0
    lea     rdi, [sanitized_buf]
    call    sanitize_input
    lea     rdi, [rsp]
    mov     rsi, 256
    lea     rdx, [str_root_chpasswd]
    lea     rcx, [sanitized_buf]
    xor     eax, eax
    call    snprintf
    lea     rdi, [rsp]
    call    system
.create_done:
    add     rsp, 312
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================
; install_busybox(char* placeholder) -> int
; ============================================================
global install_busybox
install_busybox:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_mnt_sbin]
    mov     esi, 0o755
    call    mkdir
    lea     rdi, [str_busybox_install]
    call    system
    pop     rbp
    ret

; ============================================================
; propriertary_(char*) -> int
; ============================================================
global propriertary_
propiertary_:
    push    rbp
    mov     rbp, rsp
    push    rbx
    lea     rdi, [str_prop_lock]
    lea     rsi, [str_w_mode]
    call    fopen
    test    rax, rax
    jnz     .ok
    lea     rdi, [str_prop_fail]
    xor     eax, eax
    call    printf
    mov     eax, 1
    jmp     .done
.ok:
    mov     rdi, rax
    call    fclose
    xor     eax, eax
.done:
    pop     rbx
    pop     rbp
    ret

; ============================================================
; init_car(char*) -> int
; ============================================================
global init_car
init_car:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_car_init]
    call    system
    xor     eax, eax
    pop     rbp
    ret

; ============================================================
; main_header()
; ============================================================
global main_header
main_header:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp, 16
    lea     rdi, [str_step1]
    xor     eax, eax
    call    printf
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_main_hdr_red]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    mov     rdi, YELLOW
    call    set_text_color
    lea     rdi, [str_main_hdr_yel]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    lea     rdi, [str_welcome]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_issues_nodot]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_dot_nl]
    xor     eax, eax
    call    printf
    lea     rdi, [str_sel_mode]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_up_down]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_or_word]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_jk]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_to_move]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_enter_word2]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_to_select]
    xor     eax, eax
    call    printf
    call    save_cursor
    xor     r12d, r12d
    xor     r13d, r13d
    mov     r14d, 1
.menu_loop:
    call    restore_cursor
    call    clear_to_end
    xor     r13d, r13d
.draw_loop:
    cmp     r13d, 2
    jge     .draw_done
    cmp     r13d, r12d
    jne     .not_sel
    mov     rdi, GREEN
    call    set_text_color
    lea     rdi, [str_arrow_sel]
    xor     eax, eax
    call    printf
    mov     rdi, WHITE
    call    set_text_color
    cmp     r13d, 0
    jne     .opt1
    lea     rdi, [str_opt_guided]
    jmp     .print_opt
.opt1:
    lea     rdi, [str_opt_manual]
.print_opt:
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    jmp     .draw_next
.not_sel:
    lea     rdi, [str_four_spaces]
    xor     eax, eax
    call    printf
    cmp     r13d, 0
    jne     .not_sel_opt1
    lea     rdi, [str_opt_guided]
    jmp     .not_sel_print
.not_sel_opt1:
    lea     rdi, [str_opt_manual]
.not_sel_print:
    xor     eax, eax
    call    printf
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
.draw_next:
    inc     r13d
    jmp     .draw_loop
.draw_done:
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    call    read_key
    cmp     eax, KEY_ENTER
    je      .menu_done
    cmp     eax, KEY_UP
    je      .go_up
    cmp     eax, KEY_K
    je      .go_up
    cmp     eax, KEY_DOWN
    je      .go_down
    cmp     eax, KEY_J
    je      .go_down
    jmp     .menu_loop
.go_up:
    dec     r12d
    jl      .wrap_up
    jmp     .menu_loop
.wrap_up:
    mov     r12d, 1
    jmp     .menu_loop
.go_down:
    inc     r12d
    cmp     r12d, 2
    jl      .menu_loop
    xor     r12d, r12d
    jmp     .menu_loop
.menu_done:
    cmp     r12d, 1
    jne     .exit_main_hdr
    call    clear
    sub     rsp, 16
    lea     rax, [str_sh_arg]
    mov     [rsp], rax
    mov     qword [rsp+8], 0
    lea     rdi, [str_sh_path]
    mov     rsi, rsp
    call    execv
    lea     rdi, [str_execv_err]
    call    perror
    mov     rdi, 1
    call    exit
.exit_main_hdr:
    add     rsp, 16
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

section .data
str_execv_err   db "execv", 0
section .text

; ============================================================
; localization_header() -> char*
; ============================================================
global localization_header
localization_header:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    lea     rdi, [str_step2]
    xor     eax, eax
    call    printf
    mov     rdi, YELLOW
    call    set_text_color
    lea     rdi, [str_loc_hdr]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [str_loc_note]
    xor     eax, eax
    call    printf
    call    separator
    mov     rdi, 100
    call    malloc
    mov     rbx, rax
    lea     rdi, [str_kb_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jnz     .strip
    mov     rdi, rbx
    lea     rsi, [str_us_default]
    call    strcpy
    jmp     .done
.strip:
    mov     rdi, rbx
    lea     rsi, [sep_newline]
    call    strcspn
    mov     byte [rbx + rax], 0
.done:
    mov     rax, rbx
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; language() -> char*
; ============================================================
global language
language:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    lea     rdi, [str_lang_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, 100
    call    malloc
    mov     rbx, rax
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jnz     .done
    lea     rdi, [str_lang_err]
    call    perror
.done:
    mov     rax, rbx
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

section .data
str_lang_err    db "Could not read input", 0
section .text

; ============================================================
; timezone() -> char*
; ============================================================
global timezone
timezone:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    lea     rdi, [str_tz_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, 100
    call    malloc
    mov     rbx, rax
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jnz     .done
    lea     rdi, [str_lang_err]
    call    perror
.done:
    mov     rax, rbx
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; disk_header() -> char*
; ============================================================
global disk_header
disk_header:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp, 536
    lea     rdi, [rsp]
    mov     rsi, 64
    call    list_devices
    mov     r12d, eax
    test    r12d, r12d
    jz      .ret_null
    xor     r13d, r13d
    xor     r14, r14
    xor     r15d, r15d
.size_loop:
    cmp     r15d, r12d
    jge     .size_done
    mov     rdi, [rsp + r15*8]
    mov     esi, '/'
    call    strrchr
    test    rax, rax
    jz      .size_next
    inc     rax
    mov     rbx, rax
    lea     rdi, [sysblock_path_buf]
    mov     rsi, 256
    lea     rdx, [str_sysblock_fmt]
    mov     rcx, rbx
    xor     eax, eax
    call    snprintf
    lea     rdi, [sysblock_path_buf]
    lea     rsi, [str_r_mode]
    call    fopen
    test    rax, rax
    jz      .size_next
    mov     rbx, rax
    lea     rdi, [size_str_buf]
    mov     rsi, 64
    mov     rdx, rbx
    call    fgets
    mov     rdi, rbx
    call    fclose
    lea     rdi, [size_str_buf]
    xor     esi, esi
    mov     edx, 10
    call    strtoll
    imul    rax, 512
    cmp     rax, r14
    jle     .size_next
    mov     r14, rax
    mov     r13d, r15d
.size_next:
    inc     r15d
    jmp     .size_loop
.size_done:
    mov     r15d, 1
.menu_loop2:
    test    r15d, r15d
    jz      .not_first2
    call    clear
    lea     rdi, [str_step3]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_disk_hdr]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [str_disk_warning]
    xor     eax, eax
    call    printf
    lea     rdi, [str_nav_hint]
    xor     eax, eax
    call    printf
    call    separator
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    call    save_cursor
    xor     r15d, r15d
    jmp     .draw_drives
.not_first2:
    call    restore_cursor
    call    clear_to_end
.draw_drives:
    xor     ebx, ebx
.drive_draw_loop:
    cmp     ebx, r12d
    jge     .drive_draw_done
    cmp     ebx, r13d
    jne     .drive_not_sel
    mov     rdi, GREEN
    call    set_text_color
    lea     rdi, [str_arrow_sel]
    xor     eax, eax
    call    printf
    mov     rdi, WHITE
    call    set_text_color
    mov     rdi, [rsp + rbx*8]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    jmp     .drive_draw_next
.drive_not_sel:
    lea     rdi, [str_four_spaces]
    xor     eax, eax
    call    printf
    mov     rdi, [rsp + rbx*8]
    xor     eax, eax
    call    printf
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
.drive_draw_next:
    inc     ebx
    jmp     .drive_draw_loop
.drive_draw_done:
    call    separator
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    call    read_key
    cmp     eax, KEY_ENTER
    je      .disk_selected
    cmp     eax, KEY_UP
    je      .disk_up
    cmp     eax, KEY_K
    je      .disk_up
    cmp     eax, KEY_DOWN
    je      .disk_down
    cmp     eax, KEY_J
    je      .disk_down
    jmp     .menu_loop2
.disk_up:
    dec     r13d
    jge     .menu_loop2
    mov     r13d, r12d
    dec     r13d
    jmp     .menu_loop2
.disk_down:
    inc     r13d
    cmp     r13d, r12d
    jl      .menu_loop2
    xor     r13d, r13d
    jmp     .menu_loop2
.disk_selected:
    mov     rdi, [rsp + r13*8]
    call    strdup
    mov     r15, rax
    xor     ebx, ebx
.free_loop:
    cmp     ebx, r12d
    jge     .free_done
    mov     rdi, [rsp + rbx*8]
    call    free
    inc     ebx
    jmp     .free_loop
.free_done:
    mov     rax, r15
    jmp     .done
.ret_null:
    xor     eax, eax
.done:
    add     rsp, 536
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

section .data
str_nav_hint    db "Use \x1b[94mUP/DOWN\x1b[0m or \x1b[94mj/k\x1b[0m to move, \x1b[94mENTER\x1b[0m to select.", 0Ah, 0Ah, 0
section .text

; ============================================================
; user_creation() -> char*
; ============================================================
global user_creation
user_creation:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rdi, 100
    call    malloc
    mov     rbx, rax
    lea     rdi, [str_step4]
    xor     eax, eax
    call    printf
    mov     rdi, YELLOW
    call    set_text_color
    lea     rdi, [str_user_hdr]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [str_user_note]
    xor     eax, eax
    call    printf
    call    separator
    lea     rdi, [str_username_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    mov     rax, rbx
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; user_password() -> char*
; ============================================================
global user_password
user_password:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rdi, 100
    call    malloc
    test    rax, rax
    jnz     .ok_alloc
    lea     rdi, [str_malloc_err]
    call    perror
    mov     rdi, 1
    call    exit
.ok_alloc:
    mov     rbx, rax
    lea     rdi, [str_userpass_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    call    disable_echo
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jnz     .got_pass
    lea     rdi, [str_fgets_err]
    call    perror
    call    enable_echo
    mov     rdi, rbx
    call    free
    xor     eax, eax
    jmp     .done
.got_pass:
    call    enable_echo
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    mov     rax, rbx
.done:
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

section .data
str_malloc_err  db "malloc", 0
str_fgets_err   db "fgets", 0
section .text

; ============================================================
; root_password() -> char*
; ============================================================
global root_password
root_password:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rdi, 100
    call    malloc
    test    rax, rax
    jnz     .ok_alloc
    lea     rdi, [str_malloc_err]
    call    perror
    mov     rdi, 1
    call    exit
.ok_alloc:
    mov     rbx, rax
    lea     rdi, [str_rootpass_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    call    disable_echo
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jnz     .got_pass
    lea     rdi, [str_fgets_err]
    call    perror
    call    enable_echo
    mov     rdi, rbx
    call    free
    xor     eax, eax
    jmp     .done
.got_pass:
    call    enable_echo
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    mov     rax, rbx
.done:
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; hostname() -> char*
; ============================================================
global hostname
hostname:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 8
    mov     rdi, 100
    call    malloc
    mov     rbx, rax
    lea     rdi, [str_hostname_prompt]
    xor     eax, eax
    call    printf
    mov     rdi, rbx
    mov     rsi, 100
    mov     rdx, [stdin]
    call    fgets
    mov     rax, rbx
    add     rsp, 8
    pop     rbx
    pop     rbp
    ret

; ============================================================
; proprietary_enable() -> int
; ============================================================
global proprietary_enable
proprietary_enable:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16
    lea     rdi, [str_prop_prompt]
    xor     eax, eax
    call    printf
    lea     rdi, [rsp]
    mov     rsi, 4
    mov     rdx, [stdin]
    call    fgets
    movzx   eax, byte [rsp]
    cmp     al, 'y'
    je      .yes
    cmp     al, 'Y'
    je      .yes
    mov     eax, 1
    jmp     .done
.yes:
    xor     eax, eax
.done:
    add     rsp, 16
    pop     rbp
    ret

; ============================================================
; installing_header()
; ============================================================
global installing_header
installing_header:
    push    rbp
    mov     rbp, rsp
    lea     rdi, [str_step5]
    xor     eax, eax
    call    printf
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_inst_hdr]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    pop     rbp
    ret

; ============================================================
; installed_header()
; ============================================================
global installed_header
installed_header:
    push    rbp
    mov     rbp, rsp
    call    clear
    lea     rdi, [str_step6]
    xor     eax, eax
    call    printf
    mov     rdi, GREEN
    call    set_text_color
    lea     rdi, [str_insted_hdr]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

; ============================================================
; install_failed()
; ============================================================
global install_failed
install_failed:
    push    rbp
    mov     rbp, rsp
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_failed_hdr]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    pop     rbp
    ret

; ============================================================
; shutdown_computer()
; ============================================================
global shutdown_computer
shutdown_computer:
    push    rbp
    mov     rbp, rsp
    call    sync
    mov     rdi, RB_AUTOBOOT
    call    reboot
    pop     rbp
    ret

; ============================================================
; error()
; ============================================================
global error
error:
    push    rbp
    mov     rbp, rsp
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_install_fail_msg]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_report_err]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_issues_url]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    call    enter_continue
    call    shutdown_computer
    pop     rbp
    ret

; ============================================================
; run_installation_step(int(*op)(char*), char* arg, const char* name, int destructive) -> int
; ============================================================
global run_installation_step
run_installation_step:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp, 16
    mov     rbx, rdi
    mov     r12, rsi
    mov     r13, rdx
    mov     r14d, ecx
    test    r14d, r14d
    jnz     .red_color
    mov     rdi, GREEN
    jmp     .color_set
.red_color:
    mov     rdi, RED
.color_set:
    call    set_text_color
    lea     rdi, [str_star]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_bold_fmt]
    mov     rsi, r13
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    mov     rdi, r12
    call    rbx
    test    eax, eax
    jz      .ok
    call    install_failed
    call    error
    mov     eax, -1
    jmp     .done
.ok:
    lea     rdi, [sep_newline]
    mov     rsi, [stdout]
    call    fputs
    xor     eax, eax
.done:
    add     rsp, 16
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ============================================================
; main()
; ============================================================
global main
main:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp, 72
    lea     rdi, [str_running_checks]
    xor     eax, eax
    call    printf
    call    list_dev
    call    clear
    call    main_header
    call    clear
    call    localization_header
    call    language
    call    timezone
    call    enter_continue
    call    clear
    call    disk_header
    mov     [rsp+48], rax
    test    rax, rax
    jnz     .have_drive
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_no_drive]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    enter_continue
    xor     eax, eax
    jmp     .main_ret
.have_drive:
    call    clear
    call    user_creation
    mov     [rsp+16], rax
    call    user_password
    mov     [rsp+24], rax
    test    rax, rax
    jz      .skip_upw_check
    movzx   ecx, byte [rax]
    cmp     cl, 10
    je      .warn_upw
    cmp     cl, 0
    jne     .skip_upw_check
.warn_upw:
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_remember_pass]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
.skip_upw_check:
    call    root_password
    mov     [rsp+32], rax
    test    rax, rax
    jz      .skip_rpw_check
    movzx   ecx, byte [rax]
    cmp     cl, 10
    je      .warn_rpw
    cmp     cl, 0
    jne     .skip_rpw_check
.warn_rpw:
    mov     rdi, RED
    call    set_text_color
    lea     rdi, [str_remember_pass]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
.skip_rpw_check:
    call    hostname
    mov     [rsp+40], rax
    call    proprietary_enable
    mov     [rsp+56], rax
    call    enter_continue
    call    clear
    call    installing_header
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    call    separator
    lea     rdi, [str_installing_to]
    mov     rsi, [rsp+48]
    xor     eax, eax
    call    printf
    lea     rdi, [rsp]
    mov     rsi, 4
    mov     rdx, [stdin]
    call    fgets
    movzx   eax, byte [rsp]
    cmp     al, 'y'
    je      .do_install
    cmp     al, 10
    je      .do_install
    jmp     .no_install
.do_install:
    call    clear
    mov     dword [rsp+64], 1
    call    disable_echo
    lea     rdi, [wipe_drive]
    mov     rsi, [rsp+48]
    lea     rdx, [str_erase_drive]
    mov     ecx, 1
    call    run_installation_step
    test    eax, eax
    jge     .step_makefs
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_makefs:
    lea     rdi, [makefs]
    mov     rsi, [rsp+48]
    lea     rdx, [str_make_fs]
    mov     ecx, 1
    call    run_installation_step
    test    eax, eax
    jge     .step_copy
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_copy:
    lea     rdi, [copy_root]
    mov     rsi, [rsp+48]
    lea     rdx, [str_copy_root_s]
    mov     ecx, 1
    call    run_installation_step
    test    eax, eax
    jge     .step_users
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_users:
    mov     rdi, GREEN
    call    set_text_color
    lea     rdi, [str_star]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [str_setup_users]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    mov     rdi, [rsp+16]
    mov     rsi, [rsp+24]
    mov     rdx, [rsp+32]
    call    create_users
    test    eax, eax
    jz      .users_ok
    call    install_failed
    call    error
    mov     eax, -1
    jmp     .main_ret
.users_ok:
    lea     rdi, [sep_newline]
    mov     rsi, [stdout]
    call    fputs
.step_grub:
    lea     rdi, [install_grub]
    mov     rsi, [rsp+48]
    lea     rdx, [str_inst_grub]
    mov     ecx, 1
    call    run_installation_step
    test    eax, eax
    jge     .step_patch
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_patch:
    lea     rdi, [patch]
    mov     rsi, [rsp+48]
    lea     rdx, [str_patches_s]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .step_prop_check
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_prop_check:
    cmp     dword [rsp+56], 0
    jne     .skip_prop
    lea     rdi, [propriertary_]
    lea     rsi, [str_empty]
    lea     rdx, [str_prop_s]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .skip_prop
    mov     dword [rsp+64], 0
    jmp     .cleanup
.skip_prop:
    lea     rdi, [localhost]
    mov     rsi, [rsp+40]
    lea     rdx, [str_hostname_s]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .step_car
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_car:
    lea     rdi, [init_car]
    lea     rsi, [str_empty]
    lea     rdx, [str_init_car_s]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .step_bb
    mov     dword [rsp+64], 0
    jmp     .cleanup
.step_bb:
    lea     rdi, [install_busybox]
    lea     rsi, [str_empty]
    lea     rdx, [str_inst_bb]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .cleanup
    mov     dword [rsp+64], 0
.cleanup:
    call    enable_echo
    cmp     dword [rsp+64], 0
    je      .main_ret_zero
    lea     rdi, [chroot_]
    lea     rsi, [str_empty]
    lea     rdx, [str_choose_opt]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .step_umount
    xor     eax, eax
    jmp     .main_ret
.step_umount:
    call    disable_echo
    lea     rdi, [umount_detach]
    lea     rsi, [str_mnt]
    lea     rdx, [str_unmount_s]
    mov     ecx, 0
    call    run_installation_step
    test    eax, eax
    jge     .cleanup2
    mov     dword [rsp+64], 0
.cleanup2:
    call    enable_echo
    cmp     dword [rsp+64], 0
    je      .main_ret_zero
    call    installed_header
    lea     rdi, [str_thank_you]
    xor     eax, eax
    call    printf
    lea     rdi, [str_report_bugs]
    xor     eax, eax
    call    printf
    mov     rdi, BLUE
    call    set_text_color
    lea     rdi, [str_issues_url2]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    mov     rdi, YELLOW
    call    set_text_color
    lea     rdi, [str_vm_warning]
    xor     eax, eax
    call    printf
    mov     rdi, RESET
    call    set_text_color
    call    separator
    lea     rdi, [sep_newline]
    xor     eax, eax
    call    printf
    call    enter_continue
    call    shutdown_computer
    xor     eax, eax
    jmp     .main_ret
.no_install:
    lea     rdi, [str_restart_q]
    xor     eax, eax
    call    printf
    lea     rdi, [rsp+8]
    mov     rsi, 8
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jz      .main_ret_zero
    movzx   eax, byte [rsp+8]
    cmp     al, 'n'
    je      .ask_reboot
    cmp     al, 'N'
    je      .ask_reboot
    call    clear
    lea     rdi, [str_install_bin]
    lea     rsi, [str_install_arg]
    xor     edx, edx
    xor     eax, eax
    call    execl
    jmp     .main_ret_zero
.ask_reboot:
    lea     rdi, [str_reboot_q]
    xor     eax, eax
    call    printf
    lea     rdi, [rsp+8]
    mov     rsi, 8
    mov     rdx, [stdin]
    call    fgets
    test    rax, rax
    jz      .main_ret_zero
    movzx   eax, byte [rsp+8]
    cmp     al, 's'
    je      .shutdown_now
    cmp     al, 'S'
    je      .shutdown_now
    lea     rdi, [str_reboot_msg]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    mov     rdi, 5
    call    sleep
    mov     rdi, RB_AUTOBOOT
    call    reboot
    jmp     .main_ret_zero
.shutdown_now:
    lea     rdi, [str_shutdown_msg]
    xor     eax, eax
    call    printf
    mov     rdi, [stdout]
    call    fflush
    mov     rdi, 5
    call    sleep
    mov     rdi, RB_POWER_OFF
    call    reboot
.main_ret_zero:
    xor     eax, eax
.main_ret:
    add     rsp, 72
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    pop     rbp
    ret
