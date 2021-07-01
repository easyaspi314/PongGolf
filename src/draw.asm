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
        ; Save copy of ES
        push    es
        ; Set ES to point to VRAM
        push    0xA000
        pop     es
        ; Multiply y by columns
        imul    di, SCREEN_COLS
        ; Add x to get the offset
        add     di, dx
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
        pop     es
        popa
        ; Return
        ret
