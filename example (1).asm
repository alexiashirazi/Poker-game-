.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf:proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "joc de poker",0
area_width EQU 640
area_height EQU 480
area DD 0
n dd 0
click_shuffle dd 0
counter DD 0 ; numara evenimentele de tip timer
format db "%d ",0
format1 db " ",10,0
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

check dd 0
unu equ 1

symbol_width EQU 10
symbol_height EQU 20

image_width EQU 40
image_height equ 50
skin dd 0
poz1 dd 0
 poz dd 0

vector db 15 dup(-1)
lgsir dd ($-vector)
p dd 0
carte_1 db 0
carte_2 db 0
carte_3 db 0
carte_4 db 0
carte_5 db 0

include digits.inc
include letters.inc
include picture.inc
 button_x EQU 480
 button_y EQU 410
 
 button_card_x equ 500
 button_card_y equ 20
 button_card_length equ 88
 button_length EQU 70
 button_height equ 30
 coord_x dd 180
 array db 5 dup(-1)
 frecv db 13 dup (0)
 count db 0
 carte_kind_1 dd 0
  carte_kind_2 dd 0
   carte_kind_3 dd 0
    carte_kind_4 dd 0
	 carte_kind_5 dd 0
copie dd 0
kind db 5 dup(0)
colour db 5 dup(0)
frecv_colour db 4 dup(0)
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp
; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - yS of drawing start position
; arg4- a cata carte 
make_image proc
	push ebp
	mov ebp, esp
	pusha
	lea esi, picture
	mov ecx, image_height
	imul ecx, image_width
	imul ecx,4
	imul ecx, [ebp+arg4]
	add esi,ecx
	;mov eax,[ebp+arg4]
draw_image:
	; mov ebx, image_width ; 51*area_width
	; mul ebx
	; mov ebx, image_height
	; mul ebx
	; add esi, eax
	; imul eax, [ebp+arg4]
	mov ecx, image_height
	; imul ecx,[ebp+arg4]
	; mov edi, ecx
	; sub edi,[ebp+arg4]
	; mov m,edi
	
loop_draw_lines:
	; mov edx, [ebp+arg4]
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	
	shl eax, 2 ; multiply by 4 (DWORD per pixel)

	add edi, eax
	

	push ecx
	mov ecx, image_width ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	push edi
	mov edi,0
	mov edi,skin
	cmp edi,1
	je skin_1
	cmp edi,2
	je skin_2
	cmp edi,0
	je skin_3
	jmp fara_culoare
	
	skin_1:
	rol eax,50
	jmp fara_culoare
	
	skin_2:
	shl eax,4
	jmp fara_culoare
	
	skin_3:
	ror eax,32
	jmp fara_culoare
	
	fara_culoare:
	pop edi
	mov dword ptr [edi], eax ; take data from variable to canvas
	
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	

	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
		
	res_img:
	popa

	
	mov esp, ebp
	pop ebp
	ret
make_image endp

generate_cards proc
push ebp
mov ebp,esp
	mov ecx,[ebp+arg2] ;; folosesc ecx pt loop ca sa mi genereze exact 5 carti
	mov esi,[ebp+arg1] ;aici e poz
	
	rand:
	rdtsc
	mov edx,0
	mov edi,0
	mov ebx,52 ;; cu ebx voi face %52
	div ebx ;; in edx voi avea restul
	;add edx,1 ; ca sa incepem de la 1
	;push ecx ;; salvez in stiva
	
	mov eax,edi
	verif:
	cmp eax,51
	je eticheta
	cmp dl, vector[eax]
	je rand
	inc eax
	jmp verif
	eticheta:
	cmp edi,51
	je afis
	
	mov ebx, 0
	mov bl, vector[esi]
	cmp bl,-1
	je afis
	inc edi
	jmp verif

	afis:
	mov vector[esi],dl
	inc esi
	push esi
	push ecx
	
	push edx
	push offset format
	call printf
	add esp,8
	
	pop ecx
	pop esi
	loop rand
	mov edi, esi
	mov poz, edi
	
	mov ebp,esp
	pop ebp
	ret
	generate_cards endp

	

	
;;macro generare carto
ordonare proc

push ebp
mov ebp,esp

; for(int i=0;i<lgsir-1;i++)
;; for(int j=i+1;j<lgsir;j++)
mov eax,0 
mov ebx,0
bucla_mare:
mov ebx,eax
		inc ebx
	bucla_mica:
		mov ecx,0
		mov cl,vector[eax] ;7
		cmp cl,-1
		je iesire
		mov edx,0
		mov dl,vector[ebx];2
		cmp dl,-1
		je cond_3
		cmp cl,dl
		jg interschimbare
		
		conditie:
		
		mov esi,lgsir
		dec esi
		cmp ebx,esi
		je out_1
		
		inc ebx
		jmp bucla_mica
		
		
			interschimbare:
			xchg cl,dl
			mov vector[eax],cl
			mov vector[ebx],dl
			conditie_1:
		mov esi,lgsir
		dec esi
		cmp ebx,esi
		je out_1
		inc ebx
		jmp bucla_mica
	out_1:
	mov esi,lgsir
	sub esi,2
	cmp eax,esi
	je iesire
	cond_3:
	inc eax
	jmp bucla_mare
			

iesire:
mov esp,ebp
	pop ebp
	ret
ordonare endp
macro_carti macro poz,n
	push n 
	push poz
	call generate_cards
	add esp,8
	endm
; simple macro to call the procedure easier
make_image_macro macro drawArea, x, y,cnt
	push cnt
	push y
	push x
	push drawArea
	call make_image
	add esp, 16
endm

; make_card proc
; push ebp 
; mov ebp,esp
; pusha
; mov eax, [ebp+arg1]
; cmp,

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x, y, len, color
local bucla_linie
 	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
	bucla_linie:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_linie
endm

linie_oblica macro x,y,len,color
local bucla_oblica
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx,len
	
	mov dword ptr[eax],color
	add eax,4
	
	
	endm
	

line_vertical macro x, y, len, color
local bucla_linie
 	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
	bucla_linie:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop bucla_linie
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	mov ebx,0
	mov eax, [ebp+arg2]
	cmp eax, 480
	jl button_fail
	cmp eax, 550
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, 410
	jl button_fail
	cmp eax, 440
	jg button_fail
	
	
	
	;s-a dat click in cadran

	mov n,3
	jmp cadran
	
	
	button_fail:
	jmp afisare_litere
bucla_linii:
	; mov eax, [ebp+arg2]
	; and eax, 0FFh
	;provide a new (random) color
	; mul eax
	; mul eax
	; add eax, ecx
	; push ecx
	; mov ecx, area_width
	jmp afisare_litere
bucla_coloane:
	; mov [edi], eax
	; add edi, 4
	; add eax, ebx
	; loop bucla_coloane
	; pop ecx
	; loop bucla_linii
	jmp afisare_litere
	
evt_timer:
	inc counter
	
	
afisare_litere:
	; pop ebx
	; cmp ebx,3
	; jne litere_1
	
	; make_text_macro  ' ', area, 495,415
	 ; make_text_macro ' ', area, 505,415
	 ; make_text_macro ' ', area, 515,415
	 ; make_text_macro ' ', area, 525,415
	 ; make_text_macro  'D', area, 200,200
	; jmp final_draw
	; litere_1:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	mov edi,n
	cmp edi, 3
	je cadran
	
	
		
	line_horizontal 20, 410, 60,0
	line_horizontal 20, 440, 60,0
	line_vertical 20, 410, 30,0
	line_vertical 80,410,30,0
	
	make_text_macro "S", area, 25,415
	make_text_macro "K", area, 35,415
	make_text_macro "I", area, 45,415
	make_text_macro "N", area, 55,415
	
	line_horizontal button_x, button_y, button_length,0
	line_horizontal button_x, button_y+button_height, button_length,0
	line_vertical button_x, button_y, button_height,0
	line_vertical button_x+button_length, button_y,button_height,0
	
	
	
	

	
	; make_text_macro  'D', area, 200,200
	make_text_macro  'D', area, 495,415
	make_text_macro 'E', area, 505,415
	make_text_macro 'A', area, 515,415
	make_text_macro 'L', area, 525,415
	
	make_text_macro 'A', area, 20,460
	make_text_macro 'L', area, 30,460
	make_text_macro 'E', area, 40,460
	make_text_macro 'X', area, 50,460
	make_text_macro 'I', area, 60,460
	make_text_macro 'A', area, 70,460
	
	make_text_macro 'S', area, 90,460
	make_text_macro 'H', area, 100,460
	make_text_macro 'I', area, 110,460
	make_text_macro 'R', area, 120,460
	make_text_macro 'A', area, 130,460
	make_text_macro 'Z', area, 140,460
	make_text_macro 'I', area, 150,460
	
	; linie_oblica 520,218, 8,0
		; linie_oblica 521,217, 8,0
	; linie_oblica 522,219, 8,0
	; linie_oblica 523,220, 8,0
	; linie_oblica 520,218, 8,0
	; linie_oblica 520,218, 8,0
	
	
	
	


	
	
	;;carti

	
	 jmp final_draw
	 cadran:
	make_text_macro  ' ', area, 495,415
	 make_text_macro ' ', area, 505,415
	 make_text_macro ' ', area, 515,415
	 make_text_macro ' ', area, 525,415
	 line_horizontal button_x, button_y, button_length,0ffffffh
	line_horizontal button_x, button_y+button_height, button_length,0ffffffh
	line_vertical button_x, button_y, button_height,0ffffffh
	line_vertical button_x+button_length, button_y,button_height,0ffffffh
	
	imagine:
		

	;make_image_macro area, 120,180,26
	 ; make_image_macro area, 190,180,1
	; make_image_macro area, 260,180 ,2
	; make_image_macro area,330,180 ,40
	; make_image_macro area, 400,180 ,41
	; make_image_macro area, 470,180 ,42
	
		
	mov eax, check
	
	cmp eax, unu
	jb generare_carti_buton
	jmp	afisare_carti
	generare_carti_buton:
	macro_carti poz,5
	;call ordonare
inc check

afisare_carti:
	;call ordonare
	;call ordonare
	
	 mov esi,0
	 
	 reset_frecv:
	 
	 mov frecv[esi],0
	 cmp esi,12
	 je iesire_afara
	 inc esi
	 jmp reset_frecv
	 
	 iesire_afara:
	 mov esi,0
	 reset_frecv_colour:
	 mov frecv_colour[esi],0
	 cmp esi,3
	 je iesire_afara1
	 inc esi
	 jmp reset_frecv_colour
	iesire_afara1:
	mov eax,0
	
	mov eax,0
	mov eax,[ebp+arg2]
	cmp eax,20
	jl asociere
	cmp eax,80
	jg asociere
	mov eax,0
	mov eax, [ebp+arg3]
	cmp eax,410
	jl asociere
	cmp eax,440
	jg asociere
	jmp click_skin
	
	
	click_skin:
	mov eax,0
	rdtsc 
	sub al,ah
	mov ebx,0
	mov edx,0
	mov ebx,3
	div ebx
	mov skin,edx
	
	asociere:
	mov eax,0
	mov al,vector[0]
	make_image_macro area, 120,180,eax
	mov carte_1,al
	
	
	mov edx,0
	mov edx,[ebp+arg2]
	cmp edx,120
	jl card_1
	cmp edx,160
	jg card_1
	mov edx,0
	mov edx, [ebp+arg3]
	cmp edx,180
	jl card_1
	cmp edx,230
	jg card_1
	jmp generate_0
	
	
	card_1:
	;call ordonare
	mov al,vector[1]
		mov carte_2,al

	make_image_macro area,190,180,eax
	
		mov edx,0
	mov edx,[ebp+arg2]
	cmp edx,190
	jl card_2
	cmp edx,230
	jg card_2
	mov edx,0
	mov edx, [ebp+arg3]
	cmp edx,180
	jl card_2
	cmp edx,230
	jg card_2
	jmp generate_1
	
	card_2:
		;call ordonare

	mov al,vector[2]
		mov carte_3,al

	make_image_macro area, 260,180,eax
	
			mov edx,0
	mov edx,[ebp+arg2]
	cmp edx,260
	jl card_3
	cmp edx,300
	jg card_3
	mov edx,0
	mov edx, [ebp+arg3]
	cmp edx,180
	jl card_3
	cmp edx,230
	jg card_3
	jmp generate_2
	
	card_3:
		;call ordonare

	mov al,vector[3]
		mov carte_4,al

	make_image_macro area,330,180,eax
	
		mov edx,0
	mov edx,[ebp+arg2]
	cmp edx,330
	jl card_4
	cmp edx,370
	jg card_4
	mov edx,0
	mov edx, [ebp+arg3]
	cmp edx,180
	jl card_4
	cmp edx,230
	jg card_4
	jmp generate_3
	
	card_4:
		;call ordonare

	mov al,vector[4]
		mov carte_5,al

	make_image_macro area,400,180,eax
	
	mov edx,0
	mov edx,[ebp+arg2]
	cmp edx,400
	jl verif_1
	cmp edx,440
	jg verif_1
	mov edx,0
	mov edx, [ebp+arg3]
	cmp edx,180
	jl verif_1
	cmp edx,230
	jg verif_1
	jmp generate_4
	
	verif_1:
	
	call ordonare
	jmp cont_0
	
	generate_0:
	 macro_carti poz, 1
	mov ebx,0
	 mov bl,vector[5]
	 mov vector[0],bl
	 mov vector[5],-1
	sub poz,1
	 jmp card_1
	
	
	generate_1:
	 macro_carti poz, 1
	 mov ebx,0
	 mov bl,vector[5]
	 mov vector[1],bl
	mov vector[5],-1
		sub poz,1

	jmp card_2
	
	generate_2:
	 macro_carti poz, 1
	 mov ebx,0
	 mov bl,vector[5]
	 mov vector[2],bl
	mov vector[5],-1
		sub poz,1

	jmp card_3
	
	generate_3:
	 macro_carti poz, 1
	 mov ebx,0
	 mov bl,vector[5]
	 mov vector[3],bl
	mov vector[5],-1
		sub poz,1

	jmp card_4

	generate_4:
	macro_carti poz, 1
	 mov ebx,0
	 mov bl,vector[5]
	 mov vector[4],bl
	mov vector[5],-1
		sub poz,1
		

		jmp verif_1
	
	

	cont_0:
	;;prima verificare pentru straight flush
	mov al,carte_1 ;in al pun prima carte si in bl a doua
	mov bl, carte_2; scad din a doua prima si verific daca scaderea e 1 adica daca sunt consecutive
	sub bl,al
	cmp bl,1
	je cont
		jmp four_of; daca nu verifica oricare din conditii sar la urmatoarea verificare , adica  four of a kind

	
	cont:
	mov al,carte_2 ; aceeasi gandire pt a doua si a treia
	mov bl, carte_3
	sub bl,al
	cmp bl,1
	je cont_1
		jmp four_of ; daca nu verifica sar la four of a kind

	
	cont_1:
	mov al, carte_3; verific a treia cu a patra
	mov bl,carte_4
	sub bl,al
	cmp bl,1
	je cont_2
		jmp four_of

	
	cont_2:
	mov al,carte_4 ; verific a patra cu a 5-a
	mov bl, carte_5
	sub bl, al
	cmp bl,1
	je straight_flush
	jmp four_of
	
	
	

	
	straight_flush:
	
	
	; daca s-au indeplinit conditiile sar la straight flush
	make_text_macro  'S', area, 190,270
	 make_text_macro 'T', area, 200,270
	 make_text_macro 'R', area, 210,270
	make_text_macro  'A', area,220,270
	make_text_macro  'I', area, 230,270
	 make_text_macro 'G', area, 240,270
	 make_text_macro 'H', area, 250,270
	make_text_macro  'T', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro 'F', area, 280,270
	 make_text_macro 'L', area, 290,270
	 make_text_macro  'U', area, 300,270
	 make_text_macro 'S', area, 310,270
	 make_text_macro 'H', area, 320,270
	 make_text_macro ' ',area,330,270
	 make_text_macro '1' , area,340,270
	 make_text_macro '0', area,350,270
	 make_text_macro 'p', area, 360,270
	 
	;;prima carte
		line_horizontal 120,230,40,337AFFh
		line_horizontal 120,179,40,337AFFh
		line_vertical 119,179,50,337AFFh
		line_vertical 160,179,50,337AFFh
		
	;; a doua carte
	line_horizontal 189,179,40,337AFFh
		line_horizontal 190,230,40,337AFFh
		line_vertical 189,179,50,337AFFh
		line_vertical 230,179,50,337AFFh
		
	;; a treia carte
	
	line_horizontal 260,179,40,337AFFh
		line_horizontal 260,230,40,337AFFh
		line_vertical 300,179,50,337AFFh
		line_vertical 259,179,50,337AFFh
		
		;; a patra carte
		line_horizontal 330,179,40,337AFFh
		line_horizontal 330,230,40,337AFFh
		line_vertical 329,180,50,337AFFh
		line_vertical 370,179,50,337AFFh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,337AFFh
		line_horizontal 399,230,40,337AFFh
		line_vertical 399,180,50,337AFFh
		line_vertical 440,180,50,337AFFh
	 	jmp final_draw
	
	
	four_of:
	;prima carte
		line_horizontal 120,230,40,0ffffffh
		line_horizontal 120,179,40,0ffffffh
		line_vertical 119,179,50,0ffffffh
		line_vertical 160,179,50,0ffffffh
		
	;; a doua carte
	line_horizontal 189,179,40,0ffffffh
		line_horizontal 190,230,40,0ffffffh
		line_vertical 189,179,50,0ffffffh
		line_vertical 230,179,50,0ffffffh
		
	;; a treia carte
	
	line_horizontal 260,179,40,0ffffffh
		line_horizontal 260,230,40,0ffffffh
		line_vertical 300,179,50,0ffffffh
		line_vertical 259,179,50,0ffffffh
		
		;; a patra carte
		line_horizontal 330,179,40,0ffffffh
		line_horizontal 330,230,40,0ffffffh
		line_vertical 329,180,50,0ffffffh
		line_vertical 370,179,50,0ffffffh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,0ffffffh
		line_horizontal 399,230,40,0ffffffh
		line_vertical 399,180,50,0ffffffh
		line_vertical 440,180,50,0ffffffh
	;incep prin a sterge continutul (adica textul straight flush)
	make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	  make_text_macro ' ',area,330,270
	 make_text_macro ' ' , area,340,270
	 make_text_macro ' ', area,350,270
	 make_text_macro ' ', area, 360,270
	
	; pun in vectorul kind restul impartirii la 13 adica numere de la 0 la 12
	mov eax,0
	mov al,carte_1
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[0],dl
	
	; asta e kind de a doua carte
	mov eax,0
	mov al,carte_2
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[1],dl
	
	;kind de a treia carte
	mov eax,0
	mov al,carte_3
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[2],dl
	
	;kind de a patra carte
	mov eax,0
	mov al,carte_4
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[3],dl
	
	;kind de a 5 a carte
	mov eax,0
	mov al,carte_5
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[4],dl
	
	;pun in eax kind[0] si verific cu urmatoarele 4 carti
	mov eax,0
	mov al,kind[0]
	mov esi,1 ; esi=1 ca sa inceapa de la elementul de dupa eax
	mov edi,1 ;incep cu edi de la 1 pt ca consider match si pe eax ;; de ex 2 3 2 2 2 eax e 2 si celelalte carti 2
	
	;;aici
	bucla_1:
	cmp al,kind[esi] ;verific daca eax si kind[esi] au acelasi numar
	je aduna1 ;daca sunt egale incrementez edi
	jmp cond_7 ; daca nu sar la conditia pt bucla
	
	aduna1:
	inc edi;aici se incrementeaza
	
	cond_7:
	cmp esi,4 ;compar daca nu cumva esi a ajuns la finalul vectorului
	je iesire_9
	inc esi;daca nu cresc esi si continui cautarea
	jmp bucla_1 ;sar la bucla
	
	
	iesire_9:
	mov copie,edi ;in iesire verific daca edi e 4 adica daca s-au gasit 4 carti la fel cu eax
	cmp edi,4
	je afisare_kind
	
	;;2 3 2 2 2
	mov eax,0
	mov al,kind[1];aceeasi gandire pt kind[1]
	mov esi,2 ;esi il iau cu unu dupa kind[1]
	mov edi,1 ;consider eax primul match
	
	;;aici
	bucla_2:
	cmp al,kind[esi]
	je aduna2 ;incrementez daca e egal eax cu urm element
	jmp cond_2
	
	aduna2:
	inc edi
	
	cond_2:
	cmp esi,4
	je iesire_8
	inc esi
	jmp bucla_2;continui cautarea pana ajunge la final
	
	
	iesire_8:
	mov copie,edi
	cmp copie,4;verific daca edi e 4 si daca e adv sar la afisare_kind
	je afisare_kind
	 ;e suficient sa fac doua cautari pt four of a kind pt ca de la al treilea element imi raman doar 2 de verific deci nu are sens
	jmp full_house ; daca nu a sarit la niciun afisare_kind sar la urmatoarea verificare adica pt full house
	
	 
	afisare_kind:
	; daca a fost adv atunci afisez gruparea
	
	make_text_macro  'F', area, 190,270
	 make_text_macro 'O', area, 200,270
	 make_text_macro 'U', area, 210,270
	make_text_macro  'R', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro 'O', area, 240,270
	 make_text_macro 'F', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  'A', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro 'K', area, 290,270
	 make_text_macro  'I', area, 300,270
	 make_text_macro 'N', area, 310,270
	 make_text_macro 'D', area, 320,270
	  make_text_macro ' ',area,330,270
	 make_text_macro '9' , area,340,270
	 make_text_macro 'p', area,350,270

	 jmp final_draw
	
	;aici incep urmatorul set de verificari
	full_house:
	
	 make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	   make_text_macro ' ',area,330,270
	 make_text_macro ' ' , area,340,270
	 make_text_macro ' ', area,350,270
	 
	; pun in vectorul kind restul impartirii la 13 adica numere de la 0 la 12
	mov eax,0
	mov al,carte_1
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[0],dl
	
	; asta e kind de a doua carte
	mov eax,0
	mov al,carte_2
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[1],dl
	
	;kind de a treia carte
	mov eax,0
	mov al,carte_3
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[2],dl
	
	;kind de a patra carte
	mov eax,0
	mov al,carte_4
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[3],dl
	
	;kind de a 5 a carte
	mov eax,0
	mov al,carte_5
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[4],dl
	
	mov esi,0
	
	bucla_frecv:
	mov eax,0
	mov al,kind[esi]
	mov ebx,0
	mov bl,frecv[eax]
	inc bl
	mov frecv[eax],bl
	 
	 cmp esi,4
	 je iesire_frecv
	 inc esi
	 jmp bucla_frecv
	 
	 
	 iesire_frecv:
	 mov edi,0
	 mov esi,0
	 mov edx,0
	 loop_cautare_frecv:
	 mov eax,0
	 mov al,frecv[esi]
	 cmp al,3
	 je adunare_frecv
	 cmp al,2
	 je adunare_frecv1
	 jmp cond_frecv
	 
	 adunare_frecv:
	 mov edi,3
	 jmp cond_frecv
	 
	 adunare_frecv1:
	 inc edx
	 
	 cond_frecv:
	 cmp esi,12
	 je iesire_frecv_1
	 inc esi
	 jmp loop_cautare_frecv
	 
	 iesire_frecv_1:
	 add edi,edx
	 cmp edi,4
	 je afisare_house
	 cmp edi,3
	 je afisare_three_of_a_kind
	 cmp edx,2
	 je afisare_two_pair
	 cmp edx,1
	 je afisare_one_pair
	
	 jmp verificare_flush
	 
	 afisare_house:
	 
	 
	 make_text_macro  'F', area, 190,270
	 make_text_macro 'U', area, 200,270
	 make_text_macro 'L', area, 210,270
	make_text_macro  'L', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro 'H', area, 240,270
	 make_text_macro 'O', area, 250,270
	make_text_macro  'U', area, 260,270
	 make_text_macro  'S', area, 270,270
	 make_text_macro 'E', area, 280,270
	   make_text_macro ' ',area,290,270
	 make_text_macro '8' , area,300,270
	 make_text_macro 'p', area,310,270
	 ;;prima carte
		line_horizontal 120,230,40,337AFFh
		line_horizontal 120,179,40,337AFFh
		line_vertical 119,179,50,337AFFh
		line_vertical 160,179,50,337AFFh
		
	;; a doua carte
	line_horizontal 189,179,40,337AFFh
		line_horizontal 190,230,40,337AFFh
		line_vertical 189,179,50,337AFFh
		line_vertical 230,179,50,337AFFh
		
	;; a treia carte
	
	line_horizontal 260,179,40,337AFFh
		line_horizontal 260,230,40,337AFFh
		line_vertical 300,179,50,337AFFh
		line_vertical 259,179,50,337AFFh
		
		;; a patra carte
		line_horizontal 330,179,40,337AFFh
		line_horizontal 330,230,40,337AFFh
		line_vertical 329,180,50,337AFFh
		line_vertical 370,179,50,337AFFh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,337AFFh
		line_horizontal 399,230,40,337AFFh
		line_vertical 399,180,50,337AFFh
		line_vertical 440,180,50,337AFFh
	jmp final_draw
	 
	 verificare_flush:
	 ;prima carte
		line_horizontal 120,230,40,0ffffffh
		line_horizontal 120,179,40,0ffffffh
		line_vertical 119,179,50,0ffffffh
		line_vertical 160,179,50,0ffffffh
		
	;; a doua carte
	line_horizontal 189,179,40,0ffffffh
		line_horizontal 190,230,40,0ffffffh
		line_vertical 189,179,50,0ffffffh
		line_vertical 230,179,50,0ffffffh
		
	;; a treia carte
	
	line_horizontal 260,179,40,0ffffffh
		line_horizontal 260,230,40,0ffffffh
		line_vertical 300,179,50,0ffffffh
		line_vertical 259,179,50,0ffffffh
		
		;; a patra carte
		line_horizontal 330,179,40,0ffffffh
		line_horizontal 330,230,40,0ffffffh
		line_vertical 329,180,50,0ffffffh
		line_vertical 370,179,50,0ffffffh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,0ffffffh
		line_horizontal 399,230,40,0ffffffh
		line_vertical 399,180,50,0ffffffh
		line_vertical 440,180,50,0ffffffh
		
	 make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	 
	 
	 
	 
; pun in vectorul colour catul impartirii la 13 adica numere de la 0 la 3
	mov eax,0
	mov al,carte_1
	mov ebx,13
	mov edx,0
	div ebx
	mov colour[0],al
	
	
	; asta e kind de a doua carte
	mov eax,0
	mov al,carte_2
	mov ebx,13
	mov edx,0
	div ebx
	mov colour[1],al

	
	
	;kind de a treia carte
	mov eax,0
	mov al,carte_3
	mov ebx,13
	mov edx,0
	div ebx
	mov colour[2],al

	
	;kind de a patra carte
	mov eax,0
	mov al,carte_4
	mov ebx,13
	mov edx,0
	div ebx
	mov colour[3],al
	
	
	;kind de a 5 a carte
	mov eax,0
	mov al,carte_5
	mov ebx,13
	mov edx,0
	div ebx
	mov colour[4],al	
	
	 
	 mov eax,0
	 mov esi,0
	
	frecventa_culoare:
	mov eax,0
	mov al,colour[esi]
	mov ebx,0
	mov bl,frecv_colour[eax]
	inc bl
	mov frecv_colour[eax],bl
	
	
	cmp esi,4
	je iesire_frecv_c1
	inc esi
	jmp frecventa_culoare
	
	iesire_frecv_c1:
	mov edi,0
	mov esi,0
	
	loop_cautare_culoare_frecv:
	 mov eax,0
	 mov al,frecv_colour[esi]
	 cmp al,5
	 je adunare_frecv_culoare
	 
	 jmp cond_culoare
	 
	 adunare_frecv_culoare:
	 mov edi,7
	 
	 cond_culoare:
	 cmp esi,3
	 je iesire_frecv_10
	 inc esi
	 jmp loop_cautare_culoare_frecv
	 

	 
	 iesire_frecv_10:
	 cmp edi,7
	 je afisare_flush
	 jmp verificare_straight
	 
	 
	 afisare_flush:
	 make_text_macro  'F', area, 190,270
	 make_text_macro 'L', area, 200,270
	 make_text_macro 'U', area, 210,270
	make_text_macro  'S', area,220,270
	make_text_macro  'H', area, 230,270
	 make_text_macro ' ',area,240,270
	 make_text_macro '7' , area,250,270
	 make_text_macro 'p', area,260,270
	
	 ;;prima carte
		line_horizontal 120,230,40,337AFFh
		line_horizontal 120,179,40,337AFFh
		line_vertical 119,179,50,337AFFh
		line_vertical 160,179,50,337AFFh
		
	;; a doua carte
	line_horizontal 189,179,40,337AFFh
		line_horizontal 190,230,40,337AFFh
		line_vertical 189,179,50,337AFFh
		line_vertical 230,179,50,337AFFh
		
	;; a treia carte
	
	line_horizontal 260,179,40,337AFFh
		line_horizontal 260,230,40,337AFFh
		line_vertical 300,179,50,337AFFh
		line_vertical 259,179,50,337AFFh
		
		;; a patra carte
		line_horizontal 330,179,40,337AFFh
		line_horizontal 330,230,40,337AFFh
		line_vertical 329,180,50,337AFFh
		line_vertical 370,179,50,337AFFh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,337AFFh
		line_horizontal 399,230,40,337AFFh
		line_vertical 399,180,50,337AFFh
		line_vertical 440,180,50,337AFFh
	 jmp final_draw
	 
	 verificare_straight:
	 ;prima carte
		line_horizontal 120,230,40,0ffffffh
		line_horizontal 120,179,40,0ffffffh
		line_vertical 119,179,50,0ffffffh
		line_vertical 160,179,50,0ffffffh
		
	;; a doua carte
	line_horizontal 189,179,40,0ffffffh
		line_horizontal 190,230,40,0ffffffh
		line_vertical 189,179,50,0ffffffh
		line_vertical 230,179,50,0ffffffh
		
	;; a treia carte
	
	line_horizontal 260,179,40,0ffffffh
		line_horizontal 260,230,40,0ffffffh
		line_vertical 300,179,50,0ffffffh
		line_vertical 259,179,50,0ffffffh
		
		;; a patra carte
		line_horizontal 330,179,40,0ffffffh
		line_horizontal 330,230,40,0ffffffh
		line_vertical 329,180,50,0ffffffh
		line_vertical 370,179,50,0ffffffh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,0ffffffh
		line_horizontal 399,230,40,0ffffffh
		line_vertical 399,180,50,0ffffffh
		line_vertical 440,180,50,0ffffffh
	 make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	 
	 ; pun in vectorul kind restul impartirii la 13 adica numere de la 0 la 12
	mov eax,0
	mov al,carte_1
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[0],dl
	
	; asta e kind de a doua carte
	mov eax,0
	mov al,carte_2
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[1],dl
	
	;kind de a treia carte
	mov eax,0
	mov al,carte_3
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[2],dl
	
	;kind de a patra carte
	mov eax,0
	mov al,carte_4
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[3],dl
	
	;kind de a 5 a carte
	mov eax,0
	mov al,carte_5
	mov ebx,13
	mov edx,0
	div ebx
	mov kind[4],dl
	
	mov eax,0
	mov al,kind[0]
	mov bl,kind[1]
	sub bl,al
	cmp bl,1
	je straight_cond_1
	jmp three_of_a_kind
	
	straight_cond_1:
	mov al,kind[1]
	mov bl,kind[2]
	sub bl,al
	cmp bl,1
	je straight_cond_2
	jmp three_of_a_kind
	
	straight_cond_2:
	mov al,kind[2]
	mov bl,kind[3]
	sub bl,al
	cmp bl,1
	je straight_cond_3
	jmp three_of_a_kind
	
	straight_cond_3:
	mov al,kind[3]
	mov bl,kind[4]
	sub bl,al
	cmp bl,1
	je afisare_straight
	jmp three_of_a_kind
	
	afisare_straight:
	make_text_macro  'S', area, 190,270
	 make_text_macro 'T', area, 200,270
	 make_text_macro 'R', area, 210,270
	make_text_macro  'A', area,220,270
	make_text_macro  'I', area, 230,270
	 make_text_macro 'G', area, 240,270
	 make_text_macro 'H', area, 250,270
	make_text_macro  'T', area, 260,270
	 make_text_macro ' ',area,270,270
	 make_text_macro '6' , area,280,270
	 make_text_macro 'p', area,290,270

	
	 ;;prima carte
		line_horizontal 120,230,40,337AFFh
		line_horizontal 120,179,40,337AFFh
		line_vertical 119,179,50,337AFFh
		line_vertical 160,179,50,337AFFh
		
	;; a doua carte
	line_horizontal 189,179,40,337AFFh
		line_horizontal 190,230,40,337AFFh
		line_vertical 189,179,50,337AFFh
		line_vertical 230,179,50,337AFFh
		
	;; a treia carte
	
	line_horizontal 260,179,40,337AFFh
		line_horizontal 260,230,40,337AFFh
		line_vertical 300,179,50,337AFFh
		line_vertical 259,179,50,337AFFh
		
		;; a patra carte
		line_horizontal 330,179,40,337AFFh
		line_horizontal 330,230,40,337AFFh
		line_vertical 329,180,50,337AFFh
		line_vertical 370,179,50,337AFFh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,337AFFh
		line_horizontal 399,230,40,337AFFh
		line_vertical 399,180,50,337AFFh
		line_vertical 440,180,50,337AFFh
	 jmp final_draw
	 
	three_of_a_kind:
	mov edi,0
	jmp high_card 
	
	afisare_three_of_a_kind:
	 ;;prima carte
		line_horizontal 120,230,40,337AFFh
		line_horizontal 120,179,40,337AFFh
		line_vertical 119,179,50,337AFFh
		line_vertical 160,179,50,337AFFh
		
	;; a doua carte
	line_horizontal 189,179,40,337AFFh
		line_horizontal 190,230,40,337AFFh
		line_vertical 189,179,50,337AFFh
		line_vertical 230,179,50,337AFFh
		
	;; a treia carte
	
	line_horizontal 260,179,40,337AFFh
		line_horizontal 260,230,40,337AFFh
		line_vertical 300,179,50,337AFFh
		line_vertical 259,179,50,337AFFh
		
		;; a patra carte
		line_horizontal 330,179,40,337AFFh
		line_horizontal 330,230,40,337AFFh
		line_vertical 329,180,50,337AFFh
		line_vertical 370,179,50,337AFFh
		
		;; a 5-a carte
		
		line_horizontal 399,179,40,337AFFh
		line_horizontal 399,230,40,337AFFh
		line_vertical 399,180,50,337AFFh
		line_vertical 440,180,50,337AFFh
		
		
	 make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	 
	  make_text_macro  'T', area, 190,270
	 make_text_macro 'H', area, 200,270
	 make_text_macro 'R', area, 210,270
	make_text_macro  'E', area,220,270
	make_text_macro  'E', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro 'O', area, 250,270
	make_text_macro  'F', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro 'A', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  'K', area, 300,270
	 make_text_macro 'I', area, 310,270
	 make_text_macro 'N', area, 320,270
	 make_text_macro 'D', area, 330,270
	  make_text_macro ' ',area,340,270
	 make_text_macro '5' , area,350,270
	 make_text_macro 'p', area,360,270
	 jmp final_draw
	 
	 afisare_two_pair:
	 
	 make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	 make_text_macro ' ', area, 330,270
	 
	  make_text_macro  'T', area, 190,270
	 make_text_macro 'W', area, 200,270
	 make_text_macro 'O', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  'P', area, 230,270
	 make_text_macro 'A', area, 240,270
	 make_text_macro 'I', area, 250,270
	make_text_macro  'R', area, 260,270
	 make_text_macro ' ',area,290,270
	 make_text_macro '4' , area,300,270
	 make_text_macro 'p', area,310,270
	 jmp final_draw
	 
	 afisare_one_pair:
	 
	  make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	 make_text_macro ' ', area, 330,270
	 
	 make_text_macro  'O', area, 190,270
	 make_text_macro 'N', area, 200,270
	 make_text_macro 'E', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  'P', area, 230,270
	 make_text_macro 'A', area, 240,270
	 make_text_macro 'I', area, 250,270
	make_text_macro  'R', area, 260,270
	 make_text_macro ' ',area,270,270
	 make_text_macro '3' , area,280,270
	 make_text_macro 'p', area,290,270
	 jmp final_draw
	 
	 high_card:
	   make_text_macro  ' ', area, 190,270
	 make_text_macro ' ', area, 200,270
	 make_text_macro ' ', area, 210,270
	make_text_macro  ' ', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro ' ', area, 240,270
	 make_text_macro ' ', area, 250,270
	make_text_macro  ' ', area, 260,270
	 make_text_macro  ' ', area, 270,270
	 make_text_macro ' ', area, 280,270
	 make_text_macro ' ', area, 290,270
	 make_text_macro  ' ', area, 300,270
	 make_text_macro ' ', area, 310,270
	 make_text_macro ' ', area, 320,270
	 make_text_macro ' ', area, 330,270
	 
	    make_text_macro  'H', area, 190,270
	 make_text_macro 'I', area, 200,270
	 make_text_macro 'G', area, 210,270
	make_text_macro  'H', area,220,270
	make_text_macro  ' ', area, 230,270
	 make_text_macro 'C', area, 240,270
	 make_text_macro 'A', area, 250,270
	make_text_macro  'R', area, 260,270
	 make_text_macro  'D', area, 270,270
	  make_text_macro ' ',area,280,270
	 make_text_macro '2' , area,290,270
	 make_text_macro 'p', area,300,270
	 
	 
	 
	 
final_draw:
    
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start