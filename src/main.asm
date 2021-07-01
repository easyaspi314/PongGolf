        [bits 16]
        [cpu 386]
        [org 0x100]
        extern handle_int09
        extern old_int09
        section .text
        global start
start:
        ; Zero out .bss
        mov     cx, BSS_SIZE
        mov     di, BSS_START
        rep     stosb

        ; Switch DOS to 320x200, 256 color
        mov     al, 0x13
        int     0x10
        ; TODO: shrink
        ; Save interrupt 09 and 1c
        mov     ax, 0x3509
        int     0x21
        mov     [di], bx
        mov     [di+2], es
        mov     al, 0x1c
        int     0x21
        mov     [di+4], bx
        mov     [di+6], es
        ; Set up our own interrupts and timer
        ; Sorry, I'm not playing Pong at 18.2 FPS.
        ; Set the timer to 60FPS.
        push    TIMER_60HZ
        push    game_update
        push    cs
        push    handle_int09
        push    cs
        call    set_interrupts_and_timer

        ; Spin forever: our interrupts handle the rest.
.spin:
        ; hlt ;; wait for interrupt
        jmp     .spin


        ; todo: exit
        global exit
exit:
        ; Restore the old interrupt handlers and timer
        mov     di, backup_interrupts
        ; max timer
        push    TIMER_DEFAULT
        push    dword[di]
        push    dword[di+4]
        call    set_interrupts_and_timer
        ; since I am in a good mood, reset graphics mode
        mov     ax, 0x0002
        int     0x10
        ; Exit to DOS
        mov     ah, 0x4C
        int     0x21
        ; UNREACHABLE
