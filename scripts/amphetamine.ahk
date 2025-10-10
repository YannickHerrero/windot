; AutoHotkey v2 - Natural Mouse Movement Script
; Moves mouse 20px with natural movement every 4 minutes

; Set timer for 4 minutes (240000 milliseconds)
SetTimer(NaturalMouseMove, 240000)

NaturalMouseMove() {
    ; Get current mouse position
    MouseGetPos(&startX, &startY)
    
    ; Calculate target position (20px away in random direction)
    angle := Random(0, 360) * 3.14159 / 180  ; Random angle in radians
    targetX := Round(startX + 20 * Cos(angle))
    targetY := Round(startY + 20 * Sin(angle))
    
    ; Move to target with natural curve
    steps := Random(8, 15)  ; Random number of steps for natural movement
    
    Loop steps {
        ; Calculate intermediate position with slight randomness
        progress := A_Index / steps
        
        ; Add some curve to the movement
        curve := Sin(progress * 3.14159) * Random(-3, 3)
        
        currentX := Round(startX + (targetX - startX) * progress + curve)
        currentY := Round(startY + (targetY - startY) * progress + curve)
        
        ; Move mouse to intermediate position
        MouseMove(currentX, currentY, 0)
        
        ; Small random delay between steps
        Sleep(Random(5, 15))
    }
    
    ; Brief pause at target position
    Sleep(Random(50, 150))
    
    ; Return to original position with natural movement
    Loop steps {
        progress := A_Index / steps
        curve := Sin(progress * 3.14159) * Random(-2, 2)
        
        currentX := Round(targetX + (startX - targetX) * progress + curve)
        currentY := Round(targetY + (startY - targetY) * progress + curve)
        
        MouseMove(currentX, currentY, 0)
        Sleep(Random(5, 15))
    }
}

; Press Ctrl+Alt+Q to exit the script
^!q::ExitApp