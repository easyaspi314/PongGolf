        section .text

        ;;
        ;; Draws a rectangle on the screen.
        ;;
        ;; AL: color
        ;; CX: width
        ;; DX: x
        ;; BX: height
        ;; DI: y
        ;; Saves all registers
        ;;
        global draw_rect
draw_rect:
        ; Save registers
        pusha
        ; Multiply y by columns
        imul    di, SCREEN_COLS
        ; Add x to get the offset
        add     di, dx
%ifdef DOUBLE_BUFFER
        ; Add the offset to our double buffer
        add     di, double_buffer
%else
        ; Set ES to point to VRAM
        ; Save copy of ES
        push    es
        push    0xA000
        pop     es
%endif
.loop1:
        ; Save DI and CX by pusha again :P
        pusha
        ; Fill CX bytes with our color
        rep     stosb
        ; Restore DI and CX
        popa
        ; Go to next line
        add     di, SCREEN_COLS
        ; Loop height times
        dec     bx
        jnz     .loop1
        ; Restore registers like a good boy
%ifndef DOUBLE_BUFFER
        pop     es
%endif
        popa
        ; Return
        ret
