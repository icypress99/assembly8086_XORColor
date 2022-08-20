
STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	TIME_AUX DB 00H							;TIME
	REC_WIDTH DW 2FH						;RECTANGLE WITH
	REC_HEIGHT DW 1FH						;RECTANGLE HEIGHT
	REC_X DW 0AH							;X POSITION OF RECTANGLE
	REC_Y DW 0AH							;Y POSITION OF RECTANGLE
	REC_VELOCITY_X DW 05H					
	REC_VELOCITY_Y DW 05H
	

	C_WIDTH DW 3FH							;RECTANGLE WITH
	C_HEIGHT DW 2FH							;RECTANGLE HEIGHT
	C_X DW 100H								;X POSITION OF RECTANGLE
	C_Y DW 100H								;Y POSITION OF RECTANGLE

	
	WINDOWS_WIDTH DW 140H					;WINDOWS WIDTH
	WINDOWS_HIGHT DW 0C8H					;WINDOWS HIGHT
	
	COLOR DB 0H

	
	
DATA ENDS
	
CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
		ASSUME CS:CODE,DS:DATA,SS:STACK      ;assume as code,data and stack segments the respective registers
		PUSH DS                              ;push to the stack the DS segment
		SUB AX,AX                            ;clean the AX register
		PUSH AX                              ;push AX to the stack
		MOV AX,DATA                          ;save on the AX register the contents of the DATA segment
		MOV DS,AX                            ;save on the DS segment the contents of AX
		POP AX                               ;release the top item from the stack to the AX register
		POP AX                               ;release the top item from the stack to the AX register

		MOV AL,13h
		MOV AH,0
		INT 10h             ; set video mode

		CHECK_TIME:
		
			MOV AH,2CH						;GET SYSTEM TIME DL = 1/100 S
			INT 21H 
			
			CMP DL,TIME_AUX					;check current time is equal to previus one or not
			JE CHECK_TIME
			
			MOV TIME_AUX,DL					;UPDATE TIME
			
			CALL CLEAR_SCREEN				;CLEAR SCREEN
			CALL DRAW_REC					;DRAW RECTANGLE 1
			CALL MOVE_REC					;CAN MOVE RECTANGLE 1
			CALL DRAW_C						;DRAW RECTANGLE 2
			
			
		
		JMP CHECK_TIME						; GO AGAIN
		RET		
	MAIN ENDP
	
	CLEAR_SCREEN PROC NEAR               	;clear the screen by restarting the video mode
	
			MOV CX,0
			MOV DH,0C8H
			MOV DL,90H
			mov ah,06H
			mov al,0
			MOV BH,00H
			int 10h
			RET
			
	CLEAR_SCREEN ENDP

	DRAW_REC PROC NEAR		
		MOV CX, REC_X						;SET Y CURSOR X POSITION OF RECTANGLE 1
		MOV DX, REC_Y						;SET X CURSOR Y POSITION OF RECTANGLE 1
				
		DRAW_REC_HIROZENTALLY:
			MOV AH,0CH						;DRAW PIXEL
			MOV BH,00H						;PAGE NUMBER 0
			MOV AL,02H						;GREEN COLOR
			INT 10H
			
			INC CX							;INCREASE COLUMN
			MOV AX,CX						
			SUB AX,REC_X					;CURRENT POSIONT X - START POSIOTION X
			CMP AX,REC_WIDTH				
			JNG DRAW_REC_HIROZENTALLY		;IF CURRENT POSIONT X - START POSIOTION X <= RECTANGLE WIDTH THEN JUMP UNTILL DRAW HIROZENTALLY BE COMPLETE
				
			MOV CX,REC_X					;CX GO AT THE START AGAIN
			INC DX							;INCREASE ROW
			
			MOV AX,DX						
			SUB AX,REC_Y					;CURRENT POSIONT Y - START POSIOTION Y
			CMP AX,REC_HEIGHT
			JNG DRAW_REC_HIROZENTALLY		;IF CURRENT POSIONT Y - START POSIOTION Y <= RECTANGLE HEIGHT THEN JUMP UNTILL DRAW VERTICALLY BE COMPLETE
	
		RET
	DRAW_REC ENDP
	
	
	MOVE_REC PROC NEAR 
		
		;CHECK ANY KEY PRESSED IF NOT EXIT
		
			MOV AH,01H
			INT 16H
			JZ EXIT_MOVEMENT_REC			;ZF = 1 JZ->JUMP
		
		;CHECK WHICH KEY
		
			MOV AH,00H
			INT 16H
		
		;IF W OR w GO UP
			CMP AL,77H
			JE REC_GO_UP
			CMP AL,57H
			JE REC_GO_UP
		;IF S OR s GO DOWN
			CMP AL,73H
			JE REC_GO_DOWN
			CMP AL,53H
			JE REC_GO_DOWN
		;IF D OR d GO RIGHT
			CMP AL,64H
			JE REC_GO_RIGHT
			CMP AL,44H
			JE REC_GO_RIGHT
		;IF A OR a GO LEFT
			CMP AL,61H
			JE REC_GO_LEFT
			CMP AL,41H
			JE REC_GO_LEFT
		
		REC_GO_UP:
			MOV AX,REC_VELOCITY_Y
			SUB REC_Y,AX
			
			CMP REC_Y,00H
			JNG FIX_TOP_POSIOTION			;IF REC_Y < 0  THEN JUMP 
			RET
		REC_GO_DOWN:
			MOV AX,REC_VELOCITY_Y
			ADD REC_Y,AX
			
			MOV AX,WINDOWS_HIGHT
			SUB AX,REC_HEIGHT
			CMP REC_Y,AX
			JNL FIX_BOTTOM_POSIOTION		;IF REC_Y => WINDOWS_HIGHT - REC_HEIGHT THEN JUMP
			
			RET
		REC_GO_LEFT:
			MOV AX,REC_VELOCITY_X
			SUB REC_X,AX
			
			CMP REC_X,00H
			JNG FIX_LEFT_POSIOTION			;IF REC_X < 0 THEN JUMP
			RET
		REC_GO_RIGHT:
			MOV AX,REC_VELOCITY_X
			ADD REC_X,AX
			
			MOV AX,WINDOWS_WIDTH
			SUB AX,REC_WIDTH
			CMP REC_X,AX
			JNL FIX_RIGHT_POSIOTION			;IF REC_X => WINDOWS_WIDTH - REC_WIDTH THEN JUMP
			RET		
		FIX_TOP_POSIOTION:
			MOV REC_Y,AX
			RET
		FIX_BOTTOM_POSIOTION:
			DEC AX
			MOV REC_Y,AX
			RET
		FIX_LEFT_POSIOTION:
			MOV REC_X,AX
			RET
		FIX_RIGHT_POSIOTION:
			DEC AX
			MOV REC_X,AX
			RET
			
		EXIT_MOVEMENT_REC:
		
				
		RET
	MOVE_REC ENDP
	
	
	DRAW_C PROC NEAR	
		MOV CX, C_X							;SET Y CURSOR X POSITION OF RECTANGLE 2
		MOV DX, C_Y				            ;SET X CURSOR Y POSITION OF RECTANGLE 2
				
		DRAW_C_HIROZENTALLY:
			MOV AL,00H						;MAKE AX ZERO
			MOV AH,0DH						;GET PIXEL COLOR AT CX,DX
			INT 10H 
			MOV COLOR,AL					;SAVR PIXEL COLOR
			
			MOV AH,0CH						;DRAW PIXEL
			MOV BH,00H                      ;PAGE NUMBER 0
			MOV AL,0FH                      ;WHITE COLOR
			XOR AL,COLOR					;XOR COLOR WITH THAT COLOR IT IS ON IT
			INT 10H
			
			INC CX							;INCREASE COLUMN
			MOV AX,CX                       
			SUB AX,C_X                      ;CURRENT POSIONT X - START POSIOTION X
			CMP AX,C_WIDTH                  
			JNG DRAW_C_HIROZENTALLY         ;IF CURRENT POSIONT X - START POSIOTION X <= RECTANGLE WIDTH THEN JUMP UNTILL DRAW HIROZENTALLY BE COMPLET
				                            
			MOV CX,C_X                      ;CX GO AT THE START AGAIN
			INC DX                          ;INCREASE ROW
			                                
			MOV AX,DX                       
			SUB AX,C_Y                      ;CURRENT POSIONT Y - START POSIOTION Y
			CMP AX,C_HEIGHT                 
			JNG DRAW_C_HIROZENTALLY         ;IF CURRENT POSIONT Y - START POSIOTION Y <= RECTANGLE HEIGHT THEN JUMP UNTILL DRAW VERTICALLY BE COMPLETE
	
		RET
	DRAW_C ENDP
	

	
	
CODE ENDS
END









