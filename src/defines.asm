; Screen dimensions
SCREEN_COLS: equ 320
SCREEN_ROWS: equ 200
; Timer
; http://gamedev.net/forums/topic/17816-speeding-up-the-timer-in-dos/
TIMER_60HZ: equ 0x4DAE
TIMER_DEFAULT: equ 0xFFFF
TIMER_CONTROL: equ 0x43
TIMER_COUNTER_0: equ 0x40
TIMER_CONTROL_WORD: equ 0x3C

; BIOS scan codes
KEY_Q: equ 0x10
KEY_A: equ 0x1E
KEY_P: equ 0x19
KEY_L: equ 0x26

PADDLE_WIDTH: equ 8
PADDLE_HEIGHT: equ 50
PADDLE_SPEED: equ 4
P1_PADDLE_X: equ 0
P2_PADDLE_X: equ SCREEN_COLS - PADDLE_WIDTH
BALL_WIDTH: equ 4
COLOR_BLACK: equ 0
COLOR_WHITE: equ 15