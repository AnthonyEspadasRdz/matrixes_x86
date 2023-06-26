; -- Mateia:                Estructura y programacion de computadoras
; -- Grupo:                 06
; -- Profesor:              Miguel Israel Barragán
; -- Semestre:              2023-1
; -- Desarrollado por:      Espadas Rodriguez Anthony Jonathan - 421033621
; -- Fecha de finalización: 11-Ene-2023

page 60,130
title Proyecto EyP

.286

; -- Macro que imprime en la pantalla
imprimirMensaje macro renglonM, columnaM, mensaje
    reposicionarCursor renglonM, columnaM
    mov ah, 09h; Imprimimos el texto
    mov dx, offset mensaje
    int 21h
endm

; -- Inserta la interrupcion de limpiado de pantalla
limpiarPantalla macro
    mov ah,0Fh
    int 10h
    mov ah,0
    int 10h
    mov ah,01h; Ocultando cursor
    mov cx,02607h
    int 10h
endm

; -- Cambia la posicion del cursor
reposicionarCursor macro renglon, columna
    mov ah, 02h; Reposicionamos el cursor
    mov dh, renglon; Renglón
    mov dl, columna; Columna
    mov bh, 00; Número de página
    int 10h; posiciona el cursor
endm

leerCadena macro renglonC, columnaC, cadenaC
    reposicionarCursor renglonC, columnaC
    ; Leemos la cadena desde teclado
    mov ah, 0Ah
    mov dx, offset cadenaC
    int 21h
endm

; -- Usa la interrupcion que lee por teclado
leerChar macro
    in al, 60h
endm

; -- Macro que valida si la tecla pulsada coincide con una opcion
teclaPulsada macro comparador, eti
    cmp al, comparador; Comparacion con la letra en scancode
    jnz eti; Se omite la asignacion si la seleccion no coincide
    mov sel, al; Colocamos la seleccion como la tecla
    limpiarEntrada
    limpiarPantalla
    eti:
endm

; -- Evita que el buffer del teclado almacene datos
limpiarEntrada macro
    mov al, 0
    out 60h, al; Quita los caracteres del puerto del teclado
    mov ah, 0Ch; Limpia el buffer del teclado
    mov al, 0
    int 21h
endm

; -- Macro que llama la funcion segun la tecla pulsada
ejecFun macro comparador2, eti2, funcion 
    mov al, comparador2; Verifiacamos si la seleccion coincide
    cmp al, sel; 
    jnz eti2; Omitimos de no ser el caso
    pusha; guardamos el estado de la maquina
    call funcion;
    popa; recuperamos el estado de la maquina
    eti2:
endm

; -- Macro que obtiene segmentos de la hora
obtenerTiempo macro registro, desplazamiento
    xor ax, ax
    mov al, registro
    mov bl, 10
    div bl; Separando dígitos
    add al, 30h; Obteniendo su ascii
    add ah, 30h;
    mov si, offset reloj
    mov [si+desplazamiento], al; Creando cadena de tiempo
    mov [si+desplazamiento+1], ah
endm

.model small
.stack 256

.data
reloj db 'HH:MM:SS:CS','$'
optA  db 'A) Suma de 2 matrices','$'
txtA1 db 'Seleccionaste la opcion A', '$'
;txtA2 db 'Introduce la segunda matriz:', '$'
optB  db 'B) Obtener transpuesta','$'
txtB  db 'Seleccionaste la opcion B', '$'
optC  db 'C) Multiplicar matrices','$'
txtC1 db 'Seleccionaste la opcion C', '$'
;txtC2 db 'Introduce la segunda matriz:', '$'
optD  db 'D) Diagonal principal y suma','$'
txtD  db 'Seleccionaste la opcion D', '$'
optE  db 'E) Suma de columnas de una matriz','$'
txtE  db 'Seleccionaste la opcion E', '$'
optF  db 'F) Suma de renglones de una matriz','$'
txtF  db 'Introduce la matriz:', '$'
txtR  db 'Resultado obtenido [i] Ver   [Esc] Salir', '$'
sel   db 08; Valor fuera del rango de seleccion

; -- Declaracion del espacio para las matrices
;cadena db 51,0,'                                                 ', '$' 
cadena1 db 11, 0, '         ','$'
cadena2 db 11, 0, '         ','$'
matriz1 db 16 dup(0) 
matriz2 db 16 dup(0)
matriz3 db 16 dup(0)
matriz4 db 4 dup(0)

.code
; -- Procedimiento que mantiene el control del loop
Principal proc far
    assume;
    mov ax,@data
    mov ds,ax
    limpiarPantalla

    ; -- Selector de opciones en la pantalla principal
    leer:
    leerChar; Lectura de selección en menu principal

    mov ah, 08;
    cmp ah, sel;
    jne seleccionado; Si ya hay una operacion seleccioanda, no lee otra  
    
    call validarTecla; modifica sel si la tecla pulsada es valida

    seleccionado:
    cmp al, 1; Comparamos que no haya sido scape
    jz validarEsc

    continuar:
    jmp menuPrin

    validarEsc:
    mov al, sel; 
    cmp al, 08; Verificamos si la seleccion ha sido cambiada
    jz exit
    limpiarEntrada; Evitamos que el scape se guarde en el registro
    mov sel, 08; Se corrige el valor de sel
    limpiarPantalla
    jmp continuar; se devuelve al menu

    menuPrin:
    call ejecSel; Se ejecuta la opcion seleccionada
    mov ah, 08
    cmp ah, sel
    jnz hora; Si sel presentó cambios, no imprime el menu

    call imprimirMenu; Si no hay seleccion se muestran las opciones
    jmp hora

    hora:
    call darHora
    jmp leer

    exit:
    limpiarEntrada
    limpiarPantalla
    mov ah,04ch
    mov al,05
    int 21h
Principal endp

; -- Procedimiento que ejecuta el reloj
darHora proc
    ; Obteniendo tiempo
    mov ah,02ch
    int 21h
    
    obtenerTiempo ch, 0; Horas
    obtenerTiempo cl, 3; Minutos
    obtenerTiempo dh, 6; Segundos
    obtenerTiempo dl, 9; Centésimas de segundo    
    imprimirMensaje 1, 35, si; imprimimos la hora
    
    ret
darHora endp

; -- Procedimiento que imprime las opciones de operacion
imprimirMenu proc
    
    imprimirMensaje 5, 20, optA;  Imprimir la opción A
    imprimirMensaje 7, 20, optB;  Imprimir la opción B
    imprimirMensaje 9, 20, optC;  Imprimir la opción C
    imprimirMensaje 11, 20, optD; Imprimir la opción D
    imprimirMensaje 13, 20, optE; Imprimir la opción E
    imprimirMensaje 15, 20, optF; Imprimir la opción F
    
    ret
imprimirMenu endp

; -- Determinanos si la tecla presionada tiene una acción
validarTecla proc 
    
    teclaPulsada 1Eh, notA; Verifica si se pulsó 'A'
    teclaPulsada 30h, notB; Verifica si se pulsó 'B'
    teclaPulsada 2Eh, notC; Verifica si se pulsó 'C'
    teclaPulsada 20h, notD; Verifica si se pulsó 'D'
    teclaPulsada 12h, notE; Verifica si se pulsó 'E'
    teclaPulsada 21h, notF; Verifica si se pulsó 'F'

    ret
validarTecla endp 

; -- Proc que ejecuta la operacion seleccionada
ejecSel proc

    ejecFun 1Eh, notA2, funcA; Ejecuta la funcion A
    ejecFun 30h, notB2, funcB; Ejecuta la funcion B
    ejecFun 2Eh, notC2, funcC; Ejecuta la funcion C
    ejecFun 20h, notD2, funcD; Ejecuta la funcion D
    ejecFun 12h, notE2, funcE; Ejecuta la funcion E
    ejecFun 21h, notF2, funcF; Ejecuta la funcion F

    ret
ejecSel endp

; -- Proc que ejecuta la opcion A
funcA proc
    
    imprimirMensaje 5, 15, txtA1
    
    ret
funcA endp

; -- Proc que ejecuta la opcion B
funcB proc

    imprimirMensaje 5, 15, txtB

    ret
funcB endp

; -- Proc que ejecuta la opcion C
funcC proc
    
    imprimirMensaje 5, 15, txtC1
    
    ret
funcC endp

; -- Proc que ejecuta la opcion D
funcD proc

    imprimirMensaje 5, 15, txtD

    ret
funcD endp

; -- Proc que ejecuta la opcion E
funcE proc  
    imprimirMensaje 5, 15, txtE
    
    ret
funcE endp

; -- Proc que ejecuta la opcion F
funcF proc
    limpiarPantalla
    imprimirMensaje 5, 15, txtF
    leerCadena 7, 15, cadena1

    imprimeF:
    imprimirMensaje 9, 15, txtR
    mov al, 17h
    cmp al, sel
    jnz leerF; Si no es I, seguimos leyendo
    reposicionarCursor 11, 15
    mov ah, 09h; Imprimimos el texto
    lea si, cadena1; Obtenermos dirección
    add si, 2; Desplazamos al inicio
    mov dx, si
    int 21h
    mov byte ptr[si-1], 0; Limpiamos el espacio de la cadena

    leerF:
    in al, 60h; Leemos la entrada
    cmp al, 01; Si es escape salimos
    jz salirF
    teclaPulsada 17h, notI; Si es I se imprime el resultado
    jmp imprimeF

    salirF:
    limpiarEntrada
    limpiarPantalla
    mov al, 08
    mov sel, al; Devolvemos sel a su valor estandar
    ret

funcF endp

end Principal