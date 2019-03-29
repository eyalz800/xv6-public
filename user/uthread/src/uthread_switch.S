    .text

/* Switch from current_thread to next_thread. Make next_thread
 * the current_thread, and set next_thread to 0.
 * Use eax as a temporary register, which should be caller saved.
 */
    .intel_syntax noprefix
    .extern next_thread
    .extern current_thread
    .global thread_switch
thread_switch:
    // Push general purpose registers.
    pushad

    // Current thread pointer.
    mov eax, current_thread

    // Save current thread stack pointer.
    mov [eax], esp

    // Next thread pointer.
    mov eax, next_thread

    // Load next thread stack pointer.
    mov esp, [eax]

    // Set current thread pointer to next thread.
    mov current_thread, eax

    // Set next_thread to zero.
    mov dword ptr next_thread, 0

    // Load general purpose registers, and return.
    popad
    ret
