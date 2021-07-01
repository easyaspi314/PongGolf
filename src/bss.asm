        section .bss
        global BSS_START
BSS_START:
        ; bool input_buffer[128]
        global input_buffer
input_buffer:
        resb    128

       ; section .bss
        global player1_pos
player1_pos:
        resb    2
        global player2_pos
player2_pos:
        resb    2
        global ball_x
ball_x:
        resb    1
        global ball_y
ball_y:
        resb    1
        global ball_direction
ball_direction:
        resb    1
        global ball_speed
ball_speed:
        resb    1
        global exit_test
exit_test:
        resb    1

BSS_SIZE: equ   $ - BSS_START

        ; These don't need to be zeroed.
        global backup_interrupts
backup_interrupts:
old_int09:
        resb    4
old_int1C:
        resb    4
