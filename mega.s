; megascroller en object list
;
;; object list OK
; 26*16 = 416

; resolution : debut = 20 (40) / fin = 261 (522) / de 56 à 520

; OK - calculer les 14 valeurs de Y intervalles entre les 2 lignes, en signé ! ligne basse - ligne haute / 15 => 16 lignes
; OK - lire les fontes 12 de large x 16 de haut : font_alien.png  pour ne garder que les couples YX à afficher
; OK - trier les couples YX / en fait ne pas trier mais parcourir et mettre dans les sous-listes de 16 lignes/Y + 8 lignes/Y => 256/16 = 16 groupes
; OK - créer une object list pour les N sprites, 16 lignes à chaque fois. entre X et X+8

; OK table de tailles de caractere
; OK - largeur de fonte variable ! i=3 / 1=3 / calés sur la droite
; OK - largeur des lettres trop larges : M V W 

; OK - tester sprite sur la gauche, X négatif - reglé

; OK - fade IN/ face OUT sur certains textes
; OK - écran d'intro avec fade in : image de fond puis chaque texte en fade in fade out

; OK - integrer LSP

;CC (Carry Clear) = %00100
;CS (Carry Set)   = %01000
;EQ (Equal)       = %00010
;MI (Minus)       = %11000
;NE (Not Equal)   = %00001
;PL (Plus)        = %10100
;HI (Higher)      = %00101
;T (True)         = %00000


	include	"jaguar.inc"

introduction_ON_OFF		equ			1
CLEAR_BSS			.equ			1									; 1=efface toute la BSS jusqu'a la fin de la ram utilisée

vitesse_scrolling	equ		4

GPU_OL_interrupt	equ				1					; object list GPU interrupt used to sync OL and GPU

nb_octets_par_ligne			equ		320
nb_lignes					equ		260

premiere_ligne				equ		20						; premiere ligne de l'ecran pour OL
derniere_ligne				equ		261						; derniere ligne de l'ecran pour OL

nb_colonnes_de_sprites_a_afficher	equ			26
nb_lignes_de_sprites_a_afficher		equ			16

ob_list_1				equ		(ENDRAM-64000)				; address of read list
ob_list_2				equ		(ENDRAM-128000)				; address of read list

; codes de controle du scrolling
GPU_scrolling_code_de_controle_code_minimal				equ		128
GPU_scrolling_code_de_controle_code_fin_de_texte		equ		128

; forme du scrolling
GPU_scrolling_code_de_controle_code_forme_0		equ		130					; No effect
GPU_scrolling_code_de_controle_code_forme_1		equ		131					; Sine 1
GPU_scrolling_code_de_controle_code_forme_2		equ		132					; Sine 2
GPU_scrolling_code_de_controle_code_forme_3		equ		133					; Bounce 1
GPU_scrolling_code_de_controle_code_forme_4		equ		134					; Bounce 2
GPU_scrolling_code_de_controle_code_forme_5		equ		135					; Rotate slow
GPU_scrolling_code_de_controle_code_forme_6		equ		136					; Rotate quick
GPU_scrolling_code_de_controle_code_forme_7		equ		137					; Cylinder
GPU_scrolling_code_de_controle_code_forme_8		equ		138					; Triangle
GPU_scrolling_code_de_controle_code_forme_9		equ		139					; Pack/Unpack

; codes dessin du sprites
GPU_scrolling_code_de_controle_code_0			equ		140					; // Yellow
GPU_scrolling_code_de_controle_code_1			equ		141					; // Blue
GPU_scrolling_code_de_controle_code_2			equ		142					; // Purple
GPU_scrolling_code_de_controle_code_3			equ		143					; // Germany
GPU_scrolling_code_de_controle_code_4			equ		144					; // France
GPU_scrolling_code_de_controle_code_5			equ		145					; // Belgium
GPU_scrolling_code_de_controle_code_6			equ		146					; // Great-Britain
GPU_scrolling_code_de_controle_code_7			equ		147					; // Sweden
GPU_scrolling_code_de_controle_code_8			equ		148					; // Nethelands
GPU_scrolling_code_de_controle_code_9			equ		149					; // Scotland
GPU_scrolling_code_de_controle_code_10			equ		150					; // Spain
GPU_scrolling_code_de_controle_code_11			equ		151					; // Australia
GPU_scrolling_code_de_controle_code_12			equ		152					; // Portugal
GPU_scrolling_code_de_controle_code_13			equ		153					; // Switzerland
GPU_scrolling_code_de_controle_code_14			equ		154					; // Luxembourg

colrY 	equ 	GPU_scrolling_code_de_controle_code_0
colrB 	equ		GPU_scrolling_code_de_controle_code_1
colrP	equ		GPU_scrolling_code_de_controle_code_2
flgDE	equ		GPU_scrolling_code_de_controle_code_3
flgFR	equ		GPU_scrolling_code_de_controle_code_4
flgBE	equ		GPU_scrolling_code_de_controle_code_5
flgGB	equ		GPU_scrolling_code_de_controle_code_6
flgSE	equ		GPU_scrolling_code_de_controle_code_7
flgNL	equ		GPU_scrolling_code_de_controle_code_8
flgSC	equ		GPU_scrolling_code_de_controle_code_9
flgES	equ		GPU_scrolling_code_de_controle_code_10
flgAU	equ		GPU_scrolling_code_de_controle_code_11
flgPT	equ		GPU_scrolling_code_de_controle_code_12
flgCH	equ		GPU_scrolling_code_de_controle_code_13
flgLU	equ		GPU_scrolling_code_de_controle_code_14

fNoop	equ		GPU_scrolling_code_de_controle_code_forme_0
fSin1	equ		GPU_scrolling_code_de_controle_code_forme_1
fSin2	equ		GPU_scrolling_code_de_controle_code_forme_2
fBce1	equ		GPU_scrolling_code_de_controle_code_forme_3
fBce2	equ		GPU_scrolling_code_de_controle_code_forme_4
fRot1	equ		GPU_scrolling_code_de_controle_code_forme_5
fRot2	equ		GPU_scrolling_code_de_controle_code_forme_6
fCyld	equ		GPU_scrolling_code_de_controle_code_forme_7
fTria	equ		GPU_scrolling_code_de_controle_code_forme_8
fGrow	equ		GPU_scrolling_code_de_controle_code_forme_9


GPU_STACK_SIZE	equ		32	; long words
GPU_USP			equ		(G_ENDRAM-(4*GPU_STACK_SIZE))
GPU_ISP			equ		(GPU_USP-(4*GPU_STACK_SIZE))

; ------------------------  LSP
DSP_music_ON						.equ			1								; 0/1 = music Off/On
LSP_DSP_Audio_frequence					.equ			32000				; real hardware needs lower sample frequencies than emulators 
nb_bits_virgule_offset					.equ			10					; 9 ok DRAM/ 8 avec samples en ram DSP
display_infos_debug				.equ			1
DSP_DEBUG						.equ			0
I2S_during_Timer1				.equ			0									; 0= I2S waits while timer 1 / 1=IMASK cleared while Timer 1
LSP_avancer_module				.equ			1								; 1=incremente position dans le module

channel_1		.equ		1
channel_2		.equ		1
channel_3		.equ		1
channel_4		.equ		1

DSP_STACK_SIZE	equ	32	; long words
DSP_USP			equ		(D_ENDRAM-(4*DSP_STACK_SIZE))
DSP_ISP			equ		(DSP_USP-(4*DSP_STACK_SIZE))

;------------------



.opt "~Oall"

.text

			.68000

	move.l		#$70007,G_END
	move.l		#$70007,D_END
	

	move.l		#INITSTACK, sp	
	move.w		#%0000011011000111, VMODE			; 320x256 / 16 bit RGB / $6C7
	
	move.w		#$100,JOYSTICK


; clear BSS
	.if			CLEAR_BSS=1
	lea			DEBUT_BSS,a0
	lea			FIN_RAM,a1
	moveq		#0,d0
	
boucle_clean_BSS:
	move.b		d0,(a0)+
	cmp.l		a0,a1
	bne.s		boucle_clean_BSS
; clear stack
	lea			INITSTACK-100,a0
	lea			INITSTACK,a1
	moveq		#0,d0
	
boucle_clean_BSS2:
	move.b		d0,(a0)+
	cmp.l		a0,a1
	bne.s		boucle_clean_BSS2
; clear object list
	lea			ob_list_2,a0
	lea			ENDRAM,a1
	moveq		#0,d0
	
boucle_clean_BSS3:
	move.b		d0,(a0)+
	cmp.l		a0,a1
	bne.s		boucle_clean_BSS3
	.endif
	
	;move	#$70,BG						; vert
	
	bsr		convert_texte_scrolling
	
	bsr     InitVideo2 





; init LSP
;check ntsc ou pal:

	moveq		#0,d0
	move.w		JOYBUTS ,d0
	move.l		#26593900,frequence_Video_Clock			; PAL
	move.l		#415530,frequence_Video_Clock_divisee

	
	btst		#4,d0
	beq.s		jesuisenpal
jesuisenntsc:
	move.l		#26590906,frequence_Video_Clock			; NTSC
	move.l		#415483,frequence_Video_Clock_divisee
jesuisenpal:


	move.l	#0,D_CTRL
; copie du code DSP dans la RAM DSP

	lea		YM_DSP_debut,A0
	lea		D_RAM,A1
	move.l	#YM_DSP_fin-DSP_base_memoire,d0
	lsr.l	#2,d0
	sub.l	#1,D0
boucle_copie_bloc_DSP:
	move.l	(A0)+,(A1)+
	dbf		D0,boucle_copie_bloc_DSP

; init LSP

	lea		LSP_module_music_data,a0
	lea		LSP_module_sound_bank,a1
	jsr		LSP_PlayerInit
	move.l	m_lspInstruments,a0

;		Out : 	a0: music BPM pointer (16bits).w
;				d0: music len in tick count

; launch DSP
	move.l	#REGPAGE,D_FLAGS
	move.l	#DSP_routine_init_DSP,D_PC
	move.l	#DSPGO,D_CTRL

	move.l	#0,LSP_DSP_flag

	move.l	#0,vbl_counter

; all colors to black
	lea		ecran_intro,a0
	bsr		copie_couleurs_dans_CLUT
	
	.if		introduction_ON_OFF=1
	bsr		introduction
	.endif

	move.l	#1,LSP_DSP_flag


	.if		DSP_music_ON=0
	move.l	#0,LSP_DSP_flag
	.endif

; -----------------
	
	
	
	.if		GPU_OL_interrupt=1
    bsr     InitVideo               	; Setup our video registers.
	.endif
	.if		GPU_OL_interrupt=0
    bsr     InitVideo2               	; Setup our video registers.
	.endif

	;move.w		#%0000001011000111, VMODE			; 640x256 / 16 bit RGB / $2C7


	move.l  #VBL,LEVEL0     	; Install 68K LEVEL0 handler
	move.w  a_vde,d0                	; Must be ODD
	sub.w   #16,d0
	ori.w   #1,d0
	move.w  d0,VI
	move.w  #%01,INT1                 	; Enable video interrupts 11101


	moveq	#0,d0
	move.l	d0,OLP
	
	move	#$2700,sr

	
	;move	#$70,BG						; vert


	lea		ob_list_1,a6
	bsr		preparation_OL

	lea		ob_list_2,a6
	bsr		preparation_OL

	;move	#$700,BG						; bleu


	lea		bob,a0
	bsr		copie_couleurs_dans_CLUT

	;jsr     copy_olist              	; use Blitter to update active list from shadow

	;move.l	#ob_list_1,d0					; set the object list pointer
	;swap	d0
	;move.l	d0,OLP



; mise en place vecteur VBL 68000
	move.l  #VBL,LEVEL0     	; Install 68K LEVEL0 handler
	move.w  a_vde,d0                	; Must be ODD
	sub.w   #16,d0
	ori.w   #1,d0
	move.w  d0,VI
	move.w  #%01,INT1                 	; Enable video interrupts 11101
	

	;and.w   #%1111100011111111,sr				; 1111100011111111 => bits 8/9/10 = 0
	and.w   #$f8ff,sr

	moveq	#3-1,d2
vsync2:
;vsync*2
	move.l		vbl_counter,d0
vsync1:
	move.l		vbl_counter,d1
	cmp.l		d0,d1
	beq.s		vsync1
	dbf		d2,vsync2


; copie du code GPU
	move.l	#0,G_CTRL
; copie du code GPU dans la RAM GPU

	lea		GPU_debut,A0
	lea		G_RAM,A1
	move.l	#GPU_fin-GPU_base_memoire,d0
	lsr.l	#2,d0
	sub.l	#1,D0
boucle_copie_bloc_GPU:
	move.l	(A0)+,(A1)+
	dbf		D0,boucle_copie_bloc_GPU

; launch GPU

	move.l	#REGPAGE,G_FLAGS
	move.l	#GPU_init,G_PC
	move.l  #RISCGO,G_CTRL	; START GPU

	move.l	#ob_list_1,d0					; set the object list pointer
	swap	d0
	move.l	d0,OLP
	


	;lea			liste_points_sprites,a0

	;stop		#$2700
	;stop #8448

	;move	#$770,BG						; bleu

	
toto:
	;move.l		vbl_counter,d0
	;move.l		vbl_counter_GPU,d1
	bra.s	toto


;-----------------------------------------------------------------------------------
; introduction avec sa VBL et son OL
introduction:
	jsr     copy_olist_intro
	
	jsr		copy_image_sur_ecran_intro

	move.l	#ob_list_1,d0					; set the object list pointer
	swap	d0
	move.l	d0,OLP
	
	

; mise en place vecteur VBL 68000
	move.l  #VBL_intro,LEVEL0     	; Install 68K LEVEL0 handler
	move.w  a_vde,d0                	; Must be ODD
	sub.w   #16,d0
	ori.w   #1,d0
	move.w  d0,VI
	move.w  #%01,INT1                 	; Enable video interrupts 11101
	
	and.w   #$f8ff,sr

	


; FADE IN sur les couleurs du fond
	lea		image_debut,a0
	bsr		copie_couleurs_dans_CLUT_FADEIN
	

; copie le texte 1

	lea		texte_intro1,a0
	lea		ecran_intro+(136*320),a1
	move.l	#(320*34)/2,d1
	jsr		copy_texte_intro_sur_ecran

; FADE IN sur le 255
; Bits [0-5] are green, bits [6-10] are blue and
; bits [11-15] are red.
FADE_IN_TEXTE1:
	lea		CLUT+(255*2),a1
	moveq	#0,d0
	move.w	#31-1,d7
	move.w	#%0000100001000010,d3
boucle2a1:
	move.w		#4-1,d6
	
boucle1a1:
	move.l		vbl_counter,d1
wait_1_VBLa1:

	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBLa1
	
	dbf			d6,boucle1a1
	
	add.w		d3,d0
	move.w		d0,(a1)
	;move.w		$FFFF,(a1)
	dbf			d7,boucle2a1
	move.w		d0,d4

; wait 10 secondes
	move.l		#(50*10),d0
wait_N_VBLa11:
	move.l		vbl_counter,d1
wait_1_VBLa11:
	move.l		LSP_DSP_buttonB_pressed,d3
	cmp.l		#0,d3
	beq.s		oka112
	jmp			retour_introduction
oka112:
	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBLa11
	dbf			d0,wait_N_VBLa11

; FADE OUT sur le 255
; Bits [0-5] are green, bits [6-10] are blue and
; bits [11-15] are red.
FADE_OUT_TEXTE1:
	lea		CLUT+(255*2),a1
	move.w	d4,d0					; precedente couleur
	move.w	#31-1,d7
	move.w	#%0000100001000010,d3
.boucle2:
	move.w		#4-1,d6
	
.boucle1:
	move.l		vbl_counter,d1
.wait_1_VBL:
	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		.wait_1_VBL
	
	dbf			d6,.boucle1
	
	sub.w		d3,d0
	move.w		d0,(a1)
	;move.w		$FFFF,(a1)
	dbf			d7,.boucle2

	move.w		#0,(a1)

; ecrase le bas de l'image avec l'originale
	lea		image_debut+512+(136*320),a0
	lea		ecran_intro+(136*320),a1
	move.l	#(320*35)/2,d1
	jsr		copy_texte_intro_sur_ecran_ecrase
	

; TEXTE2
; copie le texte 2

	lea		texte_intro1+(320*44),a0
	lea		ecran_intro+(136*320),a1
	move.l	#(320*55)/2,d1
	jsr		copy_texte_intro_sur_ecran

; FADE IN sur le 255
; Bits [0-5] are green, bits [6-10] are blue and
; bits [11-15] are red.
FADE_IN_TEXTE2:
	lea		CLUT+(255*2),a1
	moveq	#0,d0
	move.w	#31-1,d7
	move.w	#%0000100001000010,d3
boucle2a2:
	move.w		#4-1,d6
	
boucle1a2:
	move.l		vbl_counter,d1
wait_1_VBLa2:

	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBLa2
	
	dbf			d6,boucle1a2
	
	add.w		d3,d0
	move.w		d0,(a1)
	;move.w		$FFFF,(a1)
	dbf			d7,boucle2a2
	move.w		d0,d4

; wait 10 secondes
	move.l		#(50*10),d0
wait_N_VBL2:
	move.l		vbl_counter,d1
wait_1_VBL2:
	move.l		LSP_DSP_buttonB_pressed,d3
	cmp.l		#0,d3
	beq.s		oka114
	jmp			retour_introduction
oka114:

	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBL2
	dbf			d0,wait_N_VBL2

; FADE OUT sur le 255
; Bits [0-5] are green, bits [6-10] are blue and
; bits [11-15] are red.
FADE_OUT_TEXTE2:
	lea		CLUT+(255*2),a1
	move.w	d4,d0					; precedente couleur
	move.w	#31-1,d7
	move.w	#%0000100001000010,d3
boucle22:
	move.w		#4-1,d6
	
boucle12:
	move.l		vbl_counter,d1
wait_1_VBL2a1:

	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBL2a1
	
	dbf			d6,boucle12
	
	sub.w		d3,d0
	move.w		d0,(a1)
	;move.w		$FFFF,(a1)
	dbf			d7,boucle22

	move.w		#0,(a1)

; ecrase le bas de l'image avec l'originale
	lea		image_debut+512+(136*320),a0
	lea		ecran_intro+(136*320),a1
	move.l	#(320*55)/2,d1
	jsr		copy_texte_intro_sur_ecran_ecrase

; TEXTE3
; copie le texte 3

	lea		texte_intro1+(320*100),a0
	lea		ecran_intro+(136*320),a1
	move.l	#(320*50)/2,d1
	jsr		copy_texte_intro_sur_ecran

; FADE IN sur le 255
; Bits [0-5] are green, bits [6-10] are blue and
; bits [11-15] are red.
FADE_IN_TEXTE3:
	lea		CLUT+(255*2),a1
	moveq	#0,d0
	move.w	#31-1,d7
	move.w	#%0000100001000010,d3
boucle2a2a3:
	move.w		#4-1,d6
	
boucle1a2a3:
	move.l		vbl_counter,d1
wait_1_VBLa2a3:
	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBLa2a3
	
	dbf			d6,boucle1a2a3
	
	add.w		d3,d0
	move.w		d0,(a1)
	;move.w		$FFFF,(a1)
	dbf			d7,boucle2a2a3
	move.w		d0,d4

; wait 10 secondes
	move.l		#(50*10),d0
wait_N_VBL2a3:
	move.l		vbl_counter,d1
wait_1_VBL2a3:
	move.l		LSP_DSP_buttonB_pressed,d3
	cmp.l		#0,d3
	beq.s		oka116
	jmp			retour_introduction
oka116:

	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBL2a3
	dbf			d0,wait_N_VBL2a3

; FADE OUT sur le 255
; Bits [0-5] are green, bits [6-10] are blue and
; bits [11-15] are red.
FADE_OUT_TEXTE2a3:
	lea		CLUT+(255*2),a1
	move.w	d4,d0					; precedente couleur
	move.w	#31-1,d7
	move.w	#%0000100001000010,d3
boucle22a3:
	move.w		#4-1,d6
	
boucle12a3:
	move.l		vbl_counter,d1
wait_1_VBL2a1a3:
	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBL2a1a3
	
	dbf			d6,boucle12a3
	
	sub.w		d3,d0
	move.w		d0,(a1)
	;move.w		$FFFF,(a1)
	dbf			d7,boucle22a3

	move.w		#0,(a1)

; ecrase le bas de l'image avec l'originale
	lea		image_debut+512+(136*320),a0
	lea		ecran_intro+(136*320),a1
	move.l	#(320*50)/2,d1
	jsr		copy_texte_intro_sur_ecran_ecrase


retour_introduction:

	rts

;-----------------------------------------------------------------------------------
; convertir le texte du scrolling, -32 puis 4 bits=ligne / 4bits = colonne
convert_texte_scrolling:

		lea		texte_scrolling,a0
		lea		fin_texte_scrolling,a1

boucle_convert_scrolling:
		moveq	#0,d0
		move.b	(a0),d0

		cmp.w	#GPU_scrolling_code_de_controle_code_minimal,d0
		bge.s	.ok2
		cmp.w	#97,d0
		blt.s	.ok
		sub.w	#97-65,d0
.ok:
		sub.l	#32,d0				; caler sur les fontes

		move.l	d0,d1
		divu	#10,d0
		moveq	#0,d2
		move.w	d0,d2				; d2=ligne
		move.l	d2,d0
		lsl.l	#4,d2				; ligne en haut sur 4 bits
		mulu	#10,d0
		sub.l	d0,d1
		or.l	d2,d1
		move.b	d1,(a0)
.ok2:
		addq.l	#1,a0

		cmp.l	a0,a1
		bne.s	boucle_convert_scrolling
fin_convert_scrolling:
		rts
		
;-----------------------------------------------------------------------------------
; preparation de l'Objects list
;   Condition codes (CC):
;
;       Values     Comparison/Branch
;     --------------------------------------------------
;        000       Branch on equal            (VCnt==VC)
;        001       Branch on less than        (VCnt>VC)
;        010       Branch on greater than     (VCnt<VC)
;        011       Branch if OP flag is set
; input A6=adresse object list 
preparation_OL:
	move.l	a6,a1
	;lea		ob_list_1,a1

; insertion de Branch if YPOS < 0 a X+16

	move.l		#$00000003,d0					; branch
	or.l		#%0100000000000000,d0			; <
	move.l		#premiere_ligne,d3
	add.l		d3,d3							; *2 : half line
	lsl.l		#3,d3
	or.l		d3,d0							; Ymax	

	move.l		a1,d1
	add.l		#16,d1
	lsr.l		#3,d1							
	move.l		d1,d2
	lsl.l		#8,d1							; <<24 : 8 bits
	lsl.l		#8,d1
	lsl.l		#8,d1
	or.l		d1,d0
	lsr.l		#8,d2
	move.l		d2,(a1)+
	move.l		d0,(a1)+

; insertion de Branch if YPOS < Ymax à X+16
	move.l		#$00000003,d0					; branch
	or.l		#%0100000000000000,d0			; <
	move.l		#derniere_ligne,d3
	add.l		d3,d3							; *2 : half line
	lsl.l		#3,d3
	or.l		d3,d0							; Ymax	
	move.l		a1,d1
	add.l		#16,d1
	lsr.l		#3,d1							
	move.l		d1,d2
	lsl.l		#8,d1							; <<24 : 8 bits
	lsl.l		#8,d1
	lsl.l		#8,d1
	or.l		d1,d0
	lsr.l		#8,d2
	move.l		d2,(a1)+
	move.l		d0,(a1)+

; insertion de STOP
	moveq		#0,d0
	move.l		d0,(a1)+
	move.l		#4,d0
	move.l		d0,(a1)+


	move.l		a6,a2
	add.l		#512,a2
	;lea			ob_list_1+512,a2				; bloc0_8

; insertion de Branch if YPOS <8 bloc0_8
	move.l		#$00000003,d0					; branch
	or.l		#%0100000000000000,d0			; <

	move.l		#premiere_ligne,d3
	add.l		#8,d3
	add.l		d3,d3							; *2 : half line
	lsl.l		#3,d3
	or.l		d3,d0							; Ymax	
	move.l		a2,d1
	lsr.l		#3,d1							
	move.l		d1,d2
	lsl.l		#8,d1							; <<24 : 8 bits
	lsl.l		#8,d1
	lsl.l		#8,d1
	or.l		d1,d0
	lsr.l		#8,d2
	move.l		d2,(a1)+
	move.l		d0,(a1)+

; boucle remplissage de 24 a nb_lignes
; a1=dest
; a2=bloc, à incrementer de 1664
; d3=VC, à incrementer de 8

; d3=premiere ligne de test
	move.l		#36,d3
	move.l		a6,a2
	add.l		#512,a2
;	lea			ob_list_1+512,a2
	move.l		#29-1,d7				; 30-1
	
boucle_branch_OL:
	move.l		#$00000003,d0					; branch
	or.l		#%0100000000000000,d0			; <
	move.l		d3,d4
	add.l		d4,d4							; *2 : half line
	lsl.l		#3,d4
	or.l		d4,d0							; VC
	move.l		a2,d1
	lsr.l		#3,d1							
	move.l		d1,d2
	lsl.l		#8,d1							; <<24 : 8 bits
	lsl.l		#8,d1
	lsl.l		#8,d1
	or.l		d1,d0
	lsr.l		#8,d2
	move.l		d2,(a1)+
	move.l		d0,(a1)+

; insertion d'1 STOP au point de saut
	; moveq		#0,d0
	move.l		d0,(a2)
	move.l		#4,d0
	move.l		d0,4(a2)

; insertion d'1 STOP au point de saut
	moveq		#0,d0
	move.l		d0,(a2)
	move.l		#4,d0
	move.l		d0,4(a2)


	add.l		#1664,a2
	add.l		#8,d3
	dbf			d7,boucle_branch_OL

	.if		GPU_OL_interrupt=1
; insertion GPU object
	moveq		#0,d0
	move.l		d0,(a1)+
	move.l		#$3FFA,d0				; $3FFA
	move.l		d0,(a1)+
	.endif
	
; insertion de STOP
	moveq		#0,d0
	move.l		d0,(a1)+
	move.l		#4,d0
	move.l		d0,(a1)+

; insertion de STOP
	moveq		#0,d0
	move.l		d0,(a1)+
	move.l		#4,d0
	move.l		d0,(a1)+
; insertion de STOP
	moveq		#0,d0
	move.l		d0,(a1)+
	move.l		#4,d0
	move.l		d0,(a1)+

; insertion de STOP
	moveq		#0,d0
	move.l		d0,(a1)+
	move.l		#4,d0
	move.l		d0,(a1)+

	.if		1=0

 ;63       56        48        40       32        24       16       8        0
 ; +--------^---------^-----+------------^--------+--------^--+-----^----+---+
 ; |        data-address    |     Link-address    |   Height  |   YPos   |000|
 ; +------------------------+---------------------+-----------+----------+---+
 ;     63 .............43        42.........24      23....14    13....3   2.0
 ;          21 bits                 19 bits        10 bits     11 bits  3 bits
 ;                                   (11.8)

; insere un sprite en Y=96
; YPOS, HEIGHT, LINK, DATA, XPOS,DEPTH,PITCH=1,DWIDTH=2,IWIDTH=2,TRANS
	move.l		#1664,d0
	mulu		#7,d0					; 12 pour 96
	;lea			ob_list_1+512,a2
	move.l		a6,a2
	add.l		#512,a2

	add.l		d0,a2

; A2=dest dans l'OL
	move.l		#$00020000,d0		; heigth +00
	move.l		#bob+512,d1			; debut dessin
	lsr.l		#3,d1
	lsl.l		#8,d1
	lsl.l		#3,d1			; pos 11=43
	lea			16(a2),a3		; LINK / 19 bits
	move.l		a3,d3
	lsr.l		#3,d3
	move.l		d3,d4
; sur le 2eme .LONG, 0 à 10 bits = LINK
	lsr.l		#8,d3
	or.l		d3,d1
	move.l		d1,(a2)+
	and.l		#$FF,d4
	swap		d4			; 8 bits du bas dans 23-16
	lsl.l		#8,d4
	or.l		d4,d0
; YPOS
	move.l		#56,d4		; YPOS
	add			d4,d4		; *2 pour half line
	lsl.l		#3,d4
	or.l		d4,d0
	move.l		d0,(a2)+


; 63       56        48        40       32       24       16        8        0
;  +--------^-+------+^----+----^--+-----^---+----^----+---+---+----^--------+
;  | unused   |1stpix| flag|  idx  | iwidth  | dwidth  | p | d |   x-pos     |
;  +----------+------+-----+-------+---------+---------+---+---+-------------+
;    63...55   54..49 48.45  44.38   37..28    27..18 17.15 14.12  11.....0
;      9bit      6bit  4bit   7bit    10bit    10bit   3bit 3bit    12bit
;                                    (6.4)

	move.l		#$2008B060,d0				; XPOS=96 / depth = 3 / Pitch=1 / DWIDTH=2 / IWIDTH=2 : $60+3000+8000+80000+20000000
	move.l		#$8000,d1					; Trans=1
	move.l		d1,(a2)+
	move.l		d0,(a2)+
	.endif

; insertion de STOP
	moveq		#0,d0
	move.l		d0,(a2)+
	move.l		#4,d0
	move.l		d0,(a2)+


		.if		1=0
; copie liste 1 dans liste 2
				move.l	#ob_list_2,A1_BASE			; = DEST
				move.l	#$0,A1_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A1_FLAGS
				move.l	#ob_list_1,A2_BASE			; = source
				move.l	#$0,A2_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A2_FLAGS
				move.w	#1,d0
				swap	d0
				move.l	#64000/4,d1
				move.w	d1,d0
				move.l	d0,B_COUNT
				move.l	#LFU_REPLACE|SRCEN,B_CMD
;wait for blitter
.wait_blitter:
		move.l		B_CMD,d0
		btst		#0,d0
		beq.s		.wait_blitter
		
		.endif


	rts
;-----------------------------------------------------------------------------------
;--------------------------
; VBL

VBL:
                movem.l d0-d7/a0-a6,-(a7)
	
				;move.l			GPU_pointeur_object_list_a_modifier,d0
				;move.l			GPU_pointeur_object_list_a_afficher,GPU_pointeur_object_list_a_modifier
				;move.l			d0,GPU_pointeur_object_list_a_afficher

				;swap	d0
				;move.l	d0,OLP

	
				;lea		ob_list_1,a6
				;bsr		preparation_OL
	
                ;jsr     copy_olist              	; use Blitter to update active list from shadow

				;addq.w	#1,BG

				; is alive ?
				;move.l		vbl_counter,d0
				;move.w		d0,BG
				

                addq.l	#1,vbl_counter

                move.w  #$101,INT1              	; Signal we're done
				move.w  #$0,INT2
.exit:
                movem.l (a7)+,d0-d7/a0-a6
                rte


VBL_intro:
                movem.l d0-d7/a0-a6,-(a7)
	
				;move.l			GPU_pointeur_object_list_a_modifier,d0
				;move.l			GPU_pointeur_object_list_a_afficher,GPU_pointeur_object_list_a_modifier
				;move.l			d0,GPU_pointeur_object_list_a_afficher

				;swap	d0
				;move.l	d0,OLP

	
				;lea		ob_list_1,a6
				;bsr		preparation_OL
	
                jsr     copy_olist_intro              	; use Blitter to update active list from shadow

				;addq.w	#1,BG

				; is alive ?
				;move.l		vbl_counter,d0
				;move.w		d0,BG
				

                addq.l	#1,vbl_counter

                move.w  #$101,INT1              	; Signal we're done
				move.w  #$0,INT2
.exit:
                movem.l (a7)+,d0-d7/a0-a6
                rte



;----------------------------------
; recopie les couleurs de A0 dans CLUT
copie_couleurs_dans_CLUT:

	lea		CLUT,a1
	move.l	#256-1,d7
	
.copie_couleurs:
	move.w	(a0)+,(a1)+
	dbf		d7,.copie_couleurs
	rts

;----------------------------------
; recopie les couleurs de A0 dans CLUT avec FADE IN
copie_couleurs_dans_CLUT_FADEIN:

	lea		CLUT,a1
	move.l	#20-1,d7
	
	
copie_couleurs_FADEIN:
	move.w	(a0)+,(a1)+
	moveq	#2,d6
waitVBLcopie_couleurs_FADEIN:
	move.l		vbl_counter,d1
wait_1_VBLa1clut:

	move.l		vbl_counter,d2
	cmp.l		d1,d2
	beq.s		wait_1_VBLa1clut
	dbf			d6,waitVBLcopie_couleurs_FADEIN

	dbf		d7,copie_couleurs_FADEIN
	rts


;----------------------------------
; recopie l'object list dans la courante

				.if		1=0
copy_olist:
				move.l	#ob_list_1,A1_BASE			; = DEST
				move.l	#$0,A1_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A1_FLAGS
				move.l	#ob_list_2,A2_BASE			; = source
				move.l	#$0,A2_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A2_FLAGS
				move.w	#1,d0
				swap	d0
				move.l	#fin_ob_liste_originale-ob_liste_originale,d1
				move.w	d1,d0
				move.l	d0,B_COUNT
				move.l	#LFU_REPLACE|SRCEN,B_CMD
				rts
				.endif

copy_olist_intro:
				move.l	#ob_list_1,A1_BASE			; = DEST
				move.l	#$0,A1_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A1_FLAGS
				move.l	#ob_liste_originale,A2_BASE			; = source
				move.l	#$0,A2_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A2_FLAGS
				move.w	#1,d0
				swap	d0
				move.l	#fin_ob_liste_originale-ob_liste_originale,d1
				move.w	d1,d0
				move.l	d0,B_COUNT
				move.l	#LFU_REPLACE|SRCEN,B_CMD
				rts

copy_image_sur_ecran_intro:
				move.l	#ecran_intro,A1_BASE			; = DEST
				move.l	#$0,A1_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A1_FLAGS
				move.l	#image_debut+512,A2_BASE			; = source
				move.l	#$0,A2_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A2_FLAGS
				move.w	#1,d0
				swap	d0
				move.l	#320*200,d1
				move.w	d1,d0
				move.l	d0,B_COUNT
				move.l	#LFU_REPLACE|SRCEN,B_CMD
				rts

copy_texte_intro_sur_ecran:
; A0=source
; A1=dest
; D1=taille
				move.l	A1,A1_BASE			; = DEST
				move.l	#$0,A1_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A1_FLAGS
				move.l	A0,A2_BASE			; = source
				move.l	#$0,A2_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A2_FLAGS
				move.w	#1,d0
				swap	d0
				;move.l	#320*200,d1
				move.w	d1,d0
				move.l	d0,B_COUNT
				move.l	#LFU_SORD|SRCEN|DSTEN,B_CMD
				rts

copy_texte_intro_sur_ecran_ecrase:
; A0=source
; A1=dest
; D1=taille
				move.l	A1,A1_BASE			; = DEST
				move.l	#$0,A1_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A1_FLAGS
				move.l	A0,A2_BASE			; = source
				move.l	#$0,A2_PIXEL
				move.l	#PIXEL16|XADDPHR|PITCH1,A2_FLAGS
				move.w	#1,d0
				swap	d0
				;move.l	#320*200,d1
				move.w	d1,d0
				move.l	d0,B_COUNT
				move.l	#LFU_REPLACE|SRCEN,B_CMD
				rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Procedure: InitVideo (same as in vidinit.s)
;;            Build values for hdb, hde, vdb, and vde and store them.
;;

InitVideo2:
                movem.l d0-d6,-(sp)

				
				move.w	#-1,ntsc_flag
				move.l	#50,_50ou60hertz
	
				move.w  CONFIG,d0                ; Also is joystick register
                andi.w  #VIDTYPE,d0              ; 0 = PAL, 1 = NTSC
                beq     .palvals
				move.w	#1,ntsc_flag
				move.l	#60,_50ou60hertz
	

.ntscvals:		move.w  #NTSC_HMID,d2
                move.w  #NTSC_WIDTH,d0

                move.w  #NTSC_VMID,d6
                move.w  #NTSC_HEIGHT,d4
				
                bra     calc_vals
.palvals:
				move.w #PAL_HMID,d2
				move.w #PAL_WIDTH,d0

				move.w #PAL_VMID,d6				
				move.w #PAL_HEIGHT,d4

				
calc_vals:		
                move.w  d0,width
                move.w  d4,height
                move.w  d0,d1
                asr     #1,d1                   ; Width/2
                sub.w   d1,d2                   ; Mid - Width/2
                add.w   #4,d2                   ; (Mid - Width/2)+4
                sub.w   #1,d1                   ; Width/2 - 1
                ori.w   #$400,d1                ; (Width/2 - 1)|$400
                move.w  d1,a_hde
                move.w  d1,HDE
                move.w  d2,a_hdb
                move.w  d2,HDB1
                move.w  d2,HDB2
                move.w  d6,d5
                sub.w   d4,d5
                add.w   #16,d5
                move.w  d5,a_vdb
                add.w   d4,d6
                move.w  d6,a_vde
			
			    move.w  a_vdb,VDB
				move.w  a_vde,VDE    
				
				
				move.l  #0,BORD1                ; Black border
                move.w  #0,BG                   ; Init line buffer to black
                movem.l (sp)+,d0-d6
                rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Procedure: InitVideo 
;;

InitVideo:
	movem.l d0-d6,-(sp)
			
	move.w	#-1,ntsc_flag
	move.l	#50,_50ou60hertz

	lea		HDE,a1
	lea		HDB1,a2
	lea		HDB2,a3
	lea		VDB,a4
	lea		VDE,a5
	lea		VI,a6

	
	move.w  CONFIG,d0                ; Also is joystick register
	andi.w  #VIDTYPE,d0              ; 0 = PAL, 1 = NTSC
	beq.s    .palvals
	
; NTSC
.ntscvals:
	moveq	#0,d0
	move.w		#1,ntsc_flag
	move.l		#60,_50ou60hertz

	move.w		#$6BF,(a1)				;	67a									6BF				HDE
	move.w		#$71,(a2)				; B7			; EDZ:71				7B
	move.w		#$71,(a3)				; B7			; EDZ:71				7B
	move.w		#$28,(a4)
	move.w		#$20A,(a5)
	move.w		#$20A-16+1,d0
	or.w		#1,d0
	move.w		d0,(a6)
			
	bra.s		.sortie
; PAL
.palvals:
	moveq	#0,d0
	move.w		#$6B1,(a1)			; 678				; EDZ : 678				6B1
	move.w		#$71,(a2)			; CB				; EDZ : 71				103
	move.w		#$71,(a3)			; CB				; EDZ : 71				103
	move.w		#$40,(a4)
	move.w		#$242,(a5)
	move.w		#$242-16+1,d0
	or.w		#1,d0
	move.w		d0,(a6)
			
.sortie:		
	move.l  #0,BORD1                ; Black border
	;move.w  #0,BG                   ; Init line buffer to black
	movem.l (sp)+,d0-d6
	rts


	.phrase
GPU_debut:

	.gpu
	.org	G_RAM
GPU_base_memoire:

; CPU interrupt
	.rept	8
		nop
	.endr
; DSP interrupt, the interrupt output from Jerry
	.rept	8
		nop
	.endr
; Timing generator
	.rept	8
		nop
	.endr
; Object Processor
	jump	(R27)
	.rept	7
		nop
	.endr
; Blitter
	.rept	8
		nop
	.endr



GPU_init:
	movei	#GPU_ISP+(GPU_STACK_SIZE*4),r31			; init isp
	moveq	#0,r1
	moveta	r31,r31									; ISP (bank 0)
	nop
	movei	#GPU_USP+(GPU_STACK_SIZE*4),r31			; init usp


		.if		GPU_OL_interrupt=1
	movei	#$120771,R0
	moveta	R0,R26							; compteur
	movei	#interrupt_OP,R1
	moveta	R1,R27
	movei	#OBF,R0
	moveta	R0,R22
	movei	#G_FLAGS,R1											; GPU flags
	moveta	R1,R28


	movei	#G_FLAGS,r30
	movei	#G_OPENA|REGPAGE,r29			; object list interrupt
	nop
	nop
	store	r29,(r30)
	nop
	nop
	.endif

; swap les pointeurs d'OL
		movei	#GPU_pointeur_object_list_a_modifier,R0
		movei	#GPU_pointeur_object_list_a_afficher,R1
		load	(R0),R2
		load	(R1),R3
		store	R2,(R1)
		movei	#OLP,R4
		rorq	#16,R2
		store	R3,(R0)

		store	R2,(R4)

		;movei	#BG,R26
		;movei	#$770,R25				; bleu clair
		;storew	R25,(R26)
		
; -------------------------------------------
; -------------------------------------------
; ------------- main loop -----------------------
; -------------------------------------------
; -------------------------------------------
GPU_loop:
		;movei	#BG,R26
		;movei	#$770,R25				; bleu clair
		;storew	R25,(R26)



; synchro avec l'interrupt object list
		.if		GPU_OL_interrupt=1
		movefa	R26,R26
		
GPU_boucle_wait_vsync:
		movefa	R26,R25
		cmp		R25,R26
		jr		eq,GPU_boucle_wait_vsync
		nop
		.endif
		
; synrcho avec l'intterupt VI
		.if		GPU_OL_interrupt=0
		movei	#vbl_counter,R26
		load	(R26),R25
		or		R25,R25
GPU_boucle_wait_vsync:
		load	(R26),R24
		or		R24,R24
		nop
		nop
		nop
		cmp		R25,R24
		jr		eq,GPU_boucle_wait_vsync
		nop
		.endif

		;movei	#BG,R26
		;movei	#$700,R25				; bleu
		;storew	R25,(R26)



; swap les pointeurs d'OL
		movei	#GPU_pointeur_object_list_a_modifier,R0
		movei	#GPU_pointeur_object_list_a_afficher,R1
		load	(R0),R2
		load	(R1),R3
		store	R2,(R1)
		movei	#OLP,R4
		moveta	R3,R3
		rorq	#16,R2
		store	R3,(R0)

		store	R2,(R4)



; -------------------------------------------
; remplit liste_points_calcules : X.w Y.w
; en fonction de la formule, calcule les X et Y
	movei	#GPU_position_dans_la_colonne_scrolling,R18
	load	(R18),R10		; x en cours : de 0 a 12 : 0 4 8 12
	movei	#liste_points_calcules,R23
	
	moveq	#nb_colonnes_de_sprites_a_afficher,R3			; X max
	moveq	#nb_lignes_de_sprites_a_afficher,R13			; Y max
	movei	#178,R14		; Y de base=178

	moveq	#16,R11			; increment X
	shlq	#16,R11			; X.w 0.w

	movei	#GPU_pointeur_forme_en_cours,R20
	movei	#GPU_pointeur_forme_fin,R21
	movei	#GPU_pointeur_forme_debut,R22
	load	(R20),R20
	load	(R21),R21
	load	(R22),R22


	movei	#GPU_boucle_remplissage_points_calcules_X,R25
	;movei	#GPU_boucle_remplissage_points_calcules_Y,R26

; fabrique le X.w Y.w
	shlq	#16,R10
	add		R14,R10
	
; R10=X.w Y.w
; R11=+16.w <<16
; 
GPU_boucle_remplissage_points_calcules_X:

	move	R13,R1				; nb lignes a afficher

GPU_boucle_remplissage_points_calcules_Y:
	load	(R20),R0			; increment Y
	add		R0,R10				; Y+increment
	addq	#4,R20

	store	R10,(R23)
	addq	#4,R23

	
	subq	#1,R1
	jr		ne,GPU_boucle_remplissage_points_calcules_Y
	nop

; incrementer le X
	add		R11,R10

	load	(R20),R0			; increment Y final
	add		R0,R10				; Y+increment
	addq	#4,R20

	cmp		R20,R21
	jr		ne,.ok
	nop
	move	R22,R20
.ok:

	subq	#1,R3
	jump	ne,(R25)
	nop

	
	
	

	


GPU_apres_routine_de_forme_de_scrolling:
;alt-R3 = pointeur sur object list
;----------------------------------------------
; calcul les points a afficher

; gestion du scrolling


		;movei	#GPU_position_dans_la_colonne_scrolling,R16
		movei	#GPU_pointeur_scrolling,R23
		;load	(R16),R16					; decalage X en cours
		movei	#fonte,R10
		;movei	#-16,R17
		load	(R23),R23
		;sha		R17,R16				; decalage X=X.w 0.w

		movei	#GPU_scrolling_code_de_controle_code_fin_de_texte+1,R12
		movei	#tailles_des_caracteres,R14

GPU_code_remonte:
		loadb	(R23),R1			; R1 = lettre en cours

		cmp		R12,R1
		jr		mi,GPU_pas_code_de_controle
		nop
		addq	#1,R23
		jr		GPU_code_remonte
		nop
		;moveq	#0,R1				; on remplace par un espace
GPU_pas_code_de_controle:
		
		move	R14,R21				; tailles_des_caracteres
		add		R1,R21				; + caractere
		loadb	(R21),R21			; R21 = taille du caractere

		move	R1,R2
		shrq	#4,R1				; R1=ligne ; 4 bits
		shlq	#28,R2
		movei	#12*10*17,R3		; taille d'une ligne de lettres
		shrq	#28,R2				; ne garde que 4 bits
		mult	R3,R1				; ligne lettre * taille d'une ligne
		moveq	#12,R4
		movei	#nb_colonnes_de_sprites_a_afficher,R24
		mult	R4,R2
		movei	#liste_points_sprites,R22
		add		R2,R1				; position dans la ligne

		movei	#GPU_scrolling_code_de_controle_code_fin_de_texte,R29

		movei	#GPU_position_dans_la_lettre_scrolling,R15
		move	R10,R11
		load	(R15),R15
		add		R1,R11				; R11 = pointeur sur la lettre en cours
		;movei	#-16,R17
		add		R15,R11				; + position actuelle dans la lettre

		movei	#liste_points_calcules,R20		; valeurs calculees
		move	R11,R27

		movei	#GPU_boucle_ligne_lettre,R26
		movei	#120,R9				; largeur en octet d'une ligne de pixel dans la fonte
		movei	#GPU_boucle_colonne_lettre,R25
		movei	#GPU_pas_fin_de_lettre,R28



GPU_boucle_ligne_lettre:
		move	R27,R11				; remet le pointeur sur le bitmap de la fonte, en haut de la lettre

; R10=pointeur sur fonte:
; R11=pointeur sur la colonne en cours
; R12=GPU_scrolling_code_de_controle_code_fin_de_texte+1
; R13=
; R14=tailles_des_caracteres
; R15=position dans la lettre entre 0 et 11
;// R16=X en cours, signé
; R17=-16
; R18=nb lignes dans une colonne de pixels

; R20=liste_points_calcules
; R21=largeur de la lettre
; R22=liste_points_sprites = DEST X.w Y.w
; R23=GPU_pointeur_scrolling
; R24=nb_colonnes_de_sprites_a_afficher
; R25=GPU_boucle_colonne_lettre
; R26=GPU_boucle_ligne_lettre
; R27=pointeur sur la colonne en cours / debut de la colonne
; R28=GPU_pas_fin_de_lettre
; R29=GPU_scrolling_code_de_controle_code_fin_de_texte / code de controle de FIN
; R30=


		moveq	#nb_lignes_de_sprites_a_afficher,R18

GPU_boucle_colonne_lettre:
		load	(R20),R4			;R4=X.w Y.w
		addq	#4,R20

; traitement d'une colonne
		loadb	(R11),R0			; R0= 0 ou 1 / suivant fonte
		cmpq	#0,R0
		jr		eq,GPU_le_pixel_est_vide
		;add		R16,R4				; X.w Y.w + decalage X.w 0.w
; il faut stocker X.w Y.w dans R22 et incrementer R22
		store	R4,(R22)
		addq	#4,R22

GPU_le_pixel_est_vide:
		add		R9,R11				; ligne suivante de la meme colonne
		
		subq	#1,R18
		jump	ne,(R25)			; boucle pour faire une colonne de haut en bas
		nop
		
; boucler sur colonne suivante
;- x=x+16
;- numero de colonne en cours +1
;- si numero de colonne en cours =11 => 
;		- nouvelle lettre
;			- 
;- nb colonnes à afficher = nb colonnes à afficher - 1
		
		addq	#1,R27				; pointeur sur la colonne en cours + 1 dans la fonte
		
		addq	#1,R15				; position dans la lettre entre 0 et 11 sauf i et 1
		cmp		R21,R15
		jump	mi,(R28)
		nop
; il faut passer à la lettre suivante

		addq	#1,R23				; GPU_pointeur_scrolling + 1
		moveq	#0,R15				; position dans la lettre =0

GPU_code_remonte2:
		loadb	(R23),R1			; R1 = lettre en cours

		cmp		R12,R1
		jr		mi,GPU_pas_code_de_controle2
		nop
		addq	#1,R23
		jr		GPU_code_remonte2
		nop
		;moveq	#0,R1				; on remplace par un espace
GPU_pas_code_de_controle2:

		cmp		R29,R1				; fin du texte ?
		jr		ne,GPU_pas_fin_du_texte_scrolling
		nop
		movei	#texte_scrolling,R23
		loadb	(R23),R1			; R1 = lettre en cours
		
		
GPU_pas_fin_du_texte_scrolling:
		move	R14,R21				; tailles_des_caracteres
		add		R1,R21				; + caractere
		loadb	(R21),R21			; R21 = taille du caractere



;R1=lettre en cours : 4bits=ligne/4bits=colonne
		move	R1,R2
		shrq	#4,R1				; R1=ligne, 4 bits
		shlq	#28,R2
		movei	#12*10*17,R3		; taille d'une ligne de lettres
		shrq	#28,R2				; ne garde que 4 bits
		mult	R3,R1				; ligne lettre * taille d'une ligne
		moveq	#12,R4
		mult	R4,R2
		or		R2,R2
		add		R2,R1				; position dans la ligne

		move	R10,R27				; R10= pointeur sur debut fonte
		add		R1,R27				; R27 = pointeur sur la lettre en cours
		add		R15,R27

GPU_pas_fin_de_lettre:
		subq	#1,R24
		jump	ne,(R26)
		
		nop

; stockage du pointeur sur la fin de la liste de sprites
		movei	#GPU_pointeur_fin_liste_points_sprites,R0
		store	R22,(R0)


;----------------------------------------------
; creation table pointeurs sur blocs, modifiée à chaque sprite ensuite

		movei	#GPU_pointeurs_blocs_OL,R10
		movei	#$680,R12						; ecart entre les blocs
		move	R10,R14
		movei	#512,R2
		movefa	R3,R3					; R3=OL en cours
		moveq	#29,R0					; nb de blocs de sprites
		add		R2,R3
		moveta	R3,R3					; stocke OL+512

GPU_boucle_remplit_table_adresses_blocs_OL:
		store	R3,(R10)
		add		R12,R3
		subq	#1,R0
		jr		ne,GPU_boucle_remplit_table_adresses_blocs_OL
		addqt	#4,R10
		
		



;----------------------------------------------
; relecture des sprites, insertion dans l'OL

		movei	#liste_points_sprites,R20
		moveq	#premiere_ligne,R10							; borne basse = premiere_ligne
		;movei	#$680,R12						; ecart entre les blocs
		movei	#$FFFF,R13
		movei	#GPU_boucle_creer_OL_BITMAP,R25

		movei	#GPU_aucun_sprite,R26
		cmp		R20,R22
		jump	eq,(R26)
		nop

		movei	#GPU_next_sprite_OL,R27
		movei	#premiere_ligne,R16
		movei	#derniere_ligne-11,R17


GPU_boucle_creer_OL_BITMAP:
; R10=borne basse / ligne minimale
; R14=GPU_pointeurs_blocs_OL
; R12=écart entre les blocs de sprites=$680
; R13=$FFFF / masque 16 bits du bas
; R16 = borne basse = premiere_ligne
; R17 = derniere ligne = derniere_ligne

; R20=liste_points_sprites
; R22=fin de liste_points_sprites
; R25=GPU_boucle_creer_OL_BITMAP


		load	(R20),R0						; R0=X.W / Y.W
		move	R0,R9
		addq	#4,R20							; XY suivant
		and		R13,R9							; R9=Y.w

		cmp		R16,R9							; borne basse
		jump	mi,(R27)
		nop
		cmp		R17,R9
		jump	pl,(R27)
		
		move	R9,R2
		sub		R10,R2							; -20
		shrq	#3,R2							; /8
		shlq	#2,R2							; *4 pour lire .L
		load	(R14+R2),R24						; R3=pointeur sur OL pour cette Y = DEST
		
		
; crée un objet dans l'OL pointée par R24
;
; input : X / Y / pointeur sur data sprite /
; calculés : LINK / 
; toujours identique : HEIGHT / DEPTH / PITCH / DWIDTH / IWIDTH / TRANS

 ;63       56        48        40       32        24       16       8        0
 ; +--------^---------^-----+------------^--------+--------^--+-----^----+---+
 ; |        data-address    |     Link-address    |   Height  |   YPos   |000|
 ; +------------------------+---------------------+-----------+----------+---+
 ;     63 .............43        42.........24      23....14    13....3   2.0
 ;          21 bits                 19 bits        10 bits     11 bits  3 bits
 ;                                   (11.8)

; 63       56        48        40       32       24       16        8        0
;  +--------^-+------+^----+----^--+-----^---+----^----+---+---+----^--------+
;  | unused   |1stpix| flag|  idx  | iwidth  | dwidth  | p | d |   x-pos     |
;  +----------+------+-----+-------+---------+---------+---+---+-------------+
;    63...55   54..49 48.45  44.38   37..28    27..18 17.15 14.12  11.....0
;      9bit      6bit  4bit   7bit    10bit    10bit   3bit 3bit    12bit
;                                    (6.4)
		sharq	#16,R0							; R0=X.w
; R0=X
; R1=Y
; R24=pointeur OL actuel
		;move	R1,R9			; R9=YPOS

		movei	#GPU_pointeur_sur_sprite_en_cours,R7
		move	R24,R5
		load	(R7),R7
		;movei	#bob+512,R7		; DATA
		addq	#16,R5			; R5=LINK
		movei	#$00020000,R6	; R6 = HEIGHT=8 + 000
		
		store	R5,(R14+R2)		; update pointeur en cours sur le bloc de l'object list
		
		sharq	#3,R7			; DATA sur phrase
		shlq	#11,R7			; decalage DATA
		sharq	#3,R5			; LINK sur phrase
		move	R5,R8			; R8=LINK pour 2eme long mot
		
		sharq	#8,R5			; LINK pour le 1er mot
		or		R5,R7			; data+LINK pour 1er mot de la 1ere phrase
		store	R7,(R24)
		shlq	#24,R8			;R8=LINK pour 2eme mot
		addq	#4,R24
		or		R8,R6			; LINK + HEIGHT + 000
		shlq	#3+1,R9			; ( YPOS * 2 (half line)  ) << 3
		or		R9,R6			; LINK + HEIGHT + YPOS + 000
		store	R6,(R24)			; 2eme mot 1ere phrase
		movei	#$2008B000,R1	; depth = 3 / Pitch=1 / DWIDTH=2 / IWIDTH=2 
		addq	#4,R24
		movei	#$8000,R3		; TRANS=1
		or		R0,R1			; + XPOS
		store	R3,(R24)
		addq	#4,R24
		store	R1,(R24)
		addq	#4,R24

GPU_next_sprite_OL:
		cmp		R22,R20
		jump	ne,(R25)
		nop

GPU_aucun_sprite:
;----------------------------------------------
; il faut ajouter un branch a la fin de chaque bloc

		movefa	R3,R23			; pointeur premier bloc
		movei	#GPU_boucle_creer_branch_fin_de_bloc,R25
		moveq	#27,R11			; YPOS pour le test
		moveq	#29,R10			; R10=nb de blocs de sprites
		moveq	#0,R13			; STOP : 0
		moveq	#4,R16			; STOP : 4

GPU_boucle_creer_branch_fin_de_bloc:
		add		R12,R23			; adresse du bloc de sprite suivant=LINK

		load	(R14),R24		; pointeur sur fin du bloc
		addq	#4,R14
; fabrication branch
; TYPE=3 / YPOS=R11 / CC=2/ LINK=R23
		move	R11,R9			; R9=YPOS
		movei	#$8003,R0		; TYPE=3 + CC=2
		shlq	#3+1,R9			; ( YPOS * 2 (half line)  ) << 3
		or		R9,R0
		move	R23,R2
		shrq	#3,R2			; LINK sur phrase
		move	R2,R3

		shlq	#24,R2			; on ne garde que 8 bits du bas, placé de 24 a 31
		or		R2,R0
		
		shrq	#8,R3			; on vire les 8 bits du bas

; insert le branch		
		store	R3,(R24)
		addq	#4,R24
		store	R0,(R24)
		addq	#4,R24

; insert un stop
		store	R13,(R24)		; 0000
		addq	#4,R24
		store	R16,(R24)		; 0004
		addq	#4,R24
		
; increment YPOS
		addq	#8,R11			; YPOS + 8 
		
		subq	#1,R10
		jump	ne,(R25)
		nop
		
;----------------------------------------------
; avancer le scrolling

		movei	#tailles_des_caracteres,R14
		movei	#GPU_pointeur_scrolling,R4
		movei	#GPU_taille_caractere_actuel,R15
		load	(R4),R5
		load	(R15),R21

		movei	#GPU_position_dans_la_colonne_scrolling,R10
		;movei	#-16,R1
		load	(R10),R0
		movei	#GPU_avancer_scrolling_pas_fin_de_la_colonne,R25
		movei	#GPU_avancer_scrolling_pas_fin_de_la_lettre,R26
		cmpq	#0,R0
		jump	hi,(R25)
		nop
; fin de la colonne, il faut avancer 
		movei	#GPU_position_dans_la_lettre_scrolling,R11
		moveq	#16,R0
		load	(R11),R1
		addq	#1,R1
; tester 1 / par rapport à 12
		;moveq	#12,R3
		cmp		R21,R1				; compare a taille du caractere actuel
		jump	ne,(R26)
		nop
		moveq	#0,R1
; incrementer GPU_pointeur_scrolling
		movei	#GPU_scrolling_code_de_controle_code_fin_de_texte,R20			; R20=code de FIN
		movei	#GPU_scrolling_code_de_controle_code_0,R12			; code minimal pour changer de sprite
		movei	#GPU_scrolling_code_de_controle_code_forme_0,R13	; code minimal pour changer de forme
	
		movei	#GPU_avance_boucle_lecture_lettre,R26

GPU_avance_boucle_lecture_lettre:
		addq	#1,R5			; avance le pointeur sur le scrolling
; lecture de la nouvelle lettre ou code de controle
		loadb	(R5),r6

; test et gestion changement de motif de sprite
		cmp		R12,R6
		jr		mi,GPU_pas_de_changement_de_sprite
		nop
		sub		R12,R6				; - GPU_scrolling_code_de_controle_code_0
		movei	#bob+512,R3
		shlq	#7,R6				; code sprite *128
		movei	#GPU_pointeur_sur_sprite_en_cours,R7
		add		R6,R3
		store	R3,(R7)
		jump	(R26)	
		nop
		;moveq	#0,R6				; caractere = " "
GPU_pas_de_changement_de_sprite:

; test et gestion changement de forme
		movei	#GPU_pas_de_changement_de_forme,R19
		cmp		R13,R6
		jump	mi,(R19)
		nop
		sub		R13,R6				; - GPU_scrolling_code_de_controle_code_forme_0 = numero de forme
		movei	#table_des_formes,R3		; table des formes
		shlq	#3,R6					; code de forme * 8
		
		movei	#GPU_pointeur_forme_en_cours,R7
		add		R6,R3
		load	(R3),R8				; lire pointeur forme debut
		store	R8,(R7)				; stocke debut
		addq	#4,R3
		addq	#4,R7
		load	(R3),R2				; lire pointeur forme fin
		store	R2,(R7)				; stocke fin
		;addq	#4,R3
		addq	#4,R7

		store	R8,(R7)				; stocke repeat=debut
		jump	(R26)	
		nop
		
		;moveq	#0,R6				; caractere = " "
GPU_pas_de_changement_de_forme:


		
; si R6=R20 => fin de scrolling
		cmp		R20,R6
		jr		ne,GPU_avancer_scrolling_pas_fin_de_scrolling
		nop
		movei	#texte_scrolling,R5
		loadb	(R5),R6
GPU_avancer_scrolling_pas_fin_de_scrolling:

		move	R14,R21				; tailles_des_caracteres
		add		R6,R21				; + caractere
		loadb	(R21),R21			; R21 = taille du caractere
		store	R21,(R15)

		store	R5,(R4)
	
GPU_avancer_scrolling_pas_fin_de_la_lettre:
		store	R1,(R11)
		
GPU_avancer_scrolling_pas_fin_de_la_colonne:
		movei	#GPU_vitesse_scrolling,R1
		load	(R1),R2

		sub		R2,R0
		store	R0,(R10)


; -------------------
; avancer la forme
	movei	#GPU_pointeur_forme_en_cours,R10
	movei	#GPU_pointeur_forme_fin,R21
	movei	#GPU_pointeur_forme_debut,R22
	load	(R10),R20
	movei	#4*17,R11
	load	(R21),R21
	load	(R22),R22
	add		R11,R20
	cmp		R21,R20
	jr		ne,.ok_pas_la_fin_de_la_table
	nop
	move	R22,R20
.ok_pas_la_fin_de_la_table:
	store	R20,(R10)


;----------------------------------------------
; incremente compteur de VBL au GPU
		movei	#vbl_counter_GPU,R0
		load	(R0),R1
		addq	#1,R1
		store	R1,(R0)




; boucle globale/centrale
		movei	#GPU_loop,R20
		jump	(R20)
		nop

;--------------------------------------------------------
;
; interruption object processor
;	- libere l'OP
;	- incremente R26
;
;--------------------------------------------------------
interrupt_OP:
		storew	R0,(r22)

		load     (R28),r29
		addq     #1,r26
		load     (R31),r30
		bclr     #3,r29
		addq     #2,r30
		addq     #4,r31
		bset     #12,r29
		jump     (r30)
		store    r29,(r28)
		
	.phrase

GPU_pointeur_object_list_a_modifier:			dc.l			ob_list_1
GPU_pointeur_object_list_a_afficher:			dc.l			ob_list_2

vbl_counter_GPU:	dc.l		5424

GPU_pointeur_scrolling:			dc.l		texte_scrolling
GPU_position_dans_la_lettre_scrolling:		dc.l			0					; de 0 à 11 par pas de 1
GPU_position_dans_la_colonne_scrolling:		dc.l			16					; de 0 à 16, par pas de -4 //// 0 4 8 12 
GPU_pointeur_fin_liste_points_sprites:		dc.l			0					; pointe à la fin de la liste des sprites
GPU_pointeur_sur_sprite_en_cours:			dc.l			bob+512				; 16*8=128


GPU_taille_caractere_actuel:				dc.l			11

; doivent se succeder
GPU_pointeur_forme_en_cours:			dc.l	table_forme_0
GPU_pointeur_forme_fin:					dc.l	fin_table_forme_0
GPU_pointeur_forme_debut:				dc.l	table_forme_0
;---------
			
GPU_pointeurs_blocs_OL:
			.rept		29
			dc.l		0
			.endr

liste_points_sprites:
			.rept		nb_colonnes_de_sprites_a_afficher*nb_lignes_de_sprites_a_afficher
			dc.l		0					; X.w Y.w
			.endr



;---------------------
; FIN DE LA RAM GPU
GPU_fin:
;---------------------	

GPU_DRIVER_SIZE			.equ			GPU_fin-GPU_base_memoire
	.print	"--- GPU code size : ", /u GPU_DRIVER_SIZE, " bytes / 4096 ---"


		.68000

; ------------------------------------
;          LSP
; ------------------------------------


; ------------------------------------
; Init

LSP_PlayerInit:
; a0: music data (any mem)
; a1: sound bank data (chip mem)
; (a2: 16bit DMACON word address)

;		Out:a0: music BPM pointer (16bits)
;			d0: music len in tick count


			cmpi.l		#'LSP1',(a0)+
			bne			.dataError
			move.l		(a0)+,d0		; unique id
			cmp.l		(a1),d0			; check that sample bank is this one
			bne			.dataError

			lea			LSPVars,a3
			cmpi.w		#$0105,(a0)+			; minimal major & minor version of latest compatible LSPConvert.exe		 = V 1.05
			blt			.dataError

			moveq		#0,d6
			move.w		(a0)+,d6
			move.l		d6,m_currentBpm-LSPVars(a3)		; default BPM
			move.l		d6,LSP_BPM_frequence_replay
			move.w		(a0)+,d6
			move.l		d6,m_escCodeRewind-LSPVars(a3)		; tout en .L
			move.w		(a0)+,d6
			move.l		d6,m_escCodeSetBpm-LSPVars(a3)
			move.l		(a0)+,-(a7)							; nb de ticks du module en tout = temps de replay ( /BPM)
			;move.l	a2,m_dmaconPatch(a3)
			;move.w	#$8000,-1(a2)			; Be sure DMACon word is $8000 (note: a2 should be ODD address)
			moveq		#0,d0
			move.w		(a0)+,d0				; instrument count
			lea			-12(a0),a2				; LSP data has -12 offset on instrument tab ( to win 2 cycles in fast player :) )
			move.l		a2,m_lspInstruments-LSPVars(a3)	; instrument tab addr ( minus 4 )
			subq.w		#1,d0
			move.l		a1,d1

.relocLoop:	
			;bset.b		#0,3(a0)				; bit0 is relocation done flag
			;bne.s		.relocated
			
			move.l		(a0),d5					; pointeur sample
			add.l		d1,d5					; passage de relatif en absolu
			;lsl.l		#nb_bits_virgule_offset,d6
			move.l		d5,(a0)					; pointeur sample

			
			moveq		#0,d6
			move.w		4(a0),d6				; taille en words
			add.l		d6,d6
			move.w		d6,4(a0)				; taille en bytes

			move.l		(a0),a4					
			

			move.l		6(a0),d6					; pointeur sample repeat
			add.l		d1,d6					; passage de relatif en absolu
			cmp.l		d5,d6					; corrige pointeur de repeat avant le debut de l'instrument
			bge.s		.ok_loop
			move.l		d5,d6
.ok_loop:
			;lsl.l		#nb_bits_virgule_offset,d6
			move.l		d6,6(a0)					; pointeur sample repeat
			
			moveq		#0,d6
			move.w		10(a0),d6				; taille repeat en words
			add.l		d6,d6
			move.w		d6,10(a0)				; taille repeat en bytes

.relocated:	
			lea			12(a0),a0
			dbf.w		d0,.relocLoop
		
			move.w		(a0)+,d0				; codes count (+2)
			move.l		a0,m_codeTableAddr-LSPVars(a3)	; code table
			add.w		d0,d0
			add.w		d0,a0
			move.l		(a0)+,d0				; word stream size
			move.l		(a0)+,d1				; byte stream loop point
			move.l		(a0)+,d2				; word stream loop point

			move.l		a0,m_wordStream-LSPVars(a3)
			lea			0(a0,d0.l),a1			; byte stream
			move.l		a1,m_byteStream-LSPVars(a3)
			add.l		d2,a0
			add.l		d1,a1
			move.l		a0,m_wordStreamLoop-LSPVars(a3)
			move.l		a1,m_byteStreamLoop-LSPVars(a3)
			;bset.b		#1,$bfe001				; disabling this fucking Low pass filter!!
			lea			m_currentBpm-LSPVars(a3),a0
			move.l		(a7)+,d0				; music len in frame ticks
			rts

.dataError:	illegal

	
	
	.text
	
;-------------------------------------
;
;     DSP
;
;-------------------------------------

	.phrase
YM_DSP_debut:

	.dsp
	.org	D_RAM
DSP_base_memoire:

; CPU interrupt
	.rept	8
		nop
	.endr
; I2S interrupt
	movei	#DSP_LSP_routine_interruption_I2S,r28						; 6 octets
	movei	#D_FLAGS,r30											; 6 octets
	jump	(r28)													; 2 octets
	load	(r30),r29	; read flags								; 2 octets = 16 octets
; Timer 1 interrupt
	movei	#DSP_LSP_routine_interruption_Timer1,r12						; 6 octets
	movei	#D_FLAGS,r16											; 6 octets
	jump	(r12)													; 2 octets
	load	(r16),r13	; read flags								; 2 octets = 16 octets
; Timer 2 interrupt	
	movei	#DSP_LSP_routine_interruption_Timer2,r12						; 6 octets
	movei	#D_FLAGS,r16											; 6 octets
	jump	(r12)													; 2 octets
	load	(r16),r13	; read flags								; 2 octets = 16 octets
; External 0 interrupt
	.rept	8
		nop
	.endr
; External 1 interrupt
	.rept	8
		nop
	.endr













; -------------------------------
; DSP : routines en interruption
; -------------------------------
; utilisés : 	R29/R30/R31
; 				R18/R19/R20/R21/R22/R23/R24/R25/R26/R27/R28
;				


; I2S : replay sample
;	- version simple, lit un octet à chaque fois
;	- puis version plus compleque : lit 1 long, et utilise ses octets
DSP_LSP_routine_interruption_I2S:

	.if		DSP_DEBUG
; change la couleur du fond
	movei	#$777,R26
	movei	#BG,r27
	storew	r26,(r27)
	.endif

; version complexe avec stockage de 4 octets

; ----------
; channel 3
;	movei		#LSP_DSP_PAULA_internal_location3,R1
;	movei		#LSP_DSP_PAULA_internal_increment3,R2
;	movei		#LSP_DSP_PAULA_internal_length3,R3
;	movei		#LSP_DSP_PAULA_AUD3LEN,R4
;	movei		#LSP_DSP_PAULA_AUD3L,R5
		;movei		#LSP_DSP_PAULA_internal_location3,R28						; adresse sample actuelle, a virgule
		movefa		R1,R28
		;movei		#LSP_DSP_PAULA_internal_increment3,R27
		movefa		R2,R27
		load		(R28),R26										; R26=current pointeur sample 16:16
		load		(R27),R27										; R27=increment 16:16
		move		R26,R17											; R17 = pointeur sample a virgule avant increment
		;movei		#LSP_DSP_PAULA_internal_length3,R25				; =FIN
		movefa		R3,R25
		add			R27,R26											; R26=adresse+increment , a virgule
		load		(R25),R23
		movefa		R0,R22
		cmp			R23,R26
		jr			mi,DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel3
		;nop
		shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere

; fin de sample => on recharge les infos des registres externes
		shlq		#32-nb_bits_virgule_offset,R26
		;movei		#LSP_DSP_PAULA_AUD3LEN,R27			; fin, a virgule 
		movefa		R4,R27
		shrq		#32-nb_bits_virgule_offset,R26		; on ne garde que la virgule
		;movei		#LSP_DSP_PAULA_AUD3L,R24			; sample location a virgule
		movefa		R5,R24
		load		(R27),R27
		load		(R24),R23
		store		R27,(R25)							; update internal sample end, a virgule
		or			R23,R26								; on garde la virgule en cours
		
DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel3:
		store		R26,(R28)							; stocke internal sample pointeur, a virgule
		shrq		#nb_bits_virgule_offset,R26								; nouveau pointeur adresse sample partie entiere
														;shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere
		move		R26,R25								; R25 = nouveau pointeur sample 
		and			R22,R17								; ancien pointeur sample modulo 4
		and			R22,R26								; nouveau pointeur sample modulo 4
		;movei		#LSP_DSP_PAULA_AUD3DAT,R28			; 4 octets actuels
		subq		#4,R28								; de LSP_DSP_PAULA_internal_location3 => LSP_DSP_PAULA_AUD3DAT
		not			R22									; => %11
		load		(R28),R21							; R21 = octets actuels en stock
		and			R22,R25								; R25 = position octet à lire
		cmp			R17,R26
		jr			eq,DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word3
		shlq		#3,R25					; numero d'octet à lire * 8

; il faut rafraichir R21
		load		(R26),R21							; lit 4 nouveaux octets de sample
		store		R21,(R28)							; rafraichit le stockage des 4 octets

DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word3:
		;movei		#LSP_DSP_PAULA_AUD3VOL,R23/R24	
		subq		#4,R28								; de LSP_DSP_PAULA_AUD3DAT => LSP_DSP_PAULA_AUD3VOL
		neg			R25									; -0 -8 -16 -24
; R25=numero d'octet à lire
; ch2
		;movei		#LSP_DSP_PAULA_internal_increment2,R27
		movefa		R7,R27

		sh			R25,R21								; shift les 4 octets en stock vers la gauche, pour positionner l'octet à lire en haut
		load		(R28),R28							; R23 = volume : 6 bits
		sharq		#24,R21								; descends l'octet à lire
; ch2
		imult		R28,R21								; unsigned multiplication : unsigned sample * volume => 8bits + 6 bits = 14 bits

; R21=sample channel 3 on 14 bits

; ----------
; channel 2
;	movei		#LSP_DSP_PAULA_internal_location2,R6
;	movei		#LSP_DSP_PAULA_internal_increment2,R7
;	movei		#LSP_DSP_PAULA_internal_length2,R8
;	movei		#LSP_DSP_PAULA_AUD2LEN,R9
;	movei		#LSP_DSP_PAULA_AUD2L,R10
		load		(R27),R27										; R27=increment 16:16
		;movei		#LSP_DSP_PAULA_internal_location2,R28						; adresse sample actuelle, a virgule
		movefa		R6,R28
		;movei		#LSP_DSP_PAULA_internal_length2,R25				; =FIN
		movefa		R8,R25

		;movei		#LSP_DSP_PAULA_internal_increment2,R27
		load		(R28),R26										; R26=current pointeur sample 16:16
		move		R26,R17											; R17 = pointeur sample a virgule avant increment
		add			R27,R26											; R26=adresse+increment , a virgule
		load		(R25),R23
		movefa		R0,R22
		cmp			R23,R26
		jr			mi,DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel2
		shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere

; fin de sample => on recharge les infos des registres externes
		shlq		#32-nb_bits_virgule_offset,R26
		;movei		#LSP_DSP_PAULA_AUD2LEN,R27			; fin, a virgule 
		movefa		R9,R27
		shrq		#32-nb_bits_virgule_offset,R26		; on ne garde que la virgule
		;movei		#LSP_DSP_PAULA_AUD2L,R24			; sample location a virgule
		movefa		R10,R24
		load		(R27),R27
		load		(R24),R23
		store		R27,(R25)							; update internal sample end, a virgule
		or			R23,R26								; on garde la virgule en cours
		
DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel2:
		store		R26,(R28)							; stocke internal sample pointeur, a virgule
		shrq		#nb_bits_virgule_offset,R26								; nouveau pointeur adresse sample partie entiere
		;shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere
		move		R26,R25								; R25 = nouveau pointeur sample 
		and			R22,R17								; ancien pointeur sample modulo 4
		and			R22,R26								; nouveau pointeur sample modulo 4
		;movei		#LSP_DSP_PAULA_AUD2DAT,R28			; 4 octets actuels
		subq		#4,R28								; de LSP_DSP_PAULA_internal_location2 => LSP_DSP_PAULA_AUD2DAT
		not			R22									; => %11
		load		(R28),R20							; R20 = octets actuels en stock
		and			R22,R25								; R25 = position octet à lire
		cmp			R17,R26
		jr			eq,DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word2
		;nop
		shlq		#3,R25					; numero d'octet à lire * 8

; il faut rafraichir R20
		load		(R26),R20							; lit 4 nouveaux octets de sample
		store		R20,(R28)							; rafraichit le stockage des 4 octets

DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word2:
		;movei		#LSP_DSP_PAULA_AUD2VOL,R23
		subq		#4,R28								; de LSP_DSP_PAULA_AUD2DAT => LSP_DSP_PAULA_AUD2VOL
		neg			R25									; -0 -8 -16 -24
; R25=numero d'octet à lire
; ch1
		;movei		#LSP_DSP_PAULA_internal_increment1,R27
		movefa		R12,R27

		sh			R25,R20								; shift les 4 octets en stock vers la gauche, pour positionner l'octet à lire en haut
		load		(R28),R28							; R23 = volume : 6 bits
		sharq		#24,R20								; descends l'octet à lire
		imult		R28,R20								; unsigned multiplication : unsigned sample * volume => 8bits + 6 bits = 14 bits

; R20=sample channel 2 on 14 bits

; ----------
; channel 1
;	movei		#LSP_DSP_PAULA_internal_location1,R11
;	movei		#LSP_DSP_PAULA_internal_increment1,R12
;	movei		#LSP_DSP_PAULA_internal_length1,R13
;	movei		#LSP_DSP_PAULA_AUD1LEN,R14
;	movei		#LSP_DSP_PAULA_AUD1L,R15
		;movei		#LSP_DSP_PAULA_internal_location1,R28						; adresse sample actuelle, a virgule
		movefa		R11,R28
		load		(R28),R26										; R26=current pointeur sample 16:16
		load		(R27),R27										; R27=increment 16:16
		move		R26,R17											; R17 = pointeur sample a virgule avant increment
		;movei		#LSP_DSP_PAULA_internal_length1,R25				; =FIN
		movefa		R13,R25
		add			R27,R26											; R26=adresse+increment , a virgule
		load		(R25),R23
		movefa		R0,R22
		cmp			R23,R26
		jr			mi,DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel1
		;nop
		shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere

; fin de sample => on recharge les infos des registres externes
		shlq		#32-nb_bits_virgule_offset,R26
		;movei		#LSP_DSP_PAULA_AUD1LEN,R27			; fin, a virgule 
		movefa		R14,R27
		shrq		#32-nb_bits_virgule_offset,R26		; on ne garde que la virgule
		;movei		#LSP_DSP_PAULA_AUD1L,R24			; sample location a virgule
		movefa		R15,R24
		load		(R27),R27
		load		(R24),R23
		store		R27,(R25)							; update internal sample end, a virgule
		or			R23,R26								; on garde la virgule en cours
		
DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel1:
		store		R26,(R28)							; stocke internal sample pointeur, a virgule
		shrq		#nb_bits_virgule_offset,R26								; nouveau pointeur adresse sample partie entiere
		;shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere
		move		R26,R25								; R25 = nouveau pointeur sample 
		and			R22,R17								; ancien pointeur sample modulo 4
		and			R22,R26								; nouveau pointeur sample modulo 4
		;movei		#LSP_DSP_PAULA_AUD1DAT,R28			; 4 octets actuels
		subq		#4,R28								; de LSP_DSP_PAULA_internal_location1 => LSP_DSP_PAULA_AUD1DAT
		not			R22									; => %11
		load		(R28),R19							; R19 = octets actuels en stock
		and			R22,R25								; R25 = position octet à lire
		cmp			R17,R26
		jr			eq,DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word1
		;nop
		shlq		#3,R25					; numero d'octet à lire * 8

; il faut rafraichir R19
		load		(R26),R19							; lit 4 nouveaux octets de sample
		store		R19,(R28)							; rafraichit le stockage des 4 octets

DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word1:
		;movei		#LSP_DSP_PAULA_AUD1VOL,R23
		subq		#4,R28								; de LSP_DSP_PAULA_AUD1DAT => LSP_DSP_PAULA_AUD1VOL
		neg			R25									; -0 -8 -16 -24
; R25=numero d'octet à lire
; ch0
		;movei		#LSP_DSP_PAULA_internal_increment0,R27
		movefa		R17,R27

		sh			R25,R19								; shift les 4 octets en stock vers la gauche, pour positionner l'octet à lire en haut
		load		(R28),R23							; R23 = volume : 6 bits
		sharq		#24,R19								; descends l'octet à lire
; ch0
		;movei		#LSP_DSP_PAULA_internal_location0,R28						; adresse sample actuelle, a virgule
		movefa		R16,R28

		imult		R23,R19								; unsigned multiplication : unsigned sample * volume => 8bits + 6 bits = 14 bits

; R19=sample channel 1 on 14 bits

; ----------
; channel 0
;	movei		#LSP_DSP_PAULA_internal_location0,R16
;	movei		#LSP_DSP_PAULA_internal_increment0,R17
;	movei		#LSP_DSP_PAULA_internal_length0,R18
;	movei		#LSP_DSP_PAULA_AUD0LEN,R19
;	movei		#LSP_DSP_PAULA_AUD0L,R20
		load		(R28),R26										; R26=current pointeur sample 16:16
		load		(R27),R27										; R27=increment 16:16
		move		R26,R17											; R17 = pointeur sample a virgule avant increment
		;movei		#LSP_DSP_PAULA_internal_length0,R25				; =FIN
		movefa		R18,R25
		add			R27,R26											; R26=adresse+increment , a virgule
		load		(R25),R23
		movefa		R0,R22											; -FFFFFFC
		cmp			R23,R26
		jr			mi,DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel0
		shrq		#nb_bits_virgule_offset,R17								; ancien pointeur adresse sample partie entiere

; fin de sample => on recharge les infos des registres externes
		shlq		#32-nb_bits_virgule_offset,R26
		;movei		#LSP_DSP_PAULA_AUD0LEN,R27			; fin, a virgule 
		movefa		R19,R27
		shrq		#32-nb_bits_virgule_offset,R26		; on ne garde que la virgule
		;movei		#LSP_DSP_PAULA_AUD0L,R24			; sample location a virgule
		movefa		R20,R24
		load		(R27),R27
		load		(R24),R23
		store		R27,(R25)							; update internal sample end, a virgule
		or			R23,R26								; on garde la virgule en cours
		
DSP_LSP_routine_interruption_I2S_pas_fin_de_sample_channel0:
		store		R26,(R28)							; stocke internal sample pointeur, a virgule
		shrq		#nb_bits_virgule_offset,R26								; nouveau pointeur adresse sample partie entiere
		move		R26,R25								; R25 = nouveau pointeur sample 
		and			R22,R17								; ancien pointeur sample modulo 4
		and			R22,R26								; nouveau pointeur sample modulo 4
		;movei		#LSP_DSP_PAULA_AUD0DAT,R28			; 4 octets actuels
		subq		#4,R28								; de LSP_DSP_PAULA_internal_location0 => LSP_DSP_PAULA_AUD0DAT
		not			R22									; => %11
		load		(R28),R18							; R18 = octets actuels en stock
		and			R22,R25								; R25 = position octet à lire
		cmp			R17,R26
		jr			eq,DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word0
		shlq		#3,R25					; numero d'octet à lire * 8

; il faut rafraichir R18
		load		(R26),R18							; lit 4 nouveaux octets de sample
		store		R18,(R28)							; rafraichit le stockage des 4 octets

DSP_LSP_routine_interruption_I2S_pas_nouveau_long_word0:
		;movei		#LSP_DSP_PAULA_AUD0VOL,R23			
		subq		#4,R28								; de LSP_DSP_PAULA_AUD0DAT => LSP_DSP_PAULA_AUD0VOL
		neg			R25									; -0 -8 -16 -24
; R25=numero d'octet à lire


; suite
		.if			channel_2=0
			moveq	#0,R19
		.endif
		.if			channel_3=0
			moveq	#0,R20
		.endif
		add			R20,R19				; R19 = right 15 bits unsigned
;--

		sh			R25,R18								; shift les 4 octets en stock vers la gauche, pour positionner l'octet à lire en haut
		load		(R28),R23							; R23 = volume : 6 bits
		sharq		#24,R18								; descends l'octet à lire

; suite
		;movei		#$8000,R26
		movei		#L_I2S,R27

		imult		R23,R18								; unsigned multiplication : unsigned sample * volume => 8bits + 6 bits = 14 bits

; R18=sample channel 0 on 14 bits




; Stéreo Amiga:
; les canaux 0 et 3 formant la voie stéréo gauche et 1 et 2 la voie stéréo droite
; R18=channel 0
; R19=channel 1
; R20=channel 2
; R21=channel 3
		.if			channel_1=0
			moveq	#0,R18
		.endif
		.if			channel_4=0
			moveq	#0,R21
		.endif

		;movei		#$8000,R26
		movei		#L_I2S+4,R25
		add			R21,R18				; R18 = left 15 bits unsigned
		;add			R20,R19				; R19 = right 15 bits unsigned
		shlq		#1,R19
		shlq		#1,R18				; 16 bits unsigned
		
		;sub			R26,R18				; 16 bits signed
		;sub			R26,R19
		store		R19,(R27)			; write right channel
		store		R18,(R25)			; write left channel



		

	.if		DSP_DEBUG
; change la couleur du fond
	movei	#$000,R26
	movei	#BG,r27
	storew	r26,(r27)
	.endif


;------------------------------------	
; return from interrupt I2S
	load	(r31),r28	; return address
	bset	#10,r29		; clear latch 1 = I2S
	;bset	#11,r29		; clear latch 1 = timer 1
	;bset	#12,r29		; clear latch 1 = timer 2
	bclr	#3,r29		; clear IMASK
	addq	#4,r31		; pop from stack
	addqt	#2,r28		; next instruction
	jump	t,(r28)		; return
	store	r29,(r30)	; restore flags


;--------------------------------------------
; ---------------- Timer 1 ------------------
;--------------------------------------------
; autorise interruptions, pour timer I2S
; 
; registres utilisés :
;		R13/R16   /R31
;		R0/R1/R2/R3/R4/R5/R6/R7/R8/R9/R10  R12/R13/R14/R16


DSP_LSP_routine_interruption_Timer1:
	.if		I2S_during_Timer1=1
	bclr	#3,r13		; clear IMASK
	store	r13,(r16)	; restore flags
	.endif

; gestion replay LSP

	movei		#LSPVars,R14
	load		(R14),R0					; R0 = byte stream

DSP_LSP_Timer1_process:
	moveq		#0,R2
DSP_LSP_Timer1_cloop:

	loadb		(R0),R6						; R6 = byte code
	addq		#1,R0
	
	cmpq		#0,R6
	jr			ne,DSP_LSP_Timer1_swCode
	nop
	movei		#$0100,R3
	add			R3,R2
	jr			DSP_LSP_Timer1_cloop
	nop

DSP_LSP_Timer1_swCode:
	add			R2,R6
	move		R6,R2

	add			R2,R2
	load		(R14+2),R3			; R3=code table / m_codeTableAddr
	add			R2,R3
	movei		#DSP_LSP_Timer1_noInst,R12
	loadw		(R3),R2									; R2 = code
	cmpq		#0,R2
	jump		eq,(R12)
	nop
	load		(R14+3),R4			; R4=escape code rewind / m_escCodeRewind
	movei		#DSP_LSP_Timer1_r_rewind,R12
	cmp			R4,R2
	jump		eq,(R12)
	nop
	load		(R14+4),R4			; R4=escape code set bpm / m_escCodeSetBpm
	movei		#DSP_LSP_Timer1_r_chgbpm,R12
	cmp			R4,R2
	jump		eq,(R12)
	nop

;--------------------------
; gestion des volumes
;--------------------------
; test volume canal 3
	btst		#7,R2
	jr			eq,DSP_LSP_Timer1_noVd
	nop
	loadb		(R0),R4
	movei		#LSP_DSP_PAULA_AUD3VOL,R5
	addq		#1,R0
	store		R4,(R5)
DSP_LSP_Timer1_noVd:
; test volume canal 2
	btst		#6,R2
	jr			eq,DSP_LSP_Timer1_noVc
	nop
	loadb		(R0),R4
	movei		#LSP_DSP_PAULA_AUD2VOL,R5
	addq		#1,R0
	store		R4,(R5)
DSP_LSP_Timer1_noVc:
; test volume canal 1
	btst		#5,R2
	jr			eq,DSP_LSP_Timer1_noVb
	nop
	loadb		(R0),R4
	movei		#LSP_DSP_PAULA_AUD1VOL,R5
	addq		#1,R0
	store		R4,(R5)
DSP_LSP_Timer1_noVb:
; test volume canal 0
	btst		#4,R2
	jr			eq,DSP_LSP_Timer1_noVa
	nop
	loadb		(R0),R4
	movei		#LSP_DSP_PAULA_AUD0VOL,R5
	addq		#1,R0
	store		R4,(R5)
DSP_LSP_Timer1_noVa:

	.if			LSP_avancer_module=1
	store		R0,(R14)									; store byte stream ptr
	.endif
	addq		#4,R14									; avance a word stream ptr
	load		(R14),R0									; R0 = word stream

;--------------------------
; gestion des notes
;--------------------------
; test period canal 3
	btst		#3,R2
	jr			eq,DSP_LSP_Timer1_noPd
	nop
	loadw		(R0),R4
	movei		#LSP_DSP_PAULA_AUD3PER,R5
	addq		#2,R0
	store		R4,(R5)
DSP_LSP_Timer1_noPd:
; test period canal 2
	btst		#2,R2
	jr			eq,DSP_LSP_Timer1_noPc
	nop
	loadw		(R0),R4
	movei		#LSP_DSP_PAULA_AUD2PER,R5
	addq		#2,R0
	store		R4,(R5)
DSP_LSP_Timer1_noPc:
; test period canal 1
	btst		#1,R2
	jr			eq,DSP_LSP_Timer1_noPb
	nop
	loadw		(R0),R4
	movei		#LSP_DSP_PAULA_AUD1PER,R5
	addq		#2,R0
	store		R4,(R5)
DSP_LSP_Timer1_noPb:
; test period canal 0
	btst		#0,R2
	jr			eq,DSP_LSP_Timer1_noPa
	nop
	loadw		(R0),R4
	movei		#LSP_DSP_PAULA_AUD0PER,R5
	addq		#2,R0
	store		R4,(R5)
DSP_LSP_Timer1_noPa:

; pas de test des 8 bits du haut en entier pour zapper la lecture des instruments
; tst.w	d0							; d0.w, avec d0.b qui a avancé ! / beq.s	.noInst

	load		(R14+4),R5		; R5= instrument table  ( =+$10)  = a2   / m_lspInstruments-1 = 5-1

;--------------------------
; gestion des instruments
;--------------------------
;--- test instrument voie 3
	movei		#DSP_LSP_Timer1_setIns3,R12
	btst		#15,R2
	jump		ne,(R12)
	nop
	
	movei		#DSP_LSP_Timer1_skip3,R12
	btst		#14,R2
	jump		eq,(R12)
	nop

; repeat voie 3	
	movei		#LSP_DSP_repeat_pointeur3,R3
	movei		#LSP_DSP_repeat_length3,R4
	load		(R3),R3					; pointeur sauvegardé, sur infos de repeats
	load		(R4),R4
	movei		#LSP_DSP_PAULA_AUD3L,R7
	movei		#LSP_DSP_PAULA_AUD3LEN,R8
	store		R3,(R7)
	store		R4,(R8)					; stocke le pointeur sample de repeat dans LSP_DSP_PAULA_AUD3L
	jump		(R12)				; jump en DSP_LSP_Timer1_skip3
	nop

DSP_LSP_Timer1_setIns3:
	loadw		(R0),R3				; offset de l'instrument par rapport au precedent
; addition en .w
; passage en .L
	shlq		#16,R3
	sharq		#16,R3
	add			R3,R5				;R5=pointeur datas instruments
	addq		#2,R0


	movei		#LSP_DSP_PAULA_AUD3L,R7
	loadw		(R5),R6
	addq		#2,R5
	shlq		#16,R6
	loadw		(R5),R8
	or			R8,R6
	movei		#LSP_DSP_PAULA_AUD3LEN,R8
	shlq		#nb_bits_virgule_offset,R6		
	store		R6,(R7)				; stocke le pointeur sample a virgule dans LSP_DSP_PAULA_AUD3L
	addq		#2,R5
	loadw		(R5),R9				; .w = R9 = taille du sample
	shlq		#nb_bits_virgule_offset,R9				; en 16:16
	add			R6,R9				; taille devient fin du sample, a virgule
	store		R9,(R8)				; stocke la nouvelle fin a virgule
	addq		#2,R5				; positionne sur pointeur de repeat
; repeat pointeur
	movei		#LSP_DSP_repeat_pointeur3,R7
	loadw		(R5),R4
	addq		#2,R5
	shlq		#16,R4
	loadw		(R5),R8
	or			R8,R4
	addq		#2,R5
	shlq		#nb_bits_virgule_offset,R4	
	store		R4,(R7)				; pointeur sample repeat, a virgule
; repeat length
	movei		#LSP_DSP_repeat_length3,R7
	loadw		(R5),R8				; .w = R8 = taille du sample
	shlq		#nb_bits_virgule_offset,R8				; en 16:16
	add			R4,R8
	store		R8,(R7)				; stocke la nouvelle taille
	subq		#4,R5
	
; test le reset pour prise en compte immediate du changement de sample
	movei		#DSP_LSP_Timer1_noreset3,R12
	btst		#14,R2
	jump		eq,(R12)
	nop
; reset a travers le dmacon, il faut rafraichir : LSP_DSP_PAULA_internal_location3 & LSP_DSP_PAULA_internal_length3 & LSP_DSP_PAULA_internal_offset3=0
	movei		#LSP_DSP_PAULA_internal_location3,R7
	movei		#LSP_DSP_PAULA_internal_length3,R8
	store		R6,(R7)				; stocke le pointeur sample dans LSP_DSP_PAULA_internal_location3
	store		R9,(R8)				; stocke la nouvelle taille en 16:16: dans LSP_DSP_PAULA_internal_length3
; remplace les 4 octets en stock
	move		R6,R12
	shrq		#nb_bits_virgule_offset+2,R12	; enleve la virgule  + 2 bits du bas
	movei		#LSP_DSP_PAULA_AUD3DAT,R8
	shlq		#2,R12
	load		(R12),R7
	store		R7,(R8)
	

DSP_LSP_Timer1_noreset3:
DSP_LSP_Timer1_skip3:

;--- test instrument voie 2
	movei		#DSP_LSP_Timer1_setIns2,R12
	btst		#13,R2
	jump		ne,(R12)
	nop
	
	movei		#DSP_LSP_Timer1_skip2,R12
	btst		#12,R2
	jump		eq,(R12)
	nop

; repeat voie 2
	movei		#LSP_DSP_repeat_pointeur2,R3
	movei		#LSP_DSP_repeat_length2,R4
	load		(R3),R3					; pointeur sauvegardé, sur infos de repeats
	load		(R4),R4
	movei		#LSP_DSP_PAULA_AUD2L,R7
	movei		#LSP_DSP_PAULA_AUD2LEN,R8
	store		R3,(R7)
	store		R4,(R8)					; stocke le pointeur sample de repeat dans LSP_DSP_PAULA_AUD3L
	jump		(R12)				; jump en DSP_LSP_Timer1_skip3
	nop

DSP_LSP_Timer1_setIns2:
	loadw		(R0),R3				; offset de l'instrument par rapport au precedent
; addition en .w
; passage en .L
	shlq		#16,R3
	sharq		#16,R3
	add			R3,R5				;R5=pointeur datas instruments
	addq		#2,R0


	movei		#LSP_DSP_PAULA_AUD2L,R7
	loadw		(R5),R6
	addq		#2,R5
	shlq		#16,R6
	loadw		(R5),R8
	or			R8,R6
	movei		#LSP_DSP_PAULA_AUD2LEN,R8
	shlq		#nb_bits_virgule_offset,R6		
	store		R6,(R7)				; stocke le pointeur sample a virgule dans LSP_DSP_PAULA_AUD3L
	addq		#2,R5
	loadw		(R5),R9				; .w = R9 = taille du sample
	shlq		#nb_bits_virgule_offset,R9				; en 16:16
	add			R6,R9				; taille devient fin du sample, a virgule
	store		R9,(R8)				; stocke la nouvelle fin a virgule
	addq		#2,R5				; positionne sur pointeur de repeat
; repeat pointeur
	movei		#LSP_DSP_repeat_pointeur2,R7
	loadw		(R5),R4
	addq		#2,R5
	shlq		#16,R4
	loadw		(R5),R8
	or			R8,R4
	addq		#2,R5
	shlq		#nb_bits_virgule_offset,R4	
	store		R4,(R7)				; pointeur sample repeat, a virgule
; repeat length
	movei		#LSP_DSP_repeat_length2,R7
	loadw		(R5),R8				; .w = R8 = taille du sample
	shlq		#nb_bits_virgule_offset,R8				; en 16:16
	add			R4,R8
	store		R8,(R7)				; stocke la nouvelle taille
	subq		#4,R5
	
; test le reset pour prise en compte immediate du changement de sample
	movei		#DSP_LSP_Timer1_noreset2,R12
	btst		#12,R2
	jump		eq,(R12)
	nop
; reset a travers le dmacon, il faut rafraichir : LSP_DSP_PAULA_internal_location3 & LSP_DSP_PAULA_internal_length3 & LSP_DSP_PAULA_internal_offset3=0
	movei		#LSP_DSP_PAULA_internal_location2,R7
	movei		#LSP_DSP_PAULA_internal_length2,R8
	store		R6,(R7)				; stocke le pointeur sample dans LSP_DSP_PAULA_internal_location3
	store		R9,(R8)				; stocke la nouvelle taille en 16:16: dans LSP_DSP_PAULA_internal_length3
; remplace les 4 octets en stock
	move		R6,R12
	shrq		#nb_bits_virgule_offset+2,R12	; enleve la virgule  + 2 bits du bas
	movei		#LSP_DSP_PAULA_AUD2DAT,R8
	shlq		#2,R12
	load		(R12),R7
	store		R7,(R8)
	

DSP_LSP_Timer1_noreset2:
DSP_LSP_Timer1_skip2:
	
;--- test instrument voie 1
	movei		#DSP_LSP_Timer1_setIns1,R12
	btst		#11,R2
	jump		ne,(R12)
	nop
	
	movei		#DSP_LSP_Timer1_skip1,R12
	btst		#10,R2
	jump		eq,(R12)
	nop

; repeat voie 1
	movei		#LSP_DSP_repeat_pointeur1,R3
	movei		#LSP_DSP_repeat_length1,R4
	load		(R3),R3					; pointeur sauvegardé, sur infos de repeats
	load		(R4),R4
	movei		#LSP_DSP_PAULA_AUD1L,R7
	movei		#LSP_DSP_PAULA_AUD1LEN,R8
	store		R3,(R7)
	store		R4,(R8)					; stocke le pointeur sample de repeat dans LSP_DSP_PAULA_AUD3L
	jump		(R12)				; jump en DSP_LSP_Timer1_skip3
	nop

DSP_LSP_Timer1_setIns1:
	loadw		(R0),R3				; offset de l'instrument par rapport au precedent
; addition en .w
; passage en .L
	shlq		#16,R3
	sharq		#16,R3
	add			R3,R5				;R5=pointeur datas instruments
	addq		#2,R0


	movei		#LSP_DSP_PAULA_AUD1L,R7
	loadw		(R5),R6
	addq		#2,R5
	shlq		#16,R6
	loadw		(R5),R8
	or			R8,R6
	movei		#LSP_DSP_PAULA_AUD1LEN,R8
	shlq		#nb_bits_virgule_offset,R6		
	store		R6,(R7)				; stocke le pointeur sample a virgule dans LSP_DSP_PAULA_AUD3L
	addq		#2,R5
	loadw		(R5),R9				; .w = R9 = taille du sample
	shlq		#nb_bits_virgule_offset,R9				; en 16:16
	add			R6,R9				; taille devient fin du sample, a virgule
	store		R9,(R8)				; stocke la nouvelle fin a virgule
	addq		#2,R5				; positionne sur pointeur de repeat
; repeat pointeur
	movei		#LSP_DSP_repeat_pointeur1,R7
	loadw		(R5),R4
	addq		#2,R5
	shlq		#16,R4
	loadw		(R5),R8
	or			R8,R4
	addq		#2,R5
	shlq		#nb_bits_virgule_offset,R4	
	store		R4,(R7)				; pointeur sample repeat, a virgule
; repeat length
	movei		#LSP_DSP_repeat_length1,R7
	loadw		(R5),R8				; .w = R8 = taille du sample
	shlq		#nb_bits_virgule_offset,R8				; en 16:16
	add			R4,R8
	store		R8,(R7)				; stocke la nouvelle taille
	subq		#4,R5
	
; test le reset pour prise en compte immediate du changement de sample
	movei		#DSP_LSP_Timer1_noreset1,R12
	btst		#10,R2
	jump		eq,(R12)
	nop
; reset a travers le dmacon, il faut rafraichir : LSP_DSP_PAULA_internal_location3 & LSP_DSP_PAULA_internal_length3 & LSP_DSP_PAULA_internal_offset3=0
	movei		#LSP_DSP_PAULA_internal_location1,R7
	movei		#LSP_DSP_PAULA_internal_length1,R8
	store		R6,(R7)				; stocke le pointeur sample dans LSP_DSP_PAULA_internal_location3
	store		R9,(R8)				; stocke la nouvelle taille en 16:16: dans LSP_DSP_PAULA_internal_length3
; remplace les 4 octets en stock
	move		R6,R12
	shrq		#nb_bits_virgule_offset+2,R12	; enleve la virgule  + 2 bits du bas
	movei		#LSP_DSP_PAULA_AUD1DAT,R8
	shlq		#2,R12
	load		(R12),R7
	store		R7,(R8)
	

DSP_LSP_Timer1_noreset1:
DSP_LSP_Timer1_skip1:
	
;--- test instrument voie 0
	movei		#DSP_LSP_Timer1_setIns0,R12
	btst		#9,R2
	jump		ne,(R12)
	nop
	
	movei		#DSP_LSP_Timer1_skip0,R12
	btst		#8,R2
	jump		eq,(R12)
	nop

; repeat voie 0
	movei		#LSP_DSP_repeat_pointeur0,R3
	movei		#LSP_DSP_repeat_length0,R4
	load		(R3),R3					; pointeur sauvegardé, sur infos de repeats
	load		(R4),R4
	movei		#LSP_DSP_PAULA_AUD0L,R7
	movei		#LSP_DSP_PAULA_AUD0LEN,R8
	store		R3,(R7)
	store		R4,(R8)					; stocke le pointeur sample de repeat dans LSP_DSP_PAULA_AUD3L
	jump		(R12)				; jump en DSP_LSP_Timer1_skip3
	nop

DSP_LSP_Timer1_setIns0:
	loadw		(R0),R3				; offset de l'instrument par rapport au precedent
; addition en .w
; passage en .L
	shlq		#16,R3
	sharq		#16,R3
	add			R3,R5				;R5=pointeur datas instruments
	addq		#2,R0


	movei		#LSP_DSP_PAULA_AUD0L,R7
	loadw		(R5),R6
	addq		#2,R5
	shlq		#16,R6
	loadw		(R5),R8
	or			R8,R6
	movei		#LSP_DSP_PAULA_AUD0LEN,R8
	shlq		#nb_bits_virgule_offset,R6		
	store		R6,(R7)				; stocke le pointeur sample a virgule dans LSP_DSP_PAULA_AUD3L
	addq		#2,R5
	loadw		(R5),R9				; .w = R9 = taille du sample
	shlq		#nb_bits_virgule_offset,R9				; en 16:16
	add			R6,R9				; taille devient fin du sample, a virgule
	store		R9,(R8)				; stocke la nouvelle fin a virgule
	addq		#2,R5				; positionne sur pointeur de repeat
; repeat pointeur
	movei		#LSP_DSP_repeat_pointeur0,R7
	loadw		(R5),R4
	addq		#2,R5
	shlq		#16,R4
	loadw		(R5),R8
	or			R8,R4
	addq		#2,R5
	shlq		#nb_bits_virgule_offset,R4	
	store		R4,(R7)				; pointeur sample repeat, a virgule
; repeat length
	movei		#LSP_DSP_repeat_length0,R7
	loadw		(R5),R8				; .w = R8 = taille du sample
	shlq		#nb_bits_virgule_offset,R8				; en 16:16
	add			R4,R8
	store		R8,(R7)				; stocke la nouvelle taille
	subq		#4,R5
	
; test le reset pour prise en compte immediate du changement de sample
	movei		#DSP_LSP_Timer1_noreset0,R12
	btst		#8,R2
	jump		eq,(R12)
	nop
; reset a travers le dmacon, il faut rafraichir : LSP_DSP_PAULA_internal_location3 & LSP_DSP_PAULA_internal_length3 & LSP_DSP_PAULA_internal_offset3=0
	movei		#LSP_DSP_PAULA_internal_location0,R7
	movei		#LSP_DSP_PAULA_internal_length0,R8
	store		R6,(R7)				; stocke le pointeur sample dans LSP_DSP_PAULA_internal_location3
	store		R9,(R8)				; stocke la nouvelle taille en 16:16: dans LSP_DSP_PAULA_internal_length3

; remplace les 4 octets en stock
	move		R6,R12
	shrq		#nb_bits_virgule_offset+2,R12	; enleve la virgule  + 2 bits du bas
	movei		#LSP_DSP_PAULA_AUD0DAT,R8
	shlq		#2,R12
	load		(R12),R7
	store		R7,(R8)
	

DSP_LSP_Timer1_noreset0:
DSP_LSP_Timer1_skip0:
	
	

DSP_LSP_Timer1_noInst:
	.if			LSP_avancer_module=1
	store		R0,(R14)			; store word stream (or byte stream if coming from early out)
	.endif


; - fin de la conversion du player LSP

; elements d'emulation Paula
; calcul des increments
; calcul de l'increment a partir de la note Amiga : (3546895 / note) / frequence I2S

; conversion period => increment voie 0
	movei		#DSP_frequence_de_replay_reelle_I2S,R0
	movei		#LSP_DSP_PAULA_internal_increment0,R1
	movei		#LSP_DSP_PAULA_AUD0PER,R2
	load		(R0),R0
	movei		#3546895,R3
	
	load		(R2),R2
	cmpq		#0,R2
	jr			ne,.1
	nop
	moveq		#0,R4
	jr			.2
	nop
.1:
	move		R3,R4
	div			R2,R4			; (3546895 / note)
	or			R4,R4
	shlq		#nb_bits_virgule_offset,R4
	div			R0,R4			; (3546895 / note) / frequence I2S en 16:16
	or			R4,R4
.2:
	store		R4,(R1)
; conversion period => increment voie 1
	movei		#LSP_DSP_PAULA_AUD1PER,R2
	movei		#LSP_DSP_PAULA_internal_increment1,R1
	move		R3,R4
	load		(R2),R2
	cmpq		#0,R2
	jr			ne,.12
	nop
	moveq		#0,R4
	jr			.22
	nop
.12:

	div			R2,R4			; (3546895 / note)
	or			R4,R4
	shlq		#nb_bits_virgule_offset,R4
	div			R0,R4			; (3546895 / note) / frequence I2S en 16:16
	or			R4,R4
.22:
	store		R4,(R1)

; conversion period => increment voie 2
	movei		#LSP_DSP_PAULA_AUD2PER,R2
	movei		#LSP_DSP_PAULA_internal_increment2,R1
	move		R3,R4
	load		(R2),R2
	cmpq		#0,R2
	jr			ne,.13
	nop
	moveq		#0,R4
	jr			.23
	nop
.13:
	div			R2,R4			; (3546895 / note)
	or			R4,R4
	shlq		#nb_bits_virgule_offset,R4
	div			R0,R4			; (3546895 / note) / frequence I2S en 16:16
	or			R4,R4
.23:
	store		R4,(R1)

; conversion period => increment voie 3
	movei		#LSP_DSP_PAULA_AUD3PER,R2
	movei		#LSP_DSP_PAULA_internal_increment3,R1
	move		R3,R4
	load		(R2),R2
	cmpq		#0,R2
	jr			ne,.14
	nop
	moveq		#0,R4
	jr			.24
	nop
.14:
	div			R2,R4			; (3546895 / note)
	or			R4,R4
	shlq		#nb_bits_virgule_offset,R4
	div			R0,R4			; (3546895 / note) / frequence I2S en 16:16
	or			R4,R4
.24:
	store		R4,(R1)

;--------------------------------------------------




	
;------------------------------------	
; return from interrupt Timer 1
	load	(r31),r12	; return address
	;bset	#10,r13		; clear latch 1 = I2S
	bset	#11,r13		; clear latch 1 = timer 1
	;bset	#12,r13		; clear latch 1 = timer 2
	bclr	#3,r13		; clear IMASK
	addq	#4,r31		; pop from stack
	addqt	#2,r12		; next instruction
	jump	t,(r12)		; return
	store	r13,(r16)	; restore flags

;------------------------------------	
;rewind
DSP_LSP_Timer1_r_rewind:
;	movei		#LSPVars,R14
;	load		(R14),R0					; R0 = byte stream
	load		(R14+8),R0			; bouclage : R0 = byte stream / m_byteStreamLoop = 8
	movei		#DSP_LSP_Timer1_process,R12
	load		(R14+9),R3			; m_wordStreamLoop=9
	jump		(R12)
	store		R3,(R14+1)				; m_wordStream=1

;------------------------------------	
; change bpm
DSP_LSP_Timer1_r_chgbpm:
	movei		#DSP_LSP_Timer1_process,R12
	loadb		(R0),R11
	store		R11,(R14+7)		; R3=nouveau bpm / m_currentBpm = 7
;application nouveau bpm dans Timer 1
	movei	#60*256,R10
	;shlq	#8,R10				; 16 bits de virgule
	div		R11,R10				; 60/bpm
	movei	#24*65536,R9				; 24=> 5 bits
	or		R10,R10
	;shlq	#16,R9
	div		R10,R9				; R9=
	or		R9,R9
	shrq	#8,R9				; R9=frequence replay 
	;move	R9,R11	
; frequence du timer 1
	movei	#182150,R10				; 26593900 / 146 = 182150
	div		R9,R10
	or		R10,R10
	move	R10,R14
	subq	#1,R14					; -1 pour parametrage du timer 1
; 26593900 / 50 = 531 878 => 2 × 73 × 3643 => 146*3643
	movei	#JPIT1,r10				; F10000
	movei	#145*65536,r9				; Timer 1 Pre-scaler
	;shlq	#16,r12
	or		R14,R9
	store	r9,(r10)				; JPIT1 & JPIT2



	jump		(R12)
	addq		#1,R0




; ------------------- N/A ------------------
DSP_LSP_routine_interruption_Timer2:
; ------------------- N/A ------------------

;DSP_pad1
;DSP_pad2
; lecture des 2 pads
; Pads : mask = xxxx xxCx xxBx 2580 147* oxAP 369# RLDU
; dispos : R0 à R12
	movei		#DSP_pad1,R11
	movei		#DSP_pad2,R12
	movei		#JOYSTICK,R0

	movei		#%00001111000000000000000000000000,R2		; mask port 1
	movei		#%00000000000000000000000000000011,R3		; mask port 1

	movei		#%11110000000000000000000000000000,R5		; mask port 2
	movei		#%00000000000000000000000000001100,R6		; mask port 2



; row 0
	MOVEI		#$817e,R1			; =81<<8 + 0111 1110 = (A Pause) + (Right Left Down Up) / 81 pour bit 15 pour output + bit 8 pour  conserver le son ON : pad 1 & 2
									; 1110 = row 0 of joypad = Pause A Up Down Left Right
	storew		R1,(R0)				; lecture row 0
	nop
	load		(R0),R1
	;movei		#$F000000C,R3		; mask port 2
	
; row0 = Pause A Up Down Left Right
; 0000 1111 0000 0000 0000 0000 0000 0011
;      RLDU                            Ap
	move		R1,R10				; stocke pour lecture port 2
	
	move		R1,R4
	move		R10,R7
	and			R3,R4		
	and			R6,R7		
	and			R2,R1				
	and			R5,R10				
	shlq		#8,R4				; R4=Ap xxxx xxxx
	shlq		#6,R7				; R4=Ap xxxx xxxx
	shrq		#24,R1				; R1=RLDU
	shrq		#28,R10				; R10=RLDU
	or			R4,R1
	or			R7,R10
	move		R1,R8
	move		R10,R9



; row 1
	MOVEI		#$81BD,R1			; #($81 << 8)|(%1011 << 4)|(%1101),(a2) ; (B D) + (1 4 7 *)
	storew		R1,(R0)				; lecture row 1
	nop
	load		(R0),R1
; row1 = 
; 0000 1111 0000 0000 0000 0000 0000 0011
;      147*                            BD
	move		R1,R10				; stocke pour lecture port 2
;row1 port 1&2

	move		R1,R4
	move		R10,R7
	and			R3,R4
	and			R6,R7		
	shlq		#20,R4
	shlq		#18,R7				
	and			R2,R1				
	and			R5,R10				
	shrq		#12,R1				; R1=147*
	shrq		#16,R10				; R10=147*
	or			R1,R4
	or			R7,R10
	or			R4,R8				; R8= BD xxxx 147* xxAp xxxx RLDU
	or			R10,R9


; row 2
	MOVEI		#$81DB,R1			; #($81 << 8)|(%1101 << 4)|(%1011),(a2) ; (C E) + (2 5 8 0)
	storew		R1,(R0)				; lecture row 2
	nop
	load		(R0),R1
	move		R1,R10				; stocke pour lecture port 2

; row2 = 
; 0000 1111 0000 0000 0000 0000 0000 0011
;      2580                            CE
; 24,8,22,12
	move		R1,R4
	move		R10,R7
	and			R3,R4
	and			R6,R7		
	shlq		#24,R4
	shlq		#22,R7				
	and			R2,R1				
	and			R5,R10				
	shrq		#8,R1				; R1=147*
	shrq		#12,R10				; R10=147*
	or			R1,R4
	or			R7,R10
	or			R4,R8				; R8= BD xxxx 147* xxAp xxxx RLDU
	or			R10,R9



; row 3
	MOVEI		#$81E7,R1			; #($81 << 8)|(%1110 << 4)|(%0111),(a2) ; (Option F) + (3 6 9 #)
	storew		R1,(R0)				; lecture row 3
	nop
	load		(R0),R1
; row3 = 
; 0000 1111 0000 0000 0000 0000 0000 0011
;      369#                            oF
; l10,r20,l8,r24
	move		R1,R10				; stocke pour lecture port 2

	move		R1,R4
	move		R10,R7
	and			R3,R4
	and			R6,R7		
	shlq		#10,R4
	shlq		#8,R7				
	and			R2,R1				
	and			R5,R10				
	shrq		#20,R1				; R1=147*
	shrq		#24,R10				; R10=147*
	or			R1,R4
	or			R7,R10
	or			R4,R8				; R8= BD xxxx 147* xxAp xxxx RLDU
	or			R10,R9

	
	
	not			R8
	not			R9
	store		R8,(R11)
	store		R9,(R12)
	
	
									
									
									
;------------------------------------	
; return from interrupt Timer 2
	load	(r31),r12	; return address
	;bset	#10,r13		; clear latch 1 = I2S
	;bset	#11,r13		; clear latch 1 = timer 1
	bset	#12,r13		; clear latch 1 = timer 2
	bclr	#3,r13		; clear IMASK
	addq	#4,r31		; pop from stack
	addqt	#2,r12		; next instruction
	jump	t,(r12)		; return
	store	r13,(r16)	; restore flags



; ------------- main DSP ------------------
DSP_routine_init_DSP:
; assume run from bank 1
	movei	#DSP_ISP+(DSP_STACK_SIZE*4),r31			; init isp
	moveq	#0,r1
	moveta	r31,r31									; ISP (bank 0)
	nop
	movei	#DSP_USP+(DSP_STACK_SIZE*4),r31			; init usp

; calculs des frequences deplacé dans DSP
; sclk I2S
	movei	#LSP_DSP_Audio_frequence,R0
	movei	#frequence_Video_Clock_divisee,R1
	load	(R1),R1
	shlq	#8,R1
	div		R0,R1
	movei	#128,R2
	add		R2,R1			; +128 = +0.5
	shrq	#8,R1
	subq	#1,R1
	movei	#DSP_parametre_de_frequence_I2S,r2
	store	R1,(R2)
;calcul inverse
	addq	#1,R1
	add		R1,R1			; *2
	add		R1,R1			; *2
	shlq	#4,R1			; *16
	movei	#frequence_Video_Clock,R0
	load	(R0),R0
	div		R1,R0
	movei	#DSP_frequence_de_replay_reelle_I2S,R2
	store	R0,(R2)
	

; init I2S
	movei	#SCLK,r10
	movei	#SMODE,r11
	movei	#DSP_parametre_de_frequence_I2S,r12
	movei	#%001101,r13			; SMODE bascule sur RISING
	load	(r12),r12				; SCLK
	store	r12,(r10)
	store	r13,(r11)


; init Timer 1
; frq = 24/(60/bpm)
	movei	#LSP_BPM_frequence_replay,R11
	load	(R11),R11
	movei	#60*256,R10
	;shlq	#8,R10				; 16 bits de virgule
	div		R11,R10				; 60/bpm
	movei	#24*65536,R9				; 24=> 5 bits
	or		R10,R10
	;shlq	#16,R9
	div		R10,R9				; R9=
	or		R9,R9
	shrq	#8,R9				; R9=frequence replay 
	
	move	R9,R11	
	

; frequence du timer 1
	movei	#182150,R10				; 26593900 / 146 = 182150
	div		R11,R10
	or		R10,R10
	move	R10,R13

	subq	#1,R13					; -1 pour parametrage du timer 1
	
	

; 26593900 / 50 = 531 878 => 2 × 73 × 3643 => 146*3643
	movei	#JPIT1,r10				; F10000
	;movei	#JPIT2,r11				; F10002
	movei	#145*65536,r12				; Timer 1 Pre-scaler
	;shlq	#16,r12
	or		R13,R12
	
	store	r12,(r10)				; JPIT1 & JPIT2


; init timer 2
	movei	#JPIT3,r10				; F10004
	;movei	#JPIT4,r11				; F10006
	movei	#145*65536,r12			; Timer 1 Pre-scaler
	movei	#955-1,r13				; 951=200hz
	or		R13,R12
	store	r12,(r10)				; JPIT1 & JPIT2


; enable interrupts
	movei	#D_FLAGS,r30
	
	;movei	#D_I2SENA|D_TIM1ENA|D_TIM2ENA|REGPAGE,r29			; I2S+Timer 1+timer 2
	;movei	#D_I2SENA|D_TIM1ENA|REGPAGE,r29			; I2S+Timer 1
	;movei	#D_I2SENA|REGPAGE,r29					; I2S only
	
	
	;movei	#D_TIM1ENA|REGPAGE,r29					; Timer 1 only
	movei	#D_TIM2ENA|REGPAGE,r29					; Timer 2 only

;----------------------------
; variables pour movfa
	movei		#$FFFFFFFC,R0									; OK
; channel 3
	movei		#LSP_DSP_PAULA_internal_location3,R1			; OK
	movei		#LSP_DSP_PAULA_internal_increment3,R2			; OK
	movei		#LSP_DSP_PAULA_internal_length3,R3				; OK
	movei		#LSP_DSP_PAULA_AUD3LEN,R4						; OK
	movei		#LSP_DSP_PAULA_AUD3L,R5
;channel 2
	movei		#LSP_DSP_PAULA_internal_location2,R6			; OK
	movei		#LSP_DSP_PAULA_internal_increment2,R7			; OK
	movei		#LSP_DSP_PAULA_internal_length2,R8				; OK
	movei		#LSP_DSP_PAULA_AUD2LEN,R9						; OK
	movei		#LSP_DSP_PAULA_AUD2L,R10						; OK
;channel 1
	movei		#LSP_DSP_PAULA_internal_location1,R11
	movei		#LSP_DSP_PAULA_internal_increment1,R12
	movei		#LSP_DSP_PAULA_internal_length1,R13
	movei		#LSP_DSP_PAULA_AUD1LEN,R14
	movei		#LSP_DSP_PAULA_AUD1L,R15
;channel 0
	movei		#LSP_DSP_PAULA_internal_location0,R16
	movei		#LSP_DSP_PAULA_internal_increment0,R17
	movei		#LSP_DSP_PAULA_internal_length0,R18
	movei		#LSP_DSP_PAULA_AUD0LEN,R19
	movei		#LSP_DSP_PAULA_AUD0L,R20
;---------------
	store	r29,(r30)
	nop
	nop
DSP_boucle_centrale:



; test button B
	movei	#DSP_pad1,R30
	load	(R30),R30
	btst	#U235SE_BBUT_B,R30
	jr		eq,DSP_no_B_pressed
	nop
	movei	#LSP_DSP_buttonB_pressed,R29
	load	(R29),R30
	not		R30
	store	R30,(R29)

DSP_no_B_pressed:

; test button 1
	movei	#DSP_pad1,R30
	load	(R30),R30
	btst	#U235SE_BBUT_1,R30
	jr		eq,DSP_no_1_pressed
	nop
	movei	#GPU_vitesse_scrolling,R29
	moveq	#2,R30
	store	R30,(R29)
DSP_no_1_pressed:

; test button 2
	movei	#DSP_pad1,R30
	load	(R30),R30
	btst	#U235SE_BBUT_2,R30
	jr		eq,DSP_no_2_pressed
	nop
	movei	#GPU_vitesse_scrolling,R29
	moveq	#4,R30
	store	R30,(R29)
; mettre position en multiple de 4
	movei	#GPU_position_dans_la_colonne_scrolling,R29
	load	(R29),R30
	shrq	#2,R30			; arrondit au multiple de 4
	shlq	#2,R30
	store	R30,(R29)
DSP_no_2_pressed:



	movei	#LSP_DSP_oldflag,R27
	load	(R27),R28
	movei	#LSP_DSP_flag,R29
	load	(R29),R30

	cmp		R28,R30
	movei	#DSP_boucle_centrale,R29
	jump	eq,(R29)
	nop
; flags are different, handles new flag
	movei	#DSP_boucle_centrale,R28
	cmpq	#0,R30
	jr		ne,DSP_switch_ON
	store	R30,(R27)
; DSP switch off
	movei	#D_FLAGS,r30
	movei	#D_TIM2ENA|REGPAGE,r27
	store	R27,(R30)							; just timer 2
	nop
	nop
	nop
	nop

	jump	(R28)
	nop
DSP_switch_ON:
	movei	#D_I2SENA|D_TIM1ENA|D_TIM2ENA|REGPAGE,r27			; I2S+Timer 1+timer 2
	movei	#D_FLAGS,r30
	store	R27,(R30)
	nop
	nop
	nop
	nop
	jump	(R28)

	nop
	
	
	.phrase


LSP_DSP_flag:										dc.l			0				; DSP replay flag 0=OFF / 1=ON
LSP_DSP_oldflag:									dc.l			0
LSP_DSP_buttonB_pressed:							dc.l			0

DSP_frequence_de_replay_reelle_I2S:					dc.l			0
DSP_UN_sur_frequence_de_replay_reelle_I2S:			dc.l			0
DSP_parametre_de_frequence_I2S:						dc.l			0

LSP_PAULA:
; variables Paula
; channel 0
LSP_DSP_PAULA_AUD0L:				dc.l			silence<<nb_bits_virgule_offset			; Audio channel 0 location
LSP_DSP_PAULA_AUD0LEN:				dc.l			(silence+4)<<nb_bits_virgule_offset			; en bytes !
LSP_DSP_PAULA_AUD0PER:				dc.l			0				; period , a transformer en increment
LSP_DSP_PAULA_AUD0VOL:				dc.l			0				; volume
LSP_DSP_PAULA_AUD0DAT:				dc.l			0				; long word en cours d'utilisation / stocké / buffering
LSP_DSP_PAULA_internal_location0:	dc.l			silence<<nb_bits_virgule_offset				; internal register : location of the sample currently played
LSP_DSP_PAULA_internal_increment0:	dc.l			0				; internal register : increment linked to period 16:16
LSP_DSP_PAULA_internal_length0:		dc.l			(silence+4)<<nb_bits_virgule_offset			; internal register : length of the sample currently played
LSP_DSP_repeat_pointeur0:			dc.l			silence<<nb_bits_virgule_offset
LSP_DSP_repeat_length0:				dc.l			(silence+4)<<nb_bits_virgule_offset
; channel 1
LSP_DSP_PAULA_AUD1L:				dc.l			silence<<nb_bits_virgule_offset			; Audio channel 0 location
LSP_DSP_PAULA_AUD1LEN:				dc.l			(silence+4)<<nb_bits_virgule_offset			; en bytes !
LSP_DSP_PAULA_AUD1PER:				dc.l			0				; period , a transformer en increment
LSP_DSP_PAULA_AUD1VOL:				dc.l			0				; volume
LSP_DSP_PAULA_AUD1DAT:				dc.l			0				; long word en cours d'utilisation / stocké / buffering
LSP_DSP_PAULA_internal_location1:	dc.l			silence<<nb_bits_virgule_offset				; internal register : location of the sample currently played
LSP_DSP_PAULA_internal_increment1:	dc.l			0				; internal register : increment linked to period 16:16
LSP_DSP_PAULA_internal_length1:		dc.l			(silence+4)<<nb_bits_virgule_offset			; internal register : length of the sample currently played
LSP_DSP_repeat_pointeur1:			dc.l			silence<<nb_bits_virgule_offset
LSP_DSP_repeat_length1:				dc.l			(silence+4)<<nb_bits_virgule_offset
; channel 2
LSP_DSP_PAULA_AUD2L:				dc.l			silence<<nb_bits_virgule_offset			; Audio channel 0 location
LSP_DSP_PAULA_AUD2LEN:				dc.l			(silence+4)<<nb_bits_virgule_offset			; en bytes !
LSP_DSP_PAULA_AUD2PER:				dc.l			0				; period , a transformer en increment
LSP_DSP_PAULA_AUD2VOL:				dc.l			0				; volume
LSP_DSP_PAULA_AUD2DAT:				dc.l			0				; long word en cours d'utilisation / stocké / buffering
LSP_DSP_PAULA_internal_location2:	dc.l			silence<<nb_bits_virgule_offset				; internal register : location of the sample currently played
LSP_DSP_PAULA_internal_increment2:	dc.l			0				; internal register : increment linked to period 16:16
LSP_DSP_PAULA_internal_length2:		dc.l			(silence+4)<<nb_bits_virgule_offset			; internal register : length of the sample currently played
LSP_DSP_repeat_pointeur2:			dc.l			silence<<nb_bits_virgule_offset
LSP_DSP_repeat_length2:				dc.l			(silence+4)<<nb_bits_virgule_offset
; channel 3
LSP_DSP_PAULA_AUD3L:				dc.l			silence<<nb_bits_virgule_offset			; Audio channel 0 location																0
LSP_DSP_PAULA_AUD3LEN:				dc.l			(silence+4)<<nb_bits_virgule_offset			; en bytes !																		+4
LSP_DSP_PAULA_AUD3PER:				dc.l			0				; period , a transformer en increment																			+8
LSP_DSP_PAULA_AUD3VOL:				dc.l			0				; volume																										+12
LSP_DSP_PAULA_AUD3DAT:				dc.l			0				; long word en cours d'utilisation / stocké / buffering															+16
LSP_DSP_PAULA_internal_location3:	dc.l			silence<<nb_bits_virgule_offset				; internal register : location of the sample currently played						+20
LSP_DSP_PAULA_internal_increment3:	dc.l			0				; internal register : increment linked to period 16:16															+24
LSP_DSP_PAULA_internal_length3:		dc.l			(silence+4)<<nb_bits_virgule_offset			; internal register : length of the sample currently played							+28
LSP_DSP_repeat_pointeur3:			dc.l			silence<<nb_bits_virgule_offset																		;							+32
LSP_DSP_repeat_length3:				dc.l			(silence+4)<<nb_bits_virgule_offset																	;							+36




offset_LSP_DSP_PAULA_internal_location0		.equ			((LSP_DSP_PAULA_internal_location0-LSP_PAULA)/4)

; tableau des variables
LSP_variables_table:
; channel 3
		dc.l		LSP_DSP_PAULA_internal_location3
		dc.l		LSP_DSP_PAULA_internal_increment3
		dc.l		LSP_DSP_PAULA_internal_length3
		dc.l		LSP_DSP_PAULA_AUD3LEN
		dc.l		LSP_DSP_PAULA_AUD3L
;channel 2
		dc.l		LSP_DSP_PAULA_internal_location2
		dc.l		LSP_DSP_PAULA_internal_increment2
		dc.l		LSP_DSP_PAULA_internal_length2
		dc.l		LSP_DSP_PAULA_AUD2LEN
		dc.l		LSP_DSP_PAULA_AUD2L
;channel 1
		dc.l		LSP_DSP_PAULA_internal_location1
		dc.l		LSP_DSP_PAULA_internal_increment1
		dc.l		LSP_DSP_PAULA_internal_length1
		dc.l		LSP_DSP_PAULA_AUD1LEN
		dc.l		LSP_DSP_PAULA_AUD1L
;channel 0
		dc.l		LSP_DSP_PAULA_internal_location0
		dc.l		LSP_DSP_PAULA_internal_increment0
		dc.l		LSP_DSP_PAULA_internal_length0
		dc.l		LSP_DSP_PAULA_AUD0LEN
		dc.l		LSP_DSP_PAULA_AUD0L



LSPVars:
m_byteStream:		dc.l	0	;  0 :  byte stream							0
m_wordStream:		dc.l	0	;  4 :  word stream							1
m_codeTableAddr:	dc.l	0	;  8 :  code table addr						2
m_escCodeRewind:	dc.l	0	; 12 :  rewind special escape code			3
m_escCodeSetBpm:	dc.l	0	; 16 :  set BPM escape code					4
m_lspInstruments:	dc.l	0	; 20 :  LSP instruments table addr			5
m_relocDone:		dc.l	0	; 24 :  reloc done flag						6
m_currentBpm:		dc.l	0	; 28 :  current BPM							7
m_byteStreamLoop:	dc.l	0	; 32 :  byte stream loop point				8
m_wordStreamLoop:	dc.l	0	; 36 :  word stream loop point				9



LSP_BPM_frequence_replay:		dc.l			25

; pads
; Pads : mask = xxxxxxCx xxBx2580 147*oxAP 369#RLDU
; U235 format
;------------------------------------------------------------------------------------------------ Joypad Section

										; Pads : mask = xxxxxxCx xxBx2580 147*oxAP 369#RLDU

; 												Bit numbers for buttons in the mask for testing individual bits
U235SE_BBUT_UP			EQU		0		; Up
U235SE_BBUT_U			EQU		0
U235SE_BBUT_DOWN		EQU		1		; Down
U235SE_BBUT_D			EQU		1
U235SE_BBUT_LEFT		EQU		2		; Left
U235SE_BBUT_L			EQU		2
U235SE_BBUT_RIGHT		EQU		3		; Right
U235SE_BBUT_R			EQU		3		
U235SE_BBUT_HASH		EQU		4		; Hash (#)
U235SE_BBUT_9			EQU		5		; 9
U235SE_BBUT_6			EQU		6		; 6
U235SE_BBUT_3			EQU		7		; 3
U235SE_BBUT_PAUSE		EQU		8		; Pause
U235SE_BBUT_A			EQU		9		; A button
U235SE_BBUT_OPTION		EQU		11		; Option
U235SE_BBUT_STAR		EQU		12		; Star 
U235SE_BBUT_7			EQU		13		; 7
U235SE_BBUT_4			EQU		14		; 4
U235SE_BBUT_1			EQU		15		; 1
U235SE_BBUT_0			EQU		16		; 0 (zero)
U235SE_BBUT_8			EQU		17		; 8
U235SE_BBUT_5			EQU		18		; 5
U235SE_BBUT_2			EQU		19		; 2
U235SE_BBUT_B			EQU		21		; B button
U235SE_BBUT_C			EQU		25		; C button

; 												Numerical representations
U235SE_BUT_UP			EQU		1		; Up
U235SE_BUT_U			EQU		1
U235SE_BUT_DOWN			EQU		2		; Down
U235SE_BUT_D			EQU		2
U235SE_BUT_LEFT			EQU		4		; Left
U235SE_BUT_L			EQU		4
U235SE_BUT_RIGHT		EQU		8		; Right
U235SE_BUT_R			EQU		8		
U235SE_BUT_HASH			EQU		16		; Hash (#)
U235SE_BUT_9			EQU		32		; 9
U235SE_BUT_6			EQU		64		; 6
U235SE_BUT_3			EQU		$80		; 3
U235SE_BUT_PAUSE		EQU		$100	; Pause
U235SE_BUT_A			EQU		$200	; A button
U235SE_BUT_OPTION		EQU		$800	; Option
U235SE_BUT_STAR			EQU		$1000	; Star 
U235SE_BUT_7			EQU		$2000	; 7
U235SE_BUT_4			EQU		$4000	; 4
U235SE_BUT_1			EQU		$8000	; 1
U235SE_BUT_0			EQU		$10000	; 0 (zero)
U235SE_BUT_8			EQU		$20000	; 8
U235SE_BUT_5			EQU		$40000	; 5
U235SE_BUT_2			EQU		$80000	; 2
U235SE_BUT_B			EQU		$200000	; B button
U235SE_BUT_C			EQU		$2000000; C button

; xxxxxxCx xxBx2580 147*oxAP 369#RLDU
DSP_pad1:				dc.l		0
DSP_pad2:				dc.l		0



	.phrase

;---------------------
; FIN DE LA RAM DSP
YM_DSP_fin:
;---------------------


SOUND_DRIVER_SIZE			.equ			YM_DSP_fin-DSP_base_memoire
	.print	"--- Sound driver code size (DSP): ", /u SOUND_DRIVER_SIZE, " bytes / 8192 ---"


		
		.68000
		.dphrase

		.data

		.phrase
; YPOS, HEIGHT, LINK, DATA, XPOS,DEPTH,PITCH=1,DWIDTH=2,IWIDTH=2,TRANS
; bitmap data addr, xloc, yloc, dwidth, iwidth, iheight, bpp, pallete idx, flags, firstpix, pitch
ob_liste_originale:
		.objproc    ; Engage the OP assembler
        .org    ob_list_1
	    branch      VC < 0, .stahp     ; Branch to the STOP object if VC < 69
        branch      VC > 241, .stahp    ; Branch to the STOP object if VC > 241
        bitmap      ecran_intro, 16, 28, 40,40,200,3,1
        jump        .haha
		stop
.stahp:
        stop
.haha:
        jump        .stahp
		stop
		stop
		.dphrase
fin_ob_liste_originale:
	
		.68000
		.data	
		.dphrase

.dphrase:
ob_liste_stop:
		.objproc    ; Engage the OP assembler
		gpuobj 100,100
		stop
		stop
		stop
		.68000
		.data	
		.dphrase


; LSP
silence:		
		dc.b			$0,$0,$0,$0
fin_silence:
		dc.b			$0,$0,$0,$0
		dc.b			$0,$0,$0,$0


debut_ram_libre_DSP:		dc.l			YM_DSP_fin
debut_ram_libre:			dc.l			FIN_RAM
	even

	.phrase
LSP_module_music_data:
	.incbin				"art.lsmusic"
	;.incbin			"LSP/d.lsmusic"				; test module
	
	.phrase
LSP_module_sound_bank:
	.incbin				"art.lsbank"
	;.incbin			"LSP/d.lsbank"				; test module
	even
LSP_module_sound_bank_fin:
	dc.l				0,0,0,0,0,0,0,0
	.dphrase

.phrase:
GPU_vitesse_scrolling:						dc.l			vitesse_scrolling


;---------
	.phrase
liste_points_calcules:
			.rept		nb_colonnes_de_sprites_a_afficher*nb_lignes_de_sprites_a_afficher
			dc.l		0					; X.w Y.w
			.endr

tailles_des_caracteres:
;standard = 11
; complete à 16 car 4 bits.4bits
		dc.b		11,03,11,11,11,11,11,03,04,04,0,0,0,0,0,0			; ()
		dc.b		11,11,04,05,03,11,11,04,11,11,0,0,0,0,0,0			;   ,-. 0123
		dc.b		11,11,11,11,11,11,03,11,11,11,0,0,0,0,0,0			; 456
		dc.b		11,11,11,11,11,11,11,11,11,11,0,0,0,0,0,0			; ? ABCDEFG
		dc.b		11,04,11,11,11,12,11,11,11,11,0,0,0,0,0,0			; HIJKLMNOPQ
		dc.b		11,11,11,11,12,12,11,11,11,11,0,0,0,0,0,0			; RSTUVWXYZ
		even

texte_scrolling:
		dc.b        "  Yuk, another megascroller!"
		dc.b        fSin1, colrB, "   But this seems to be a very special one..."  
		dc.b        fRot1, colrY, "   Don't you think so?"  
		dc.b        fBce1, colrP, "   ST Connexion presents its first demo-screen since 1989, called:"  
		dc.b        fCyld, colrY, "   Let's do the twist again!"  
		dc.b        fTria, colrB, "   A demo masterminded by Alien."  
		dc.b        fSin2, colrP, "   Would you like to see some more bobs? Ok:"  
		dc.b        fRot2, colrY, "   # ## ### ######"  
		dc.b        fGrow, colrP, "   You just saw 384 masked 3-bitplane bobs per VBL..."  
		dc.b        fRot1, colrY, "   Anyway, let's have some greetings now."  
		dc.b        fTria, colrP, "   First the megagreetings. They go to:"  
		dc.b        fTria, flgDE, "   Delta Force"  
		dc.b        fGrow, flgFR, "   Legacy"  
		dc.b        fGrow, flgFR, "   Overlanders"  
		dc.b        fCyld, flgFR, "   Poltergeist"  
		dc.b        fSin2, flgDE, "   TEX"  
		dc.b        fGrow, flgFR, "   Vegetables."  
		dc.b        fNoop, colrB, "   Normal greetings go to:"  
		dc.b        fNoop, flgFR, "   1984    ABCS 85"  
		dc.b        fTria, flgDE, "   ACF"  
		dc.b        fTria, flgFR, "   Mathias Agopian"  
		dc.b        fRot1, flgFR, "   Alcatraz"  
		dc.b        fSin1, flgDE, "   BMT"  
		dc.b        fSin1, flgFR, "   DNT Crew"  
		dc.b        fGrow, flgBE, "   Dr. Satan"  
		dc.b        fNoop, flgGB, "   Dynamic Duo"  
		dc.b        fCyld, flgSE, "   Electra"  
		dc.b        fTria, flgGB, "   Electronic Images"  
		dc.b        fSin2, flgFR, "   Equinox"  
		dc.b        fGrow, flgNL, "   Eternal"  
		dc.b        fRot2, flgSC, "   Fingerbobs"  
		dc.b        fBce2, flgSE, "   Flexible Front"  
		dc.b        fBce2, flgNL, "   Galtan 6"  
		dc.b        fBce1, flgFR, "   Laurent Z."  
		dc.b        fBce1, flgBE, "   Lem and Nic"  
		dc.b        fTria, flgFR, "   Mad Vision"  
		dc.b        fGrow, flgFR, "   MCoder"  
		dc.b        fRot2, flgFR, "   Naos"  
		dc.b        fBce2, flgGB, "   Neil of Cor Blimey"  
		dc.b        fCyld, flgDE, "   Newline"  
		dc.b        fCyld, flgFR, "   Next    NGC"  
		dc.b        fBce1, flgSE, "   Omega    Phalanx"  
		dc.b        fBce1, flgFR, "   Prism    Quartex"  
		dc.b        fGrow, flgES, "   Red Devil"  
		dc.b        fNoop, flgDE, "   The Respectables"  
		dc.b        fSin1, flgGB, "   Ripped Off"  
		dc.b        fRot2, flgAU, "   Sewer Software"  
		dc.b        fTria, flgFR, "   Silents"  
		dc.b        fBce1, flgPT, "   Paulo Simoes"  
		dc.b        fCyld, flgCH, "   Spreadpoint"  
		dc.b        fNoop, flgFR, "   ST Magazine"  
		dc.b        fNoop, flgNL, "   ST News"  
		dc.b        fNoop, flgDE, "   Sven Meyer"  
		dc.b        fBce2, flgSE, "   Sync"  
		dc.b        fBce1, flgSE, "   TCB"  
		dc.b        fGrow, flgCH, "   TDA"  
		dc.b        fGrow, flgGB, "   TLB"  
		dc.b        fGrow, flgDE, "   TNT-Crew"  
		dc.b        fSin2, flgDE, "   TOS Magazin"  
		dc.b        fSin2, flgFR, "   Tsunoo Rhilty"  
		dc.b        fRot2, flgDE, "   TVI"  
		dc.b        fGrow, flgLU, "   ULM"  
		dc.b        fGrow, flgFR, "   Undead"  
		dc.b        fCyld, flgGB, "   XXX International"  
		dc.b        fCyld, flgFR, "   Yoda"  
		dc.b        fCyld, flgFR, "   Zarathoustra."  
		dc.b        fNoop, colrP, "   Alien's special greetings are flying over to:"  
		dc.b        fSin2, flgFR, "   Atm    Alain Hurtig    Nicolas Chouckroun"  
		dc.b        fTria, flgDE, "   Flix    Big Alec"  
		dc.b        fSin1, flgGB, "   Manikin"  
		dc.b        fSin1, flgNL, "   Digital Insanity"  
		dc.b        fSin2, flgFR, "   Fury"  
		dc.b        fGrow, flgLU, "   Gunstick"  
		dc.b        fRot2, flgFR, "   Dbug II"  
		dc.b        fTria, flgDE, "   ES    Gogo"  
		dc.b        fGrow, flgSE, "   Tanis"  
		dc.b        fRot1, flgFR, "   Gordon    Thomas Landspurg"  
		dc.b        fBce1, flgGB, "   Kreator    4mat"  
		dc.b        fTria, flgFR, "   Moby    Audio Monster"  
		dc.b        fNoop, colrP, "   Douglas Adams and Rodney Matthews.    Now a little comment about ripping..."  
		dc.b        fSin1, colrY, "   ST Connexion's policy is the following:"  
		dc.b        fGrow, colrP, "   All our code is copyrighted and may not be re-used in any program or modified in any way whatsoever."  
		dc.b        fNoop, colrB, "   It is also illegal to distribute it under any form other than that in which it was released:"  
		dc.b        fSin2, colrP, "   Delta Force's Punish Your Machine Demo."  
		dc.b        fNoop, colrY, "   If you wonder why we have such a strict policy, it is because some commercial lamers helped themselves to parts of our code, as well as inumerable groups."  
		dc.b        fSin1, colrP, "   Some hints about the 4-bit hardware scroller coming up...    In January 1991, I (Alien) got my 4-bit hardware-scroller to work."  
		dc.b        fSin2, colrP, "   It allows you to move the whole screen left and right by increments of 4 pixels. The source has been published in my series of articles about overscan in ST Magazine, a French publication."  
		dc.b        fTria, colrY, "   As this technique is brand-new, it may not work on some Atari ST's. If it doesn't work on yours, please contact us."  
		dc.b        fBce2, colrB, "   Time to grab a pen..........    To obtain 4 bit hardware scrolling on an ST, you have to switch to midrez after the passage to hirez used to free the left border, and then wait 0,4,8,12 cycles before switching back to lowrez."  
		dc.b        fNoop, colrP, "   This affects the way the shifter works, and delays the displaying of the picture by a multiple of 500 nanoseconds, which results in an effective shift in the picture..."  
		dc.b        fSin2, colrY, "   Note the method described here does not work on some STE's.   Time is up, so let's cut the crap:"  
		dc.b        fRot1, colrB, "   According to Vickers of Legacy sitting next to us, you've been reading this text for over an hour..."  
		dc.b        fCyld, colrP, "   But the original version was over 10 kb long, ensuring 4 hours of pleasant reading!"  
		dc.b        fGrow, colrY, "   See you in the next St Connexion Production, scheduled to be released within the next 2 years!                                 "  
		dc.b		GPU_scrolling_code_de_controle_code_fin_de_texte,"   "
fin_texte_scrolling:
	even

		

.dphrase
bob:
	.incbin		"bobs_alien.png_JAG"
fin_bob:
; 256 * 16 bits de couleur
; 16 * 120 = 16 * 15 * 8
; 16x8
	even
	

; fonte 1 plan, 1 octet par pixel
; 120 x 102
; 10 x 6
; une lettre = 12 (largeur ) x 17 (hauteur)
; 10 lettres par ligne
; 6 lignes
; hauteur lettre = 16
; ecart ligne = 17
; largeur lettre =11
; ecart lettre = 12

fonte:
	.incbin		"font_alien.png_JAG_1byteperpixel"
fin_fonte:
	even

table_des_formes:
		dc.l		table_forme_0,fin_table_forme_0		; No effect		
		dc.l		table_forme_1,fin_table_forme_1     ; Sine 1		
		dc.l		table_forme_2,fin_table_forme_2     ; Sine 2		
		dc.l		table_forme_3,fin_table_forme_3     ; Bounce 1		
		dc.l		table_forme_4,fin_table_forme_4     ; Bounce 2		
		dc.l		table_forme_5,fin_table_forme_5     ; Rotate slow	
		dc.l		table_forme_6,fin_table_forme_6     ; Rotate quick	
		dc.l		table_forme_7,fin_table_forme_7     ; Cylinder		
		dc.l		table_forme_8,fin_table_forme_8     ; Triangle		
		dc.l		table_forme_9,fin_table_forme_9     ; Pack/Unpack	
		
		
		

;-------------
table_forme_0:
	.include	"STCNX_forme0.s"
fin_table_forme_0:
;-------------
table_forme_1:
	.include	"STCNX_forme1.s"
fin_table_forme_1:
;-------------
table_forme_2:
	.include	"STCNX_forme2.s"
fin_table_forme_2:
;-------------
table_forme_3:
	.include	"STCNX_forme3.s"
fin_table_forme_3:
;-------------
table_forme_4:
	.include	"STCNX_forme4.s"
fin_table_forme_4:
;-------------
table_forme_5:
	.include	"STCNX_forme5.s"
fin_table_forme_5:
;-------------
table_forme_6:
	.include	"STCNX_forme6.s"
fin_table_forme_6:
;-------------
table_forme_7:
	.include	"STCNX_forme7.s"
fin_table_forme_7:
;-------------
table_forme_8:
	.include	"STCNX_forme8.s"
fin_table_forme_8:
;-------------
table_forme_9:
	.include	"STCNX_forme9.s"
fin_table_forme_9:

	.dphrase
texte_intro1:
	.incbin		"intro-text.png_JAG_1byteperpixel"
	even
	

	.dphrase
image_debut:
	.incbin		"intro-bg.png_JAG"
	even


		.dphrase

		.BSS
	.phrase
DEBUT_BSS:
; LSP
frequence_Video_Clock:					ds.l				1
frequence_Video_Clock_divisee :			ds.l				1
; -------------

_50ou60hertz:	ds.l	1
ntsc_flag:				ds.w	1
a_hdb:          		ds.w   1
a_hde:          		ds.w   1
a_vdb:          		ds.w   1
a_vde:          		ds.w   1
width:          		ds.w   1
height:         		ds.w   1

	.phrase
taille_liste_OP:		ds.l	1
vbl_counter:			ds.l	1

ecran_intro:
		ds.b			320*200

	.phrase
FIN_RAM:


	.if		1=0
	; calcul une colonne de sprites
; le X avance de 4 en 4

; calcul du Y

		movei	#GPU_ligne_haute,R0
		movei	#GPU_ligne_basse,R4
		load	(R0),R11				; Y haut 
		load	(R4),R23				; Y bas
		sub		R11,R23					; distance entre les 2 lignes, peut etre négatif en cas de retournement
		sharq	#4,R23					; / 16 = ecart entre chaque ligne de la colonne = increment Y

		moveq	#0,R0
		moveq	#15,R12					; nb de lignes
		movei	#GPU_boucle_1colonne,R24

		moveq		#4,R23

; premier Y = R1
; increment Y = R23
; X = R0
GPU_boucle_1colonne:
		move	R11,R1					; Y
		

		movefa		R3,R3


; crée un objet dans l'OL pointée par R3
;
; input : X / Y / pointeur sur data sprite /
; calculés : LINK / 
; toujours identique : HEIGHT / DEPTH / PITCH / DWIDTH / IWIDTH / TRANS

 ;63       56        48        40       32        24       16       8        0
 ; +--------^---------^-----+------------^--------+--------^--+-----^----+---+
 ; |        data-address    |     Link-address    |   Height  |   YPos   |000|
 ; +------------------------+---------------------+-----------+----------+---+
 ;     63 .............43        42.........24      23....14    13....3   2.0
 ;          21 bits                 19 bits        10 bits     11 bits  3 bits
 ;                                   (11.8)

; 63       56        48        40       32       24       16        8        0
;  +--------^-+------+^----+----^--+-----^---+----^----+---+---+----^--------+
;  | unused   |1stpix| flag|  idx  | iwidth  | dwidth  | p | d |   x-pos     |
;  +----------+------+-----+-------+---------+---------+---+---+-------------+
;    63...55   54..49 48.45  44.38   37..28    27..18 17.15 14.12  11.....0
;      9bit      6bit  4bit   7bit    10bit    10bit   3bit 3bit    12bit
;                                    (6.4)

; R3=object list debut
; R0=X=150
; R1=Y=120
		
		
		movei	#512,R5
		add		R5,R3			; object list + branch du debut
		move	R1,R9			; R9=YPOS
		subq	#20,R1			; Y-haut de l'ecran
		movei	#1664,R4
		sharq	#3,R1			; Y/8
		mult	R4,R1			; Y*1664
		add		R1,R3			; position Y dans l'object list

		move	R3,R5
		addq	#16,R5			; R5=LINK
		
		movei	#$00020000,R6	; R6 = HEIGHT=8 + 000
		movei	#bob+512,R7		; DATA
		sharq	#3,R7			; DATA sur phrase
		shlq	#11,R7			; decalage DATA
		sharq	#3,R5			; LINK sur phrase
		move	R5,R8			; R8=LINK pour 2eme long mot
		
		sharq	#8,R5			; LINK pour le 1er mot
		or		R5,R7			; data+LINK pour 1er mot de la 1ere phrase
		store	R7,(R3)
		addq	#4,R3
		shlq	#24,R8			;R8=LINK pour 2eme mot
		or		R8,R6			; LINK + HEIGHT + 000
		shlq	#3+1,R9			; ( YPOS * 2 (half line)  ) << 3
		or		R9,R6			; LINK + HEIGHT + YPOS + 000
		store	R6,(R3)			; 2eme mot 1ere phrase
		addq	#4,R3

		movei	#$2008B000,R1	; depth = 3 / Pitch=1 / DWIDTH=2 / IWIDTH=2 
		or		R0,R1			; + XPOS
		movei	#$8000,R2		; TRANS=1
		store	R2,(R3)
		addq	#4,R3
		store	R1,(R3)
		addq	#4,R3

; boucle ligne suivante

		add		R23,R11			; Y=Y+increment ecart
		subq	#1,R12			; nb lignes - 1 
		cmpq	#0,R12
		jump	ne,(R24)
		nop
		


;insere un stop
		moveq	#0,R0
		moveq	#4,R1
		store	R0,(R3)
		addq	#4,R3
		store	R1,(R3)

		.endif
		
