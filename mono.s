	.file	"mono.c"
gcc2_compiled.:
___gnu_compiled_c:
.text
LC0:
	.ascii "ERROR: Somebody else has the video buffer.\12\0"
LC1:
	.ascii "VioGetPhysBuf failed returncode %d.\12\0"
	.align 2
.globl _main
_main:
	pushl %ebp
	movl %esp,%ebp
	subl $24,%esp

	movl $753664,-12(%ebp)
	movl $4000,-8(%ebp)
	pushl $0
	leal -18(%ebp),%eax
	pushl %eax
	pushl $0
	call _VioScrLock
	addl $12,%esp
	cmpw $0,-18(%ebp)
	je L14
	pushl $LC0
	call _printf
	addl $4,%esp
	pushl $0
	call _exit
	addl $4,%esp
	.align 2,0x90
L14:
	pushl $0
	leal -12(%ebp),%eax
	pushl %eax
	call _VioGetPhysBuf
	addl $8,%esp
	movl %eax,%eax
	movw %ax,-18(%ebp)
	cmpw $0,-18(%ebp)
	je L15
	movzwl -18(%ebp),%eax
	pushl %eax
	pushl $LC1
	call _printf
	addl $8,%esp
	pushl $0
	call _exit
	addl $4,%esp
	.align 2,0x90
L15:
	movzwl -4(%ebp),%eax
	movl %eax,%edx
	sall $16,%edx
	pushl %edx
	call _emx_16to32
	addl $4,%esp
	movl %eax,-16(%ebp)
	movl $0,-24(%ebp)
L16:
	cmpl $3999,-24(%ebp)
	jle L19
	jmp L17
	.align 2,0x90
L19:
	movl -16(%ebp),%eax
	movl -24(%ebp),%edx
	addl %edx,%eax
	movb $32,(%eax)
L18:
	addl $2,-24(%ebp)
	jmp L16
	.align 2,0x90
L17:
	pushl $0
	call _VioScrUnLock
	addl $4,%esp
L13:
	leave
	ret
	.align 2
.globl _VioScrLock
_VioScrLock:
	pushl %ebp
	movl %esp,%ebp
	subl $20,%esp
	movl 8(%ebp),%eax
	movl 16(%ebp),%edx
	movw %ax,-2(%ebp)
	movw %dx,-4(%ebp)
	leal -16(%ebp),%eax
	leal 12(%eax),%ecx
	movl %ecx,-20(%ebp)
	movl $8,-16(%ebp)
	addl $-2,-20(%ebp)
	movl -20(%ebp),%eax
	movw -2(%ebp),%dx
	movw %dx,(%eax)
	movl 12(%ebp),%eax
	pushl %eax
	call _emx_32to16
	addl $4,%esp
	movl %eax,%eax
	addl $-4,-20(%ebp)
	movl -20(%ebp),%edx
	movl %eax,(%edx)
	addl $-2,-20(%ebp)
	movl -20(%ebp),%eax
	movl -4(%ebp),%edx
	movw %dx,(%eax)
	pushl $_16_Vio16ScrLock
	leal -16(%ebp),%eax
	pushl %eax
	call _emx_thunk1
	addl $8,%esp
	movl %eax,%eax
	movzwl %ax,%edx
	movl %edx,%eax
	jmp L20
	.align 2,0x90
L20:
	leave
	ret
	.align 2
.globl _VioGetPhysBuf
_VioGetPhysBuf:
	pushl %ebp
	movl %esp,%ebp
	subl $20,%esp
	movl 12(%ebp),%eax
	movw %ax,-2(%ebp)
	leal -16(%ebp),%eax
	leal 10(%eax),%ecx
	movl %ecx,-20(%ebp)
	movl $6,-16(%ebp)
	movl 8(%ebp),%eax
	pushl %eax
	call _emx_32to16
	addl $4,%esp
	movl %eax,%eax
	addl $-4,-20(%ebp)
	movl -20(%ebp),%edx
	movl %eax,(%edx)
	addl $-2,-20(%ebp)
	movl -20(%ebp),%eax
	movw -2(%ebp),%dx
	movw %dx,(%eax)
	pushl $_16_Vio16GetPhysBuf
	leal -16(%ebp),%eax
	pushl %eax
	call _emx_thunk1
	addl $8,%esp
	movl %eax,%eax
	movzwl %ax,%edx
	movl %edx,%eax
	jmp L21
	.align 2,0x90
L21:
	leave
	ret
	.align 2
.globl _VioScrUnLock
_VioScrUnLock:
	pushl %ebp
	movl %esp,%ebp
	subl $16,%esp
	movl 8(%ebp),%eax
	movw %ax,-2(%ebp)
	leal -12(%ebp),%eax
	leal 6(%eax),%ecx
	movl %ecx,-16(%ebp)
	movl $2,-12(%ebp)
	addl $-2,-16(%ebp)
	movl -16(%ebp),%eax
	movw -2(%ebp),%dx
	movw %dx,(%eax)
	pushl $_16_Vio16ScrUnLock
	leal -12(%ebp),%eax
	pushl %eax
	call _emx_thunk1
	addl $8,%esp
	movl %eax,%eax
	movzwl %ax,%edx
	movl %edx,%eax
	jmp L22
	.align 2,0x90
L22:
	leave
	ret

.globl ___main
___main:
	leave
	ret