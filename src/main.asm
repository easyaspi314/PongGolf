        [bits 16]
        [cpu 186]
        [org 0x100]
        extern handle_int09
        extern old_int09
        section .text
        global start
start:
        ; Zero out .bss.
        mov     cx, BSS_SIZE
        mov     di, BSS_START
        rep     stosb
        ; Switch DOS to 320x200, 256 color
        mov     al, 0x13
        int     0x10
        
        push    es
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
        pop     es
        ; Set up our own interrupts and timer.
%ifndef GOLF
        ; Sorry, I'm not playing Pong at 18.2 FPS.
        ; Set the timer to 30FPS.
        ; 60fps works too but DOSBox can't handle it without bumping the
        ; framerate.
        push    TIMER_30HZ
%endif
        push    game_update
        push    cs
        push    handle_int09
        push    cs
        call    set_interrupts_and_timer

.spin:
%ifndef GOLF
        hlt
%endif
        cmp     byte[exit_test], 0
        jz      .spin


        ; todo: exit
        global exit
exit:
        ; Restore the old interrupt handlers and timer
        mov     di, backup_interrupts
%ifndef GOLF
        ; max timer
        push    TIMER_DEFAULT
%endif
        push    word[di + 4]
        push    word[di + 6]
        push    word[di]
        push    word[di + 2]
        call    set_interrupts_and_timer
        ; since I am in a good mood, reset graphics mode
        mov     ax, 0x0003
        int     0x10
        ; Exit to DOS
        int     0x20
        ; UNREACHABLE
