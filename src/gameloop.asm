        global game_update
        ;;
        ;; This is our game loop.
        ;;
        ;; It is called every 30th of a second by int 0x1C.
        ;;
game_update:
        ; Disable interrupts
        cli
        ; Save all registers
        pusha   
        ;;
        ;; Read input buffer
        ;;

        ; Load our input buffer into SI
        mov     si, input_buffer
        xor     ax, ax
        cwd
        cmp     byte[si + KEY_ESC], dl
        jz      .not_exit
.exit:
        inc     byte[exit_test]
       ; sti
       ; iret
.not_exit:
        ; Load Player 1's position
        mov     al, [si + (player1_pos - input_buffer)]

        ; Q: move P1 paddle up
        cmp     byte[si + KEY_Q], dl
        jz     .not_p1_up
.p1_up:
        call    move_paddle_up
.not_p1_up:
        ; A: move P1 paddle down
        cmp     byte[si + KEY_A], dl
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
        cmp     byte[si + KEY_P], dl
        jz      .not_p2_up
.p2_up:
        call    move_paddle_up
.not_p2_up:
        ; L: move P2 paddle down
        cmp     byte[si + KEY_L], dl
        jz      .not_p2_down
.p2_down:
        call    move_paddle_down
.not_p2_down:
        ; Save Player 2's position
        mov     [si + (player2_pos - input_buffer)], al
        ; Push for later
        push    ax
        ;;
        ;; Clear screen
        ;;
%ifdef DOUBLE_BUFFER
        mov     cx, 64000/2
        mov     di, double_buffer
        xor     ax, ax
        rep     stosw
%endif
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
        cwd
        pop     di
        call    draw_rect
%ifdef DOUBLE_BUFFER
        mov     si, double_buffer
        push    es
        push    0xA000
        pop     es
        mov     cx, SCREEN_ROWS * SCREEN_COLS / 2
        xor     di, di
        rep     movsw
        pop     es
        mov     ax, si
%endif
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