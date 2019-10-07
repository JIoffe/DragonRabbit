*-----------------------------------------------------------
* CPU VECTORS
* These give the runtime some hints and must be first (address 0)
*-----------------------------------------------------------
	dc.l	$FFFFFE00		; Stack pointer
	dc.l	Main			; Code start
	dc.l	HandleException	; Bus error
	dc.l	HandleException	; Address error
	dc.l	HandleException	; Illegal instruction
	dc.l	HandleException	; Divistion by zero
	dc.l	HandleException	; CHK exception
	dc.l	HandleException	; TRAPV exception
	dc.l	HandleException	; Privilege violation
	dc.l	HandleException	; TRACE exeption
	dc.l	NotHandled	    ; Line 1010 emulator
	dc.l	NotHandled	    ; Line 1111 emulator
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Spurious exception
	dc.l	NotHandled	    ; Interrupt request level 1 (lowest priority)
	dc.l	NotHandled	    ; Interrupt request level 2 (external interrupt)
	dc.l	NotHandled	    ; Interrupt request level 3
	dc.l	HBlank			; Interrupt request level 4 (VDP interrupt/HBlank)
	dc.l	NotHandled	    ; Interrupt request level 5
	dc.l	VBlank			; Interrupt request level 6 (VDP interrupt/VBlank)
	dc.l	NotHandled	    ; Interrupt request level 7 (highest priority)
	dc.l	NotHandled	    ; TRAP #00 exception
	dc.l	NotHandled	    ; TRAP #01 exception
	dc.l	NotHandled	    ; TRAP #02 exception
	dc.l	NotHandled	    ; TRAP #03 exception
	dc.l	NotHandled	    ; TRAP #04 exception
	dc.l	NotHandled	    ; TRAP #05 exception
	dc.l	NotHandled	    ; TRAP #06 exception
	dc.l	NotHandled	    ; TRAP #07 exception
	dc.l	NotHandled	    ; TRAP #08 exception
	dc.l	NotHandled	    ; TRAP #09 exception
	dc.l	NotHandled	    ; TRAP #10 exception
	dc.l	NotHandled	    ; TRAP #11 exception
	dc.l	NotHandled	    ; TRAP #12 exception
	dc.l	NotHandled	    ; TRAP #13 exception
	dc.l	NotHandled	    ; TRAP #14 exception
	dc.l	NotHandled	    ; TRAP #15 exception
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
	dc.l	NotHandled	    ; Reserved
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
