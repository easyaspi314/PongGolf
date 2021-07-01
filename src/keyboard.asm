	[bits 16]
        extern input_buffer
        global handle_int09
        ; To have a proper experience, we need to have direct access to the keyboard.
        ; Playing Pong with standard key repeat suuuuuucks
handle_int09:
        ; Disable interrupts
	cli
        ; Save registers and flags
        pusha
        mov     dl, 1
	; Read keycode
	in	al, 0x60
        ; If the highest bit is set, then it is released. Otherwise it is pressed.
        aam     0x80
        sub     dl, ah
        ; Zero extend AL (since we know the sign bit is clear)
        cbw
	; Save to the buffer
        xchg    ax, bx
        mov     [cs:input_buffer + bx], dl
        ; Claim that it was consumed
        in      al, 0x61
        or      al, 0x80
        out     0x61, al
        xor     al, 0x80
        out     0x61, al
        ; Mark that we're done with the interrupt
        mov     al, 0x20
        out     0x20, al
        ; Restore registers
        popa
	; Enable interrupts
	sti
	; Return
	iret

        ; stdcall
        ; SP + 2: int09 segment
        ; SP + 4: int09 offset
        ; SP + 6: int1C segment
        ; SP + 8: int1C offset
        ; SP + 12: refresh rate
set_interrupts_and_timer:
        pop     si
        mov     di, ds
        pop     ds
        pop     dx
        mov     ax, 0x2509
        int     0x21
        pop     ds
        pop     dx
        mov     al, 0x1C
        int     0x21
        mov     al, TIMER_CONTROL_WORD
        out     TIMER_CONTROL, al
        pop     ax
        out     TIMER_COUNTER_0, al
        mov     al, ah
        out     TIMER_COUNTER_0, al
        mov     ds, di
        ; return
        jmp     si