.686
.model flat
public _size_of_files
extern _FindNextFileW@8 : PROC
extern _FindFirstFileW@8 : PROC
.code
_size_of_files PROC
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi
 
	; Reserve space on the stack 
	sub esp, 596
	mov ebx, esp ; 596 B reserved for WIN32_FIND_DATA

	; Initialize FPU
	finit
	fldz ; load zero to perform first addition

	; Iterating through the files
	next_file:
	push ebx               ; spcae for WIN32_FIND_DATA FindFileData
	push dword ptr [ebp+8] ; int handle
	call _FindNextFileW@8
	cmp eax, 0 
	je no_next_file        ; escaping the loop when there is no next file
	bt dword ptr [ebx], 4
	jc  handle_folder

	handle_file:
		push dword ptr [ebx+28] ; nFileSizeHigh
		push dword ptr [ebx+32] ; nFileSizeLow
		fild qword ptr [esp]
		; Converting B to MB
		push dword ptr 1
		shl dword ptr [esp], 20 ; 2^20 B = 1 MB
		fild dword ptr [esp]
		add esp, 12
		fdivp                   
		faddp
	jmp next_file

	handle_folder:
		mov edi, ebx
		add edi, 44  ; cFileName address
		cmp [edi], word ptr "."
		jne regular_folder
		cmp [edi+2], word ptr "."
		je next_file ; if the folder name is ".." go to the next file
		regular_folder:

		mov edi, [ebp+12] ; pointer to wchar_t parent_path
		mov ax, 0		  ; end of string
		mov ecx, 512      ; we assume that the size of parent_path does not exceed 1024 B
		repne scasw
		neg ecx
		add ecx, 512      
		dec ecx           ; number of words to move

		; Reserve space on the stack 
		sub esp, 1024     ; beginning of reserved space preserved
		mov edi, esp      ; space for path
		mov esi, [ebp+12] ; pointer to wchar_t parent_path
		rep movsw
		mov [edi], word ptr "\"
		add edi, 2
		mov edx, edi      ; end of the rewrited path

		mov edi, ebx
		add edi, 44  ; cFileName address
		mov ax, 0	 ; end of string
		mov ecx, 260 ; cFileName[260]
		repne scasw
		neg ecx
		add ecx, 260 ; number of words to move
		dec ecx
		
		mov esi, ebx
		add esi, 44  ; cFileName address
		mov edi, edx ; end of the rewrited path
		rep movsw

		mov [edi], word ptr "\"
		mov [edi+2], word ptr "*"
		mov [edi+4], word ptr 0

		mov esi, esp
		push ebx     ; space for WIN32_FIND_DATA
		push esi     ; folder's path
		; We assume that FindFirstFile will always work properly
		call _FindFirstFileW@8 

		sub esp, 8
		fst qword ptr [esp]   ; sum of file sizes preserved
		mov [edi], word ptr 0 ; shorten the parent path
		push esi              ; pointer to parent_path
		push eax              ; handle from FindFirstFileW
		call _size_of_files	
		add esp, 8            ; cleaning stack from size_of_files arguments
		fld	qword ptr [esp]   ; sum of file sizes restored
		add esp, 8
		faddp
		add esp, 1024         ; free reserved space
	jmp next_file
	no_next_file:

	; Free space on the stack 
	add esp, 596

	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
_size_of_files ENDP 
END