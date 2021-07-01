        global game_update
        ;;
        ;; This is our game loop.
        ;;
        ;; It is called every ~18.5ms by int 0x1C.
        ;;
game_update:
        ; Disable interrupts
        cli
        ; Save all registers
        pusha
%ifndef NO_DEFLICKER
        ; DOSBox hack: We need to VSync to avoid flickering. Unfortunately, this
        ; doesn't work with VirtualBox, it simply flips the bit each time.
        ;
        ; This is left out in the golfed code, as it wastes 13 bytes, but
        ; it is enabled by default for normal builds.
        ; Wait for vsync
        mov     dx, 0x3DA
.spin1:
        in      al, dx
        test    al, 0x8
        jnz     .spin1
.spin2:
        in      al, dx
        test    al, 0x8
        jz      .spin2
%endif
        ; Find our home segment. Since we are using a flat .com file,
        ; our code segment is the same as the data segment.
        push    ds
        push    cs
        pop     ds

        ;;
        ;; Read input buffer
        ;;

        ; Load our input buffer into SI
        mov     si, input_buffer
        ; Load Player 1's position
        xor     ax, ax
        mov     al, [si + (player1_pos - input_buffer)]

        ; Q: move P1 paddle up
        cmp     byte[si + KEY_Q], 0
        jz     .not_p1_up
.p1_up:
        call    move_paddle_up
.not_p1_up:
        ; A: move P1 paddle down
        cmp     byte[si + KEY_A], 0
        jz      .not_p1_down
.p1_down:
        call    move_paddle_down
.not_p1_down:
        ; Save Player 1's position
        mov     [si + (player1_pos - input_buffer)], al
        ; Push for later
        push    ax
        ; Load Player 2's position
        mov     al, [si + (player2_pos - input_buffer)]
        ; P: move P2 paddle up
        cmp     byte[si + KEY_P], 0
        jz      .not_p2_up
.p2_up:
        call    move_paddle_up
.not_p2_up:
        ; L: move P2 paddle down
        cmp     byte[si + KEY_L], 0
        jz      .not_p2_down
.p2_down:
        call    move_paddle_down
.not_p2_down:
        ; Save Player 2's position
        mov     [si + (player2_pos - input_buffer)], al
        ; Push for later
        push    ax
        ;;
        ;; Clear paddles
        ;; TODO: fix flicker on DOSBox
        ;;
        
        ; ax = dx = di = 0
        xor     di, di
        mul     di
        mov     cx, PADDLE_WIDTH
        mov     bx, 200

        call    draw_rect
        mov     dx, P2_PADDLE_X
        call    draw_rect

        ;;
        ;; Draw the new paddles
        ;;
        mov     al, COLOR_WHITE
        mov     bl, PADDLE_HEIGHT
        pop     di
        call    draw_rect

        ; dx = 0 (P1_PADDLE_X)
        cdq
        pop     di
        call    draw_rect
        ; Restore data segment
        pop     ds
        ; Restore registers
        popa
        ; Enable interrupts
        sti
        ; Return from interrupt
        iret
        
        ; Moves the paddle up.
        ; IN: ax
        ; OUT: al
move_paddle_up:
        sub     al, PADDLE_SPEED
        jnc     .dont_correct
.correct:
        xor     ax, ax
.dont_correct:
        ret

        ; Moves the paddle down.
        ; IN: al
        ; OUT: al
move_paddle_down:
        add     al, PADDLE_SPEED
        cmp     al, SCREEN_ROWS - PADDLE_HEIGHT
        jna     .dont_correct
.correct:
        mov     al, SCREEN_ROWS - PADDLE_HEIGHT
.dont_correct:
        ret