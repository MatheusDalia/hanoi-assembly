;; dupla: pedro balbino e matheus dalia (phsb e mdaa)

section .data
    input_msg db "Digite o numero de discos (1-9): "
    input_msg_len equ $ - input_msg

    intro_msg db "Algoritmo da Torre de Hanoi com "
    intro_msg_len equ $ - intro_msg

    disk_count db "0 discos", 10
    disk_count_len equ $ - disk_count

    move_msg db "Mova disco "
    move_msg_disk db "0"
    move_msg_part2 db " da Torre "
    move_msg_origin db "A"
    move_msg_part3 db " para a Torre "
    move_msg_destination db "C", 10   
    move_msg_total_len equ $ - move_msg

    done_msg db "Concluido!", 10
    done_msg_len equ $ - done_msg

section .bss
    num_buffer resb 2       ; Buffer to store input number

section .text
    global _start

_start:
    ; Output the input prompt message
    mov eax, 4                          
    mov ebx, 1                          
    lea ecx, [input_msg]                
    mov edx, input_msg_len              
    int 0x80                            

    ; Read the user input
    mov eax, 3                          ; Sys_read
    mov ebx, 0                          ; STDIN
    lea ecx, [num_buffer]               ; Address of input buffer
    mov edx, 2                          ; Number of bytes to read (include newline)
    int 0x80                            

    ; Convert ASCII input to integer
    movzx eax, byte [num_buffer]        ; Load the first byte into eax
    sub eax, '0'                        ; Convert from ASCII to integer
    mov [num_buffer], eax               ; Store integer in buffer

    ; Output the introductory message with the number of disks
    mov eax, 4                          
    mov ebx, 1                          
    lea ecx, [intro_msg]                
    mov edx, intro_msg_len              
    int 0x80                            

    mov al, byte [num_buffer]           ; Load the number of disks (already an int)
    add al, '0'                         ; Convert back to ASCII for display
    mov [disk_count], al                ; Store in display message

    ; Output the disk count message
    mov eax, 4                          
    mov ebx, 1                          
    lea ecx, [disk_count]                
    mov edx, disk_count_len              
    int 0x80                            

    ; Setup parameters for the Towers of Hanoi function
    mov eax, [num_buffer]               ; Load number of disks
    push eax                            ; Number of disks (n)
    push dword 1                        ; Source peg identifier (Torre A)
    push dword 3                        ; Destination peg identifier (Torre C)
    push dword 2                        ; Auxiliary peg identifier (Torre B)
    call hanoi
    add esp, 16                         ; Clean up the stack after the function call

    ; Output the completion message
    mov eax, 4                          
    mov ebx, 1                          
    lea ecx, [done_msg]                 
    mov edx, done_msg_len               
    int 0x80                            

    ; Exit the program
    mov eax, 1                          
    xor ebx, ebx                        
    int 0x80                            

; Function: hanoi
; Moves n disks from source peg to destination peg using auxiliary peg
hanoi:
    push ebp
    mov ebp, esp

    ; Load parameter n (number of disks)
    mov eax, [ebp + 8]
    cmp eax, 1
    je .move_single_disk           ; If n == 1, move single disk

    ; Process: Move n-1 disks from source to auxiliary peg
    dec eax
    push eax                       ; n-1
    push dword [ebp + 12]          ; source
    push dword [ebp + 20]          ; auxiliary
    push dword [ebp + 16]          ; destination
    call hanoi
    add esp, 16                    

    ; Process: Move nth disk from source to destination
    mov eax, [ebp + 8]             
    push eax                       ; disk number
    push dword [ebp + 12]          ; source
    push dword [ebp + 16]          ; destination
    call print_move
    add esp, 12                    

    ; Process: Move n-1 disks from auxiliary to destination peg
    mov eax, [ebp + 8]             
    dec eax
    push eax                       ; n-1
    push dword [ebp + 20]          ; auxiliary (source)
    push dword [ebp + 16]          ; destination
    push dword [ebp + 12]          ; source (auxiliary)
    call hanoi
    add esp, 16                    

    jmp .end

.move_single_disk:
    ; Move a single disk directly from source to destination
    push dword [ebp + 8]
    push dword [ebp + 12]
    push dword [ebp + 16]
    call print_move
    add esp, 12

.end:
    leave
    ret

; Function: print_move
; Prints the move of a disk from source peg to destination peg
print_move:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]               ; Disk number
    add al, '0'                      ; Convert number to ASCII
    mov [move_msg_disk], al         

    mov eax, [ebp + 12]              ; Source peg
    add al, 'A'-1
    mov [move_msg_origin], al       

    mov eax, [ebp + 16]              ; Destination peg
    add al, 'A'-1
    mov [move_msg_destination], al  

    ; Output move message
    mov eax, 4                      
    mov ebx, 1                      
    lea ecx, [move_msg]             
    mov edx, move_msg_total_len     
    int 0x80                        

    leave
    ret
