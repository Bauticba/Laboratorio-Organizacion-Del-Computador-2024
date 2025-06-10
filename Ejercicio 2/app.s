	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34

	.globl main
	.globl bloques

main:

    // x0 contiene la direccion base del framebuffer
    mov x20, x0 // Guarda la dirección base del framebuffer en x20
    mov x23, 0x0  //Contador para cambiar color

    movz x17, 0x55, lsl 16
    movk x17, 0x5555, lsl 00            // Gris Carretera

	movz x18, 0x87, lsl 16
    movk x18, 0xCEFF, lsl 00            // Celeste Cielo
    
    movz x19, 0xD5, lsl 16
    movk x19, 0xAB55, lsl 00            // Amarillo linea

	movz x21, 0xE, lsl 16 
    movk x21, 0xF400, lsl 00            //posicion inicial de lineas

	movz x24, 0x5, lsl 16 
    movk x24, 0xF800, lsl 00            //posicion inicial de Montañas

	movz x27, 0x1, lsl 16 
    movk x27, 0xF400, lsl 00            //posicion inicial de nube 1

	movz x16, 0x1, lsl 16 
    movk x16, 0x0000, lsl 00            //posicion inicial de nube 2    


loop_animation:
// Printeo "el Cielo" usando la funcion de cuadrados

    mov x5, x18                 //Celeste cielo
    mov x25, 640                // Ancho de la pantalla
    mov x26, 310                // hasta que llegue a la parte en que empiezo a pintar carretera
    movz x4, 0x00, lsl 16       // Dirección de inicio + 0 -> Printea desde la direccion base del framebuffer
    movk x4, 0x0000, lsl 00 
    bl cuadrado
    

// Printeo "Carretera" usando la funcion de cuadrados

    mov x5, x17             // Carretera Gris 
    mov x25, 640            // Mismo ancho que el fondo
    mov x26, 180            // Pinto hasta el final de la pantalla
    movz x4, 0xB, lsl 16    // Empieza en Dirección = Dirección de inicio + 4 * [x + (y * 640)] con y = 300 x = 0
    movk x4, 0xC000, lsl 00 // Dirección = Dirección de inicio + 768,000 
    bl cuadrado	

// Ruedas
  
    mov x5, 0x0                 // Ruedas negras
    mov x11, 18
    mov x13, 2                  //Cantidad de ruedas que imprime
    movz x4, 0xF, lsl 16       //Posicion en la que imprime al primero
    movk x4, 0xD940, lsl 00
rueda:
    bl circulos
    add x4, x4, 300           // Distancia entre cada rueda 
    sub x13, x13, 1             // "Ya imprimi una rueda" entonces le resto una rueda al contador

    cbnz x13, rueda


// Primera hilera de nubes
 
    movz x5, 0xFF, lsl 16
    movk x5, 0xFFFF, lsl 00  //Nubes blancas
    mov x11, 48
    mov x13, 3              //Cantidad de circulos que imprime
    mov x4, x27
nube:
    bl circulos
    add x4, x4, 256        // Distancia entre cada circulo
    sub x13, x13, 1         // "Ya imprimi una Nube" entonces le resto una Nube al contador

    cbnz x13, nube 

// Segunda hilera de nubes
  
    movz x5, 0xFF, lsl 16
    movk x5, 0xFFFF, lsl 00     // nuebes blancas
    mov x11, 48
    mov x13, 3                  //Cantidad de circulos que imprime
    mov x4, x16
nube2:
    bl circulos
    add x4, x4, 256            // Distancia entre cada linea 
    sub x13, x13, 1             // "Ya imprimi una nube" entonces le resto una nube al contador

    cbnz x13, nube2 


// hilera de la carretera

    mov x5, x19		     //Linea Amarilla
    mov x25, 40          // Ancho de la linea    
	mov x26, 15			 // Largo de la linea
	mov x13, 8			 // Cantidad de lineas 
    mov x4, x21
lineacarretera:
    bl cuadrado
    add x4, x4, 320        // Distancia entre cada linea 
    sub x13, x13, 1         // "Ya imprimi una linea" entonces le resto una linea al contador

    cbnz x13, lineacarretera 


// Auto
    movz x5, 0xFF, lsl 16		     // Rojo auto
    movk x5, 0x0000, lsl 00
    mov x25, 140         // Ancho del auto    
	mov x26, 35		 // Largo del auto  
    movz x4, 0xE, lsl 16    //Posicion en la que imprime al primero
    movk x4, 0xF300, lsl 00 //Posicion en la que imprime al primero
    bl cuadrado


// Ventanas
    mov x5, 0x0		     // Negro
    mov x25, 120         // Ancho de la ventana    
	mov x26, 25		 // Largo de la ventana  
    movz x4, 0xE, lsl 16    //Posicion en la que imprime al primero
    movk x4, 0x172A, lsl 00 //Posicion en la que imprime al primero
    bl cuadrado


//Montañas
    movz x5, 0x96, lsl 16
    movk x5, 0x4B1F, lsl 00     //color gris Montañas
    mov x25, 300                 //ancho del triangulo
    mov x26, 150                 //altura del triangulo 
    mov x4, x24
    bl triangulo	    

    // Actualizar las posiciones para la próxima iteración
    sub x21, x21, 16        // Mover el auto a la izquierda
    sub x24, x24, 16        // mover la ventana a la izquierda
    sub x27, x27, 32        //mover las nubes 1 a la izquierda
    sub x16, x16, 64        //mover las nubes 2 a la izquierda

    // Esperar un momento (simple delay loop)
    mov x22, 0xFFFFFF
delay_loop:
    subs x22, x22, 1
    b.ne delay_loop

    // Repetir el bucle de animación
    b loop_animation

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Función para Pintar Pixeles ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

pintar_pixel:
    mov x0, x20
    cmp x2, SCREEN_WIDTH
    b.hs end_pintar_pixel
    cmp x3, SCREEN_HEIGH
    b.hs end_pintar_pixel
    mov x7, SCREEN_WIDTH
    madd x7, x3, x7, x2
    mov x8, x7
    lsl x8, x8, #2
    add x0, x0, x8
    stur w10, [x0]
end_pintar_pixel:
    br lr

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Función para Dibujar Líneas Horizontales ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

linea_horizontal:
    sub sp, sp, #16
    stur lr, [sp, 8]
    stur x2, [sp]

loop_linea_horizontal:
    cmp x2, x4
    b.gt end_loop_horizontal
    bl pintar_pixel
    add x2, x2, #1
    b loop_linea_horizontal

end_loop_horizontal:
    ldur lr, [sp, #8]
    ldur x2, [sp]
    add sp, sp, #16

    br lr

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Función para Dibujar Cuadrados/Rectángulos ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

cuadrado:
    mov x0, x20
    add x0, x0, x4
    mov x3, x0
    
    mov x2, 0
set2:
    mov x1, 0
set1:
     stur w5, [x0]
     add x0, x0, 4
     add x1, x1, 1
     cmp x1, x25
     b.ne set1
     add x3, x3, 2560
     mov x0, x3
     add x2, x2, 1
     cmp x2, x26
     b.ne set2
     br x30

circulos:
    mov x0,x20          //x0 direccion de inicio
    add x0,x0,x4        //direccion de inicio + dir cuadrado que contiene al circulo
    mov x3,x0
    mov x6,x11          //Coordenada x del centro del circulo radio x11
    mov x7,x11          //Coordenada y del centro del circulo radio x11
    mul x12,x11,x11     //Radio al cuadrado

    mov x2,0            //Primer pixel y
setc:
    mov x1,0            //Primer pixel x
setc2:
    sub x8 , x6, x1                     // x8 = x11 - 0
    mul x8, x8, x8                      // x8 = (x11 - 0)^2
    sub x9, x7, x2                      // x9 = x11 - 0
    mul x9, x9, x9                      // x4 = (x11 - 0)^2
    add x15, x8, x9                     // x5 = (x-x0)^2 + (y-y0)^2
    cmp x15, x12                        // Me fijo si es menor o igual al radio al cuadrado x11^2
    b.le pintar_circulo
    add x0,x0,4                         // siguiente pixel
    add x1,x1,1                         // recorro eje x
    cmp x1, x25                         // pinto mientras x sea distinto 
    b.ne setc2

ir_a_y:
    add x3,x3,2560                      // x3= x3 + (6401+0)4
    mov x0,x3
    add x2,x2,1                         // recorro eje y
    cmp x2,x26                          // mientras y sea distinto 
    b.ne setc
    br x30
    
pintar_circulo:
    stur w5, [x0]
    add x0, x0, 4                       // Siguiente pixel
    add x1, x1, 1                       // Incremento x   
    cmp x1, x25
    b.ne setc2                          // Si es el final del cuadrado vuelvo al loop Principal
    b ir_a_y                             // Vuelvo a ver la condicion


// Funcion que dibuja un triangulo

triangulo:
    mov x0, x20  // Base del framebuffer
    add x0, x0, x4  // Offset de inicio
    mov x3, x0
    
    mov x2, 0  // Coordenada y inicial
tri_set2:
    mov x1, 0  // Coordenada x inicial
tri_set1:
    // Calcula el centro del triángulo y los límites
    mov x10, x25  // Ancho del triángulo
    lsr x10, x10, 1  // Centro del triángulo
    sub x10, x10, x2  // Límite izquierdo del triángulo
    add x11, x10, x2, lsl 1  // Límite derecho del triángulo
    cmp x1, x10
    b.lt no_pintar
    cmp x1, x11
    b.gt no_pintar
    stur w5, [x0]  // Pinta el pixel
no_pintar:
    add x0, x0, 4
    add x1, x1, 1
    cmp x1, x25  // Verifica el ancho
    b.ne tri_set1
    add x3, x3, 2560
    mov x0, x3
    add x2, x2, 1
    cmp x2, x26  // Verifica la altura
    b.ne tri_set2
    br x30
