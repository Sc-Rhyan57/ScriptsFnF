local chaosMode = {}

local events = {
    "swapNotes",
    "randomizeNoteSpeeds",
    "shakeNotes",
    "spinNotes",
    "cameraZoomOut",
    "cameraShake",
    "flashScreen",
    "reverseLanes",
    "noteFade",
    "rainbowNotes",
    "stealthNotes",
    "speedUp",
    "slowDown",
    "invertControls",
    "randomNoteSizes",
    "jitteringNotes",
    "verticalNotes",
    "zigZagNotes",
    "sineWaveNotes",
    "hiddenReceptors",
    "flipScreen",
    "dizzyCamera",
    "noteJumping",
    "misplaceHUD",
    "randomizeScrollDirections",
    "ghostNotes",
    "confusingColors",
    "switchPlayfield",
    "bounceNotes",
    "diagonalNotes"
}

local activeEffects = {}
local eventTimers = {}
local eventDurations = {}
local isEnabled = false
local defaultNotePos = {}
local defaultHUDPos = {}
local defaultCamZoom = 0
local defaultSpeed = 0
local originalNoteAlpha = {}
local swappedNotes = false
local invertedControls = false
local reversedLanes = false
local screensFlipped = false
local originalHealth = 0
local hudMisplaced = false

function chaosMode.initialize()
    isEnabled = true
    math.randomseed(os.time())
    
    for i = 0, 7 do
        defaultNotePos[i] = {getPropertyFromGroup('strumLineNotes', i, 'x'), getPropertyFromGroup('strumLineNotes', i, 'y')}
        originalNoteAlpha[i] = getPropertyFromGroup('strumLineNotes', i, 'alpha')
    end
    
    defaultHUDPos = {
        scoreTxt = {getProperty('scoreTxt.x'), getProperty('scoreTxt.y')},
        healthBar = {getProperty('healthBar.x'), getProperty('healthBar.y')},
        iconP1 = {getProperty('iconP1.x'), getProperty('iconP1.y')},
        iconP2 = {getProperty('iconP2.x'), getProperty('iconP2.y')}
    }
    
    defaultCamZoom = getProperty('defaultCamZoom')
    defaultSpeed = getProperty('songSpeed')
    originalHealth = getProperty('health')
    
    debugPrint("[ CHAOS MODE ] » INICIALIZADO!")
    chaosMode.scheduleNextEvent()
end

function chaosMode.scheduleNextEvent()
    if not isEnabled then return end
    
    local nextEventDelay = math.random(3, 8)
    runTimer('nextChaosEvent', nextEventDelay)
    debugPrint("[ CHAOS MODE ] » PRÓXIMO EVENTO EM " .. nextEventDelay .. " SEGUNDOS...")
end

function chaosMode.triggerRandomEvent()
    if not isEnabled then return end
    
    local randomEvent = events[math.random(1, #events)]
    local duration = math.random(8, 20)
    
    chaosMode[randomEvent](duration)
    chaosMode.scheduleNextEvent()
end

function chaosMode.swapNotes(duration)
    debugPrint("[ CHAOS MODE ] » TROCANDO NOTAS PLAYER/INIMIGO [ √ ]")
    
    if not swappedNotes then
        for i = 0, 3 do
            local playerX = getPropertyFromGroup('strumLineNotes', i, 'x')
            local enemyX = getPropertyFromGroup('strumLineNotes', i + 4, 'x')
            
            setPropertyFromGroup('strumLineNotes', i, 'x', enemyX)
            setPropertyFromGroup('strumLineNotes', i + 4, 'x', playerX)
        end
        swappedNotes = true
    else
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i][1])
        end
        swappedNotes = false
    end
    
    runTimer('resetSwapNotes', duration)
    activeEffects.swapNotes = true
    eventDurations.swapNotes = duration
end

function chaosMode.randomizeNoteSpeeds(duration)
    debugPrint("[ CHAOS MODE ] » VELOCIDADES ALEATÓRIAS NAS NOTAS [ √ ]")
    
    for i = 0, getProperty('notes.length')-1 do
        setPropertyFromGroup('notes', i, 'multSpeed', math.random(50, 300) / 100)
    end
    
    runTimer('resetNoteSpeeds', duration)
    activeEffects.randomizeNoteSpeeds = true
    eventDurations.randomizeNoteSpeeds = duration
end

function chaosMode.shakeNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS TREMENDO [ √ ]")
    
    activeEffects.shakeNotes = true
    eventDurations.shakeNotes = duration
    runTimer('stopShakeNotes', duration)
end

function chaosMode.spinNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS GIRANDO [ √ ]")
    
    activeEffects.spinNotes = true
    eventDurations.spinNotes = duration
    runTimer('stopSpinNotes', duration)
end

function chaosMode.cameraZoomOut(duration)
    debugPrint("[ CHAOS MODE ] » CAMERA ZOOM OUT [ √ ]")
    
    setProperty('defaultCamZoom', 0.3)
    runTimer('resetCameraZoom', duration)
    activeEffects.cameraZoomOut = true
    eventDurations.cameraZoomOut = duration
end

function chaosMode.cameraShake(duration)
    debugPrint("[ CHAOS MODE ] » CAMERA TREMENDO [ √ ]")
    
    cameraShake('game', 0.015, duration)
    cameraShake('hud', 0.010, duration)
    activeEffects.cameraShake = true
    eventDurations.cameraShake = duration
end

function chaosMode.flashScreen(duration)
    debugPrint("[ CHAOS MODE ] » FLASH NA TELA [ √ ]")
    
    cameraFlash('game', 'FFFFFF', 0.5, true)
    activeEffects.flashScreen = true
    eventTimers.flashScreen = duration
    eventDurations.flashScreen = duration
    runTimer('flashScreenTimer', 1, duration)
end

function chaosMode.reverseLanes(duration)
    debugPrint("[ CHAOS MODE ] » INVERTENDO LANES [ √ ]")
    
    if not reversedLanes then
        for i = 0, 3 do
            local tempX = getPropertyFromGroup('strumLineNotes', i, 'x')
            setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', 3-i, 'x'))
            setPropertyFromGroup('strumLineNotes', 3-i, 'x', tempX)
            
            tempX = getPropertyFromGroup('strumLineNotes', i+4, 'x')
            setPropertyFromGroup('strumLineNotes', i+4, 'x', getPropertyFromGroup('strumLineNotes', 7-i, 'x'))
            setPropertyFromGroup('strumLineNotes', 7-i, 'x', tempX)
        end
        reversedLanes = true
    else
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i][1])
        end
        reversedLanes = false
    end
    
    runTimer('resetReverseLanes', duration)
    activeEffects.reverseLanes = true
    eventDurations.reverseLanes = duration
end

function chaosMode.noteFade(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS TRANSPARENTES [ √ ]")
    
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0.3)
    end
    
    runTimer('resetNoteFade', duration)
    activeEffects.noteFade = true
    eventDurations.noteFade = duration
end

function chaosMode.rainbowNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS COLORIDAS [ √ ]")
    
    activeEffects.rainbowNotes = true
    eventDurations.rainbowNotes = duration
    runTimer('stopRainbowNotes', duration)
end

function chaosMode.stealthNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS INVISÍVEIS [ √ ]")
    
    for i = 0, getProperty('notes.length')-1 do
        setPropertyFromGroup('notes', i, 'alpha', 0)
    end
    
    runTimer('resetStealthNotes', duration)
    activeEffects.stealthNotes = true
    eventDurations.stealthNotes = duration
end

function chaosMode.speedUp(duration)
    debugPrint("[ CHAOS MODE ] » ACELERANDO MÚSICA [ √ ]")
    
    setProperty('songSpeed', defaultSpeed * 1.5)
    runTimer('resetSpeed', duration)
    activeEffects.speedUp = true
    eventDurations.speedUp = duration
end

function chaosMode.slowDown(duration)
    debugPrint("[ CHAOS MODE ] » DESACELERANDO MÚSICA [ √ ]")
    
    setProperty('songSpeed', defaultSpeed * 0.5)
    runTimer('resetSpeed', duration)
    activeEffects.slowDown = true
    eventDurations.slowDown = duration
end

function chaosMode.invertControls(duration)
    debugPrint("[ CHAOS MODE ] » CONTROLES INVERTIDOS [ √ ]")
    
    invertedControls = true
    runTimer('resetInvertControls', duration)
    activeEffects.invertControls = true
    eventDurations.invertControls = duration
end

function chaosMode.randomNoteSizes(duration)
    debugPrint("[ CHAOS MODE ] » TAMANHO DAS NOTAS ALTERADOS [ √ ]")
    
    for i = 0, 7 do
        local scale = math.random(50, 200) / 100
        setPropertyFromGroup('strumLineNotes', i, 'scale.x', scale)
        setPropertyFromGroup('strumLineNotes', i, 'scale.y', scale)
    end
    
    runTimer('resetNoteSizes', duration)
    activeEffects.randomNoteSizes = true
    eventDurations.randomNoteSizes = duration
end

function chaosMode.jitteringNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS COM JITTER [ √ ]")
    
    activeEffects.jitteringNotes = true
    eventDurations.jitteringNotes = duration
    runTimer('stopJitteringNotes', duration)
end

function chaosMode.verticalNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS NA VERTICAL [ √ ]")
    
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'angle', 90)
    end
    
    runTimer('resetVerticalNotes', duration)
    activeEffects.verticalNotes = true
    eventDurations.verticalNotes = duration
end

function chaosMode.zigZagNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS EM ZIGZAG [ √ ]")
    
    activeEffects.zigZagNotes = true
    eventDurations.zigZagNotes = duration
    runTimer('stopZigZagNotes', duration)
end

function chaosMode.sineWaveNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS EM ONDA SENOIDAL [ √ ]")
    
    activeEffects.sineWaveNotes = true
    eventDurations.sineWaveNotes = duration
    runTimer('stopSineWaveNotes', duration)
end

function chaosMode.hiddenReceptors(duration)
    debugPrint("[ CHAOS MODE ] » RECEPTORES ESCONDIDOS [ √ ]")
    
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
    end
    
    runTimer('resetHiddenReceptors', duration)
    activeEffects.hiddenReceptors = true
    eventDurations.hiddenReceptors = duration
end

function chaosMode.flipScreen(duration)
    debugPrint("[ CHAOS MODE ] » TELA INVERTIDA [ √ ]")
    
    setProperty('camGame.angle', 180)
    setProperty('camHUD.angle', 180)
    screensFlipped = true
    
    runTimer('resetFlipScreen', duration)
    activeEffects.flipScreen = true
    eventDurations.flipScreen = duration
end

function chaosMode.dizzyCamera(duration)
    debugPrint("[ CHAOS MODE ] » CÂMERA TONTA [ √ ]")
    
    activeEffects.dizzyCamera = true
    eventDurations.dizzyCamera = duration
    runTimer('stopDizzyCamera', duration)
end

function chaosMode.noteJumping(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS PULANDO [ √ ]")
    
    activeEffects.noteJumping = true
    eventDurations.noteJumping = duration
    runTimer('stopNoteJumping', duration)
end

function chaosMode.misplaceHUD(duration)
    debugPrint("[ CHAOS MODE ] » HUD DESLOCADO [ √ ]")
    
    setProperty('scoreTxt.x', defaultHUDPos.scoreTxt[1] + math.random(-200, 200))
    setProperty('scoreTxt.y', defaultHUDPos.scoreTxt[2] + math.random(-100, 100))
    
    setProperty('healthBar.x', defaultHUDPos.healthBar[1] + math.random(-200, 200))
    setProperty('healthBar.y', defaultHUDPos.healthBar[2] + math.random(-100, 100))
    
    setProperty('iconP1.x', defaultHUDPos.iconP1[1] + math.random(-100, 100))
    setProperty('iconP1.y', defaultHUDPos.iconP1[2] + math.random(-50, 50))
    
    setProperty('iconP2.x', defaultHUDPos.iconP2[1] + math.random(-100, 100))
    setProperty('iconP2.y', defaultHUDPos.iconP2[2] + math.random(-50, 50))
    
    hudMisplaced = true
    runTimer('resetMisplaceHUD', duration)
    activeEffects.misplaceHUD = true
    eventDurations.misplaceHUD = duration
end

function chaosMode.randomizeScrollDirections(duration)
    debugPrint("[ CHAOS MODE ] » DIREÇÕES DE SCROLL ALEATÓRIAS [ √ ]")
    
    local directions = {'up', 'down', 'left', 'right'}
    
    for i = 0, getProperty('notes.length')-1 do
        local randomDir = math.random(1, 4) - 1
        setPropertyFromGroup('notes', i, 'noteData', randomDir)
    end
    
    runTimer('resetScrollDirections', duration)
    activeEffects.randomizeScrollDirections = true
    eventDurations.randomizeScrollDirections = duration
end

function chaosMode.ghostNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS FANTASMAS [ √ ]")
    
    activeEffects.ghostNotes = true
    eventDurations.ghostNotes = duration
    runTimer('stopGhostNotes', duration)
end

function chaosMode.confusingColors(duration)
    debugPrint("[ CHAOS MODE ] » CORES CONFUSAS [ √ ]")
    
    local colors = {0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00}
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'color', colors[math.random(1, 4)])
    end
    
    runTimer('resetConfusingColors', duration)
    activeEffects.confusingColors = true
    eventDurations.confusingColors = duration
end

function chaosMode.switchPlayfield(duration)
    debugPrint("[ CHAOS MODE ] » CAMPO DE JOGO TROCADO [ √ ]")
    
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'x', getScreenWidth() - getPropertyFromGroup('strumLineNotes', i, 'x'))
    end
    
    runTimer('resetSwitchPlayfield', duration)
    activeEffects.switchPlayfield = true
    eventDurations.switchPlayfield = duration
end

function chaosMode.bounceNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS QUICANDO [ √ ]")
    
    activeEffects.bounceNotes = true
    eventDurations.bounceNotes = duration
    runTimer('stopBounceNotes', duration)
end

function chaosMode.diagonalNotes(duration)
    debugPrint("[ CHAOS MODE ] » NOTAS DIAGONAIS [ √ ]")
    
    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes', i, 'angle', 45)
    end
    
    runTimer('resetDiagonalNotes', duration)
    activeEffects.diagonalNotes = true
    eventDurations.diagonalNotes = duration
end

function chaosMode.update(elapsed)
    if not isEnabled then return end
    
    if activeEffects.shakeNotes then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i][1] + math.random(-10, 10))
            setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i][2] + math.random(-10, 10))
        end
    end
    
    if activeEffects.spinNotes then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', getPropertyFromGroup('strumLineNotes', i, 'angle') + 5)
        end
    end
    
    if activeEffects.rainbowNotes then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'color', RGB(
                math.sin(getSongPosition() / 500 + i * 0.5) * 127 + 128,
                math.sin(getSongPosition() / 500 + i * 0.5 + 2) * 127 + 128,
                math.sin(getSongPosition() / 500 + i * 0.5 + 4) * 127 + 128
            ))
        end
    end
    
    if activeEffects.jitteringNotes then
        for i = 0, getProperty('notes.length')-1 do
            local noteType = getPropertyFromGroup('notes', i, 'noteType')
            if noteType == '' or noteType == 'Normal Note' then
                local originalX = getPropertyFromGroup('notes', i, 'x')
                setPropertyFromGroup('notes', i, 'x', originalX + math.random(-10, 10))
            end
        end
    end
    
    if activeEffects.zigZagNotes then
        for i = 0, getProperty('notes.length')-1 do
            local yPos = getPropertyFromGroup('notes', i, 'y')
            local mustHit = getPropertyFromGroup('notes', i, 'mustHit')
            local iTime = getSongPosition() * 0.001
            local zigZag = math.sin(yPos * 0.05 + iTime * 2) * 30
            
            setPropertyFromGroup('notes', i, 'x', getPropertyFromGroup('notes', i, 'x') + zigZag)
        end
    end
    
    if activeEffects.sineWaveNotes then
        for i = 0, getProperty('notes.length')-1 do
            local yPos = getPropertyFromGroup('notes', i, 'y')
            local time = getSongPosition() * 0.001
            local wave = math.sin(yPos * 0.02 + time) * 50
            
            setPropertyFromGroup('notes', i, 'x', getPropertyFromGroup('notes', i, 'x') + wave)
        end
    end
    
    if activeEffects.dizzyCamera then
        local time = getSongPosition() * 0.001
        setProperty('camGame.angle', math.sin(time) * 10)
        setProperty('camHUD.angle', math.cos(time) * 5)
    end
    
    if activeEffects.noteJumping then
        for i = 0, 7 do
            local time = getSongPosition() * 0.002
            local jump = math.sin(time + i * 0.2) * 30
            setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i][2] + jump)
        end
    end
    
    if activeEffects.ghostNotes then
        for i = 0, getProperty('notes.length')-1 do
            local alpha = getPropertyFromGroup('notes', i, 'alpha')
            setPropertyFromGroup('notes', i, 'alpha', math.abs(math.sin(getSongPosition() * 0.003 + i * 0.1)))
        end
    end
    
    if activeEffects.bounceNotes then
        for i = 0, 7 do
            local time = getSongPosition() * 0.001
            local bounce = math.abs(math.sin(time + i * 0.5)) * 30
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.7 + bounce * 0.01)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.7 + bounce * 0.01)
        end
    end
end

function chaosMode.keyPressed(key)
    if not isEnabled or not invertedControls then return false end
    
    local invertMap = {
        ["left"] = "right",
        ["down"] = "up",
        ["up"] = "down",
        ["right"] = "left"
    }
    
    if invertMap[key] then
        return keyJustPressed(invertMap[key])
    end
    
    return false
end

function chaosMode.onTimerCompleted(tag)
    if tag == 'nextChaosEvent' then
        chaosMode.triggerRandomEvent()
    elseif tag == 'resetSwapNotes' then
        if swappedNotes then
            chaosMode.swapNotes(0)
        end
        activeEffects.swapNotes = false
    elseif tag == 'resetNoteSpeeds' then
        for i = 0, getProperty('notes.length')-1 do
            setPropertyFromGroup('notes', i, 'multSpeed', 1)
        end
        activeEffects.randomizeNoteSpeeds = false
    elseif tag == 'stopShakeNotes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i][1])
            setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i][2])
        end
        activeEffects.shakeNotes = false
    elseif tag == 'stopSpinNotes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
        activeEffects.spinNotes = false
    elseif tag == 'resetCameraZoom' then
        setProperty('defaultCamZoom', defaultCamZoom)
        activeEffects.cameraZoomOut = false
    elseif tag == 'flashScreenTimer' then
        if activeEffects.flashScreen then
            cameraFlash('game', 'FFFFFF', 0.2, true)
            eventTimers.flashScreen = eventTimers.flashScreen - 1
            if eventTimers.flashScreen <= 0 then
                activeEffects.flashScreen = false
            end
        end
    elseif tag == 'resetReverseLanes' then
        if reversedLanes then
            chaosMode.reverseLanes(0)
        end
        activeEffects.reverseLanes = false
    elseif tag == 'resetNoteFade' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', originalNoteAlpha[i] or 1)
        end
        activeEffects.noteFade = false
    elseif tag == 'stopRainbowNotes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'color', 0xFFFFFF)
        end
        activeEffects.rainbowNotes = false
    elseif tag == 'resetStealthNotes' then
        for i = 0, getProperty('notes.length')-1 do
            setPropertyFromGroup('notes', i, 'alpha', 1)
        end
        activeEffects.stealthNotes = false
    elseif tag == 'resetSpeed' then
        setProperty('songSpeed', defaultSpeed)
        activeEffects.speedUp = false
        activeEffects.slowDown = false
    elseif tag == 'resetInvertControls' then
        invertedControls = false
        activeEffects.invertControls = false
    elseif tag == 'resetNoteSizes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.7)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.7)
        end
        activeEffects.randomNoteSizes = false
    elseif tag == 'stopJitteringNotes' then
        activeEffects.jitteringNotes = false
    elseif tag == 'resetVerticalNotes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
        activeEffects.verticalNotes = false
    elseif tag == 'stopZigZagNotes' then
        activeEffects.zigZagNotes = false
    elseif tag == 'stopSineWaveNotes' then
        activeEffects.sineWaveNotes = false
    elseif tag == 'resetHiddenReceptors' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', originalNoteAlpha[i] or 1)
        end
        activeEffects.hiddenReceptors = false
    elseif tag == 'resetFlipScreen' then
        if screensFlipped then
            setProperty('camGame.angle', 0)
            setProperty('camHUD.angle', 0)
            screensFlipped = false
        end
        activeEffects.flipScreen = false
    elseif tag == 'stopDizzyCamera' then
        setProperty('camGame.angle', 0)
        setProperty('camHUD.angle', 0)
        activeEffects.dizzyCamera = false
    elseif tag == 'stopNoteJumping' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i][2])
        end
        activeEffects.noteJumping = false
    elseif tag == 'resetMisplaceHUD' then
        if hudMisplaced then
            for key, pos in pairs(defaultHUDPos) do
                setProperty(key .. '.x', pos[1])
                setProperty(key .. '.y', pos[2])
            end
            hudMisplaced = false
        end
        activeEffects.misplaceHUD = false
    elseif tag == 'resetScrollDirections' then
        activeEffects.randomizeScrollDirections = false
    elseif tag == 'stopGhostNotes' then
        for i = 0, getProperty('notes.length')-1 do
            setPropertyFromGroup('notes', i, 'alpha', 1)
        end
        activeEffects.ghostNotes = false
    elseif tag == 'resetConfusingColors' then
        local defaultColors = {0xC24B99, 0x00FFFF, 0x12FA05, 0xF9393F}
        for i = 0, 7 do
            local colorIdx = (i % 4) + 1
            setPropertyFromGroup('strumLineNotes', i, 'color', defaultColors[colorIdx])
        end
        activeEffects.confusingColors = false
    elseif tag == 'resetSwitchPlayfield' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i][1])
        end
        activeEffects.switchPlayfield = false
    elseif tag == 'stopBounceNotes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.7)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.7)
        end
        activeEffects.bounceNotes = false
    elseif tag == 'resetDiagonalNotes' then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
        activeEffects.diagonalNotes = false
    end
end

function chaosMode.onNoteCreation(id, data, noteType, isSustainNote)
    if activeEffects.randomizeNoteSpeeds then
        setPropertyFromGroup('notes', id, 'multSpeed', math.random(50, 300) / 100)
    end
    
    if activeEffects.stealthNotes then
        setPropertyFromGroup('notes', id, 'alpha', 0)
    end
    
    if activeEffects.ghostNotes then
        setPropertyFromGroup('notes', id, 'alpha', 0.5)
    end
end

function onCreatePost()
    chaosMode.initialize()
end

function onUpdate(elapsed)
    chaosMode.update(elapsed)
end

function onTimerCompleted(tag, loops, loopsLeft)
    chaosMode.onTimerCompleted(tag)
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if activeEffects.flashScreen then
        cameraFlash('game', 'FF0000', 0.2, true)
    end
    
    local randomHealth = math.random(1, 10)
    if randomHealth == 1 and isEnabled then
        setProperty('health', getProperty('health') - 0.2)
    end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if activeEffects.flashScreen then
        cameraFlash('game', '0000FF', 0.2, true)
    end
    
    if math.random(1, 15) == 1 and isEnabled then
        cameraShake('game', 0.02, 0.2)
    end
end

function onKeyPress(key)
    if chaosMode.keyPressed(key) then
        return Function_Stop
    end
    return Function_Continue
end

function onSpawnNote(id, data, noteType, isSustainNote)
    chaosMode.onNoteCreation(id, data, noteType, isSustainNote)
end

function getScreenWidth()
    return 1280
end

function RGB(r, g, b)
    return (r * 0x10000) + (g * 0x100) + b
end

return chaosMode