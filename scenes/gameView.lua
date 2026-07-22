----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- gameView.lua
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local sceneGroup

--> MISCELLANEOUS
require ("math")
system.activate( "multitouch" )

-- include Corona's "widget" library
local widget = require "widget"

-- include global variables custom lua
local global = require( "lib.variables" )

-- include Corona's "physics" library
local physics = require "physics"

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--> VARIABLES AND CONSTANTS
	local halfpost = 36
	local longside = 140
	local a = 120
	local b = 100
	local strokeWidth = 10
	local netHeight = 5
	local X, Y, X1, Y1, X2, Y2

	local ballDensity = 0.0020
	local playerDensity = 0.004
	local ball
	local ballDim = 30
	local pdim = 12

	local player1
	local player2
	local player1Score
	local player2Score
	local score = 0

	local background
	local blueLine
	local redLine
	local blueTableL = {}
	local blueTableR = {}
	local redTableL = {}
	local redTableR = {}
	local upBoundL
	local upBoundR
	local lowBoundL
	local lowBoundR

	local title
	local text
	local text2

	local v = 0.16
	local netTimeK = 1.2

	local LowerNetCollisionFilter = {categoryBits = 1, maskBits = 16}
	local upperNetCollisionFilter = {categoryBits = 2, maskBits = 32}
	local lowerBoundCollisionFilter = {categoryBits = 4, maskBits = 80}
	local upperBoundCollisionFilter = {categoryBits = 8, maskBits = 96}
	local bluePlayerCollisionFilter = {categoryBits = 16, maskBits = 101}
	local redPlayerCollisionFilter = {categoryBits = 32, maskBits = 90}
	local ballCollisionFilter = {categoryBits = 64, maskBits = 60}


	local LowerNetCollisionFilter_1 = {categoryBits = 1, maskBits = 0}
	local upperNetCollisionFilter_1 = {categoryBits = 2, maskBits = 0}
	local lowerBoundCollisionFilter_1 = {categoryBits = 4, maskBits = 64}
	local upperBoundCollisionFilter_1 = {categoryBits = 8, maskBits = 64}
	local bluePlayerCollisionFilter_1 = {categoryBits = 16, maskBits = 64}
	local redPlayerCollisionFilter_1 = {categoryBits = 32, maskBits = 64}
	local ballCollisionFilter_1 = {categoryBits = 64, maskBits = 60}

	local LowerNetCollisionFilter_2 = {categoryBits = 1, maskBits = 16}
	local upperNetCollisionFilter_2 = {categoryBits = 2, maskBits = 16}
	local lowerBoundCollisionFilter_2 = {categoryBits = 4, maskBits = 80}
	local upperBoundCollisionFilter_2 = {categoryBits = 8, maskBits = 80}
	local bluePlayerCollisionFilter_2 = {categoryBits = 16, maskBits = 79}
	local redPlayerCollisionFilter_2 = {categoryBits = 32, maskBits = 64}
	local ballCollisionFilter_2 = {categoryBits = 64, maskBits = 60}

	local goal
  local shootPowerDefault=0.008

	local restartBtn
	local menuBtn
	local buttonIsEnabled = true

	local winningCondition = '5'

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> GAME
	function scene:create( event )
	physics.start()
	physics.setGravity(0,0)
	sceneGroup = self.view


--> SOUND
	local goalSound = audio.loadSound('assets/sounds/goal.mp3')

	--isAwake=false addormenta la palla ma le lascia la velocita': al primo
	--contatto riparte come prima. Per fermarla davvero va azzerata.
	local function stopBall()
		ball:setLinearVelocity(0, 0)
		ball.angularVelocity = 0
		ball.isAwake = false
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local i = {}
	local j = {}
	local delta = {}

	--UTILITIES
	-- calcola il numero totale di elementi contenuti in un array
	local function tableSize(table)
		local i = 0
		while table[i+1] do
			i = i + 1
		end
		return i
	end

	--calcola la lunghezza di un segmento dati gli estremi
	local function segmentLenght( x1, y1, x2, y2 )
		local xFactor = x2 - x1
		local yFactor = y2 - y1
		local dist = math.sqrt( (xFactor*xFactor) + (yFactor*yFactor) )
		return dist
	end

	--calcola l'intervallo di tempo per percorrere un segmento con una certa velocità
	local function segmentTime(S, V)
		local timeInterval = S / V
		return timeInterval
	end

	--calcola l'angolo tra due oggetti
  local function angleBetween ( srcObj, dstObj )
      local xDist = dstObj.x-srcObj.x ; local yDist = dstObj.y-srcObj.y
      local angleBetween = math.deg( math.atan( yDist/xDist ) )
      if srcObj.x < dstObj.x then
				angleBetween = angleBetween+90
			else
				angleBetween = angleBetween-90
			end
      return angleBetween
    end


	--MOVIMENTO

	local blueSegmentTransition
	local redSegmentTransition
	local playerInPitch = {}
	playerInPitch[1]=false
	playerInPitch[2]=false
	local blueX = {}
	local blueY = {}
	local redX = {}
	local redY = {}
	local timeTable = {}
	local lenXTable
	local lenredX

	--muove player2 lungo la blueLine
	local function onCompleteMove(player, n, SegmentTransition, playerX, playerY)
		print(delta[n])
		i[n] = i[n] + delta[n]
		if timeTable[i[n]] then
			SegmentTransition = transition.to(player, {
			time=timeTable[i[n]],
			x=playerX[i[n]+delta[n]+j[n]],
			y=playerY[i[n]+delta[n]+j[n]],
			onComplete=function()
				onCompleteMove(player, n, SegmentTransition, playerX, playerY);
			end
			})
		else
			if j[n]==0 then
				j[n] = 1
			else
				j[n] = 0
			end
		delta[n] = delta[n]*(-1)
		i[n] = i[n] + delta[n]
		SegmentTransition = transition.to(player, {
			time=timeTable[i[n]],
			x=playerX[i[n]+delta[n]+j[n]],
			y=playerY[i[n]+delta[n]+j[n]],
			onComplete=function()
				onCompleteMove(player, n, SegmentTransition, playerX, playerY);
			end
		})
		end
	end

	--inverte il verso del moto di player2
	local function invert(event, player, n, SegmentTransition, playerX, playerY)
		if buttonIsEnabled then
			if event.phase == "ended" and not playerInPitch[n] then
				if player.x <= display.contentCenterX - halfpost or player.x >= display.contentCenterX + halfpost then
					transition.pause(player)
					delta[n] = delta[n] * (-1)
					if j[n]==0 then
						j[n] = 1
					else
						j[n] = 0
					end
					SegmentTransition = transition.to(player, {
						time = segmentTime( segmentLenght( player.x, player.y, playerX[i[n]+delta[n]+j[n]], playerY[i[n]+delta[n]+j[n]]), v),
						x = playerX[i[n]+delta[n]+j[n]],
						y = playerY[i[n]+delta[n]+j[n]],
						onComplete=function()
							onCompleteMove(player, n, SegmentTransition, playerX, playerY);
						end
					})
				end
			end
		end
	end

--fa ripartire il player dopo hook
	local function startMoving(player, n, SegmentTransition, playerX, playerY)
		i[n] = 2
		if player.x < display.contentCenterX then
			while playerX[i[n]] < player.x do
				i[n] = i[n] + 1
			end
			i[n] = i[n] - 1
			delta[n] = 1
			j[n] = 0
		else
			i[n] = lenXTable - 1
			while playerX[i[n]] > player.x do
				i[n] = i[n] - 1
			end
			delta[n] = -1
			j[n] = 1
		end
		SegmentTransition = transition.to(player, {
			time = segmentTime( segmentLenght( player.x, player.y, playerX[i[n]+delta[n]+j[n]], playerY[i[n]+delta[n]+j[n]]), v),
			x = playerX[i[n]+delta[n]+j[n]],
			y = playerY[i[n]+delta[n]+j[n]],
			onComplete=function()
				onCompleteMove(player, n, SegmentTransition, playerX, playerY);
			end
		})
	end

--ritorna y ellisse corrispondente a x attuale
	local function EllipseY(X)
		return math.sqrt((1-(X^2)/(a^2))*b^2)
	end

	local leftX = display.contentCenterX - a - halfpost
	local leftPostX = display.contentCenterX - halfpost
	local rightPostX = display.contentCenterX + halfpost
	local rightX = display.contentCenterX + a + halfpost
	local highY = display.contentCenterY - longside - b
	local lowY = display.contentCenterY + longside + b

--regola l'hook del player alla guida colorata
	local function Hooking(player, n, SegmentTransition, playerX, playerY)
		if player==player1 and playerInPitch[n] and player.y >= display.contentCenterY then
			if player.x - leftX <= 3 or rightX - player.x <= 3 or lowY - player.y <= 2 then
				player.isAwake = false
				startMoving(player, n, SegmentTransition, playerX, playerY)
				playerInPitch[n] = false
			elseif player.x < leftPostX and (EllipseY(player.x - display.contentCenterX + halfpost) + display.contentCenterY + longside) - player.y<= 3 then
				print(EllipseY(player.x - display.contentCenterX + halfpost))
				player.isAwake = false
				startMoving(player, n, SegmentTransition, playerX, playerY)
				playerInPitch[n] = false
			elseif player.x > rightPostX and (EllipseY(player.x - display.contentCenterX - halfpost) + display.contentCenterY + longside) - player.y <= 3 then
				print(EllipseY(player.x - display.contentCenterX - halfpost))
				player.isAwake = false
				startMoving(player, n, SegmentTransition, playerX, playerY)
				playerInPitch[n] = false
			end
	elseif player==player2 and playerInPitch[n] and player.y <= display.contentCenterY then
			if player.x - leftX <= 3 or rightX - player.x <= 3 or player.y - highY <= 2 then
				player.isAwake = false
				startMoving(player, n, SegmentTransition, playerX, playerY)
				playerInPitch[n] = false
			elseif player.x < leftPostX and player.y + EllipseY(player.x-display.contentCenterX+halfpost) - display.contentCenterY + longside <= 3 then
				player.isAwake = false
				startMoving(player, n, SegmentTransition, playerX, playerY)
				playerInPitch[n] = false
			elseif player.x >rightPostX and player.y + EllipseY(player.x-display.contentCenterX-halfpost) - display.contentCenterY + longside <= 3 then
				player.isAwake = false
				startMoving(player, n, SegmentTransition, playerX, playerY)
				playerInPitch[n] = false
			end
		end
	end

	-->TIRO
	--#grazieGiorgio^2
	--spara player2 nel campo con direzione normale alla blueLine
	local function shoot(player, n, SegmentTransition)
		if buttonIsEnabled then
			if not playerInPitch[n] then
				if player.y > display.contentCenterY - longside and player.y < display.contentCenterY + longside then
					if player.x < display.contentCenterX then
						transition.pause(player)
		        player:applyLinearImpulse( shootPowerDefault, 0, player.x, player.y)
					elseif player.x > display.contentCenterX then
						transition.pause(player)
		      	player:applyLinearImpulse( -shootPowerDefault, 0, player.x, player.y)
					end
				elseif player.x > display.contentCenterX - a - halfpost and player.x < display.contentCenterX-halfpost then
					if player == player1 then
						local centerBS = display.newCircle(a, display.contentHeight/2+140, 0.1)
		        centerBS:setFillColor( 0, 0, 0, 0)
		        local angleBS = angleBetween(centerBS, player)*math.pi/180
		        local shootAngle = math.atan(b*math.sin(angleBS)/(a*math.cos(angleBS))) + math.pi/2
						print("AAAAAAAA ANGLE: ".. tostring(shootAngle*180/math.pi))
		        local shootPowerComp_x = -shootPowerDefault * math.cos(shootAngle)
		        local shootPowerComp_y = -shootPowerDefault * math.sin(shootAngle)
						transition.pause(player)
		        player:applyLinearImpulse(shootPowerComp_x, shootPowerComp_y, player.x, player.y)
					else
		      	local centerAS = display.newCircle(a, display.contentHeight/2-140, 0.1)
		        centerAS:setFillColor( 0, 0, 0, 0)
		        local angleAS = angleBetween(centerAS, player)*math.pi/180
		        local shootAngle = math.atan(b*math.sin(angleAS)/(a*math.cos(angleAS))) + math.pi/2
		        print("ANGLE: ".. tostring(shootAngle*180/math.pi))
		    		local shootPowerComp_x = shootPowerDefault * math.cos(shootAngle)
		        local shootPowerComp_y = shootPowerDefault * math.sin(shootAngle)
						transition.pause(player)
		        player:applyLinearImpulse(shootPowerComp_x, shootPowerComp_y, player.x, player.y)
					end
	      elseif player.x >= display.contentCenterX - halfpost and player.x <= display.contentCenterX + halfpost then
					transition.pause(player)
					--playerStop(SegmentTransition)
					if player == player1 then
	        	player:applyLinearImpulse( 0, -shootPowerDefault, player.x, player.y)
					else
						player:applyLinearImpulse( 0, shootPowerDefault, player.x, player.y)
					end
	    	elseif player.x > display.contentCenterX + halfpost and player.x < display.contentCenterX + a + halfpost then
					if player==player1 then
						local centerBD = display.newCircle(display.contentCenterX + halfpost, display.contentHeight/2+140, 0.1)
		        centerBD:setFillColor( 0, 0, 0, 0)
		        local angleBD = angleBetween(centerBD, player)*math.pi/180
		        local shootAngle = math.atan(b*math.sin(angleBD)/(a*math.cos(angleBD))) - math.pi/2
		        print("BBBBBB ANGLE: ".. tostring(shootAngle*180/math.pi))
		    		local shootPowerComp_x = shootPowerDefault * math.cos(shootAngle)
		        local shootPowerComp_y = shootPowerDefault * math.sin(shootAngle)
						transition.pause(player)
		        player:applyLinearImpulse(shootPowerComp_x, shootPowerComp_y, player.x, player.y)
					else
		        local centerAD = display.newCircle(display.contentCenterX + halfpost, display.contentHeight/2-140, 0.1)
		        centerAD:setFillColor( 0, 0, 0, 0)
		        local angleAD = angleBetween(centerAD, player)*math.pi/180
		        local shootAngle = math.atan(b*math.sin(angleAD)/(a*math.cos(angleAD))) - math.pi/2
						print("ANGLE: ".. tostring(shootAngle*180/math.pi))
		        local shootPowerComp_x = -shootPowerDefault * math.cos(shootAngle)
		        local shootPowerComp_y = -shootPowerDefault * math.sin(shootAngle)
						transition.pause(player)
		        player:applyLinearImpulse(shootPowerComp_x, shootPowerComp_y, player.x, player.y)
					end
	      end
				playerInPitch[n] = true
	    end
		end
	end


	--> POWERUPS

	local used = {}
	used[1]=true
	used[2]=true
	local ready_to_randomize = {}
	ready_to_randomize[1]=true
	ready_to_randomize[2]=true
	local loading = {}
	local rand = {}
	local power_button = {}
	local current = {}
	local powerup_sound = {}
	local counter = {}
	counter[1]=-1
	counter[2]=-1
	local staging_powerup = {}
	local wall = {}
	local powerup_start = {}

	local deltaY = {longside + b, - longside - b }

	--riporta player sulla linea di porta
	local function goNet(player, n, SegmentTransition, playerX, playerY)
		transition.pause(player)
		SegmentTransition = transition.to(player, {
		time=segmentTime( segmentLenght( player.x, player.y, display.contentCenterX, display.contentCenterY + deltaY[n]),2*v),
		x=display.contentCenterX,
		y=display.contentCenterY + deltaY[n],
		onComplete=function()
			startMoving(player, n, SegmentTransition, playerX, playerY)
		end
		})
	end

	local function restorePower()--ripristina potenza di tiro
	  shootPowerDefault = shootPowerDefault/2
	end

	local function restoreWall(n)
		if wall[n] then
			physics.removeBody( wall[n] )
			wall[n]:removeSelf()
			wall[n] = nil
		end
	end

	--funzione che regola l'uso dei powerups
	local function powerup_usage(player, n, SegmentTransition, playerX, playerY)
		audio.stop( 6 )
		if buttonIsEnabled then
			--power_button_red.fill.effect = "filter.grayscale"
			power_button[n].alpha=0
			used[n]=true
			print ("X")
			if current[n]==1 then
				print ("a")
				if global.sfxFlag==1 then
					powerup_sound[n] = audio.loadSound( "assets/sounds/powerup1_sound.mp3")
					audio.play(powerup_sound[n], {channel=6})
				end
				stopBall()
			elseif current[n]==2 then
				print ("b")
				if not wall[n] then
					if global.sfxFlag==1 then
						powerup_sound[n] = audio.loadSound( "assets/sounds/powerup2_sound.mp3" )
						audio.play(powerup_sound[n], {channel=6})
					end
					if player==player1 and player.y>=display.contentCenterY+longside then
						wall[n]=display.newRect( display.contentCenterX, display.contentCenterY+longside, 100, 5 )
						physics.addBody( wall[n], "static", {filter = redPlayerCollisionFilter} )
						wall[n]:setFillColor(1, 0, 0, 1)
					elseif player==player2 and player.y<=display.contentCenterY-longside then
						wall[n]=display.newRect( display.contentCenterX, display.contentCenterY-longside, 100, 5 )
						physics.addBody( wall[n], "static", {filter = bluePlayerCollisionFilter} )
						wall[n]:setFillColor(0, 0, 1, 1)
					else
						wall[n]=display.newRect( display.contentCenterX, player.y, 100, 5 )
						if player==player1 then
							physics.addBody( wall[n], "static", {filter = redPlayerCollisionFilter} )
							wall[n]:setFillColor(1, 0, 0, 1)
						else
							physics.addBody( wall[n], "static", {filter = bluePlayerCollisionFilter} )
							wall[n]:setFillColor(0, 0, 1, 1)
						end
					end
					timer.performWithDelay(4000, function()
						restoreWall(n);
					end)
				else
					if global.sfxFlag==1 then
						powerup_sound[n] = audio.loadSound( "assets/sounds/powerup4a_sound.mp3" )
						audio.play(powerup_sound[n], {channel=6})
					end
				end
			elseif current[n]==3 then
				print ("c")
				if global.sfxFlag==1 then
					powerup_sound[n] = audio.loadSound( "assets/sounds/powerup3_sound.mp3" )
					audio.play(powerup_sound[n], {channel=6})
				end
				shootPowerDefault=shootPowerDefault*2
				timer.performWithDelay(4000, restorePower)
			elseif current[n]==4 then
				print ("d")
				if playerInPitch[n] then
					if global.sfxFlag==1 then
						powerup_sound[n] = audio.loadSound( "assets/sounds/powerup4_sound.mp3" )
						audio.play(powerup_sound[n], {channel=6})
					end
					goNet(player, n, SegmentTransition, playerX, playerY)
				else
					if global.sfxFlag==1 then
						powerup_sound[n] = audio.loadSound( "assets/sounds/powerup4a_sound.mp3" )
						audio.play(powerup_sound[n], {channel=6})
					end
				end
			elseif current[n]==5 then
				if global.sfxFlag==1 then
					powerup_sound[n] = audio.loadSound( "assets/sounds/powerup4a_sound.mp3" )
					audio.play(powerup_sound[n], {channel=6})
				end
			end
			print ("Y")
		end
	end

	--funzione di display e sorteggio powerup
	local function powerup(player, n, SegmentTransition, playerX, playerY)
		if counter[n]~=-1 then
			loading[n].alpha=0
		else
			counter[n]=0
		end
		if used[n] and ready_to_randomize[n] then
			print("A libero B libero")
			rand[n]=math.random(5)
			if rand[n]==1 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup1N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup1B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup1W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==2 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup2N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup2B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup2W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B2")
			elseif rand[n]==3 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup3N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup3B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup3W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B3")
			elseif rand[n]==4 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup4N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup4B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup4W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B4")
			elseif rand[n]==5 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup5N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup5B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup5W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B5")
			end
			if n==2 then
				loading[n].x = display.contentCenterX + 115
				loading[n].y = display.contentCenterY-45
			elseif n==1 then
				loading[n].x = display.contentCenterX - 115
				loading[n].y = display.contentCenterY+45
			end
			counter[n]=counter[n]+1
			if counter[n] ~= 5 then
			print("rieseguo")
			powerup_start[n] = timer.performWithDelay(700, function()
																		powerup(player, n, SegmentTransition, playerX, playerY);
																	end)
			else
				print("counter=5")
				if rand[n]==1 then
					if (global.fieldType == 1) then --neon
						power_button[n]=display.newImageRect("assets/powerups/powerup1N.png", 30, 30 )
					elseif (global.fieldType == 2) then --blak
						power_button[n]=display.newImageRect("assets/powerups/powerup1B.png", 30, 30 )
					else --white
						power_button[n]=display.newImageRect("assets/powerups/powerup1W.png", 30, 30 )
					end
				elseif rand[n]==2 then
					if (global.fieldType == 1) then --neon
						power_button[n]=display.newImageRect("assets/powerups/powerup2N.png", 30, 30 )
					elseif (global.fieldType == 2) then --blak
						power_button[n]=display.newImageRect("assets/powerups/powerup2B.png", 30, 30 )
					else --white
						power_button[n]=display.newImageRect("assets/powerups/powerup2W.png", 30, 30 )
					end
				elseif rand[n]==3 then
					if (global.fieldType == 1) then --neon
						power_button[n]=display.newImageRect("assets/powerups/powerup3N.png", 30, 30 )
					elseif (global.fieldType == 2) then --blak
						power_button[n]=display.newImageRect("assets/powerups/powerup3B.png", 30, 30 )
					else --white
						power_button[n]=display.newImageRect("assets/powerups/powerup3W.png", 30, 30 )
					end
				elseif rand[n]==4 then
					if (global.fieldType == 1) then --neon
						power_button[n]=display.newImageRect("assets/powerups/powerup4N.png", 30, 30 )
					elseif (global.fieldType == 2) then --blak
						power_button[n]=display.newImageRect("assets/powerups/powerup4B.png", 30, 30 )
					else --white
						power_button[n]=display.newImageRect("assets/powerups/powerup4W.png", 30, 30 )
					end
				elseif rand[n]==5 then
					if (global.fieldType == 1) then --neon
						power_button[n]=display.newImageRect("assets/powerups/powerup5N.png", 30, 30 )
					elseif (global.fieldType == 2) then --blak
						power_button[n]=display.newImageRect("assets/powerups/powerup5B.png", 30, 30 )
					else --white
						power_button[n]=display.newImageRect("assets/powerups/powerup5W.png", 30, 30 )
					end
				end
				if n==2 then
					power_button[n].x = display.contentCenterX + 78
					power_button[n].y = display.contentCenterY - 65
				elseif n==1 then
					power_button[n].x = display.contentCenterX - 78
					power_button[n].y = display.contentCenterY + 65
				end
				current[n]=rand[n]
				power_button[n]:addEventListener("tap", function()
							powerup_usage(player, n, SegmentTransition, playerX, playerY);
							end)
				used[n]=false
				counter[n]=0
				powerup_start[n] = timer.performWithDelay(700, function()
																			powerup(player, n, SegmentTransition, playerX, playerY);
																		end)
				print("rieseguo")
			end
		elseif not used[n] and ready_to_randomize[n] then
			print("A pieno B libero")
			loading[n].alpha=0
			rand[n]=math.random(5)
			if rand[n]==1 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup1N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup1B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup1W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==2 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup2N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup2B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup2W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==3 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup3N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup3B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup3W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==4 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup4N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup4B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup4W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==5 then
				if (global.fieldType == 1) then
					loading[n]=display.newImageRect("assets/powerups/powerup5N.png", 30, 30 )
				elseif (global.fieldType == 2) then
					loading[n]=display.newImageRect("assets/powerups/powerup5B.png", 30, 30 )
				else
					loading[n]=display.newImageRect("assets/powerups/powerup5W.png", 30, 30 )
				end
				loading[n].alpha=1
				print("B1")
			end
			if n==2 then
				loading[n].x = display.contentCenterX + 115
				loading[n].y = display.contentCenterY-45
			elseif n==1 then
				loading[n].x = display.contentCenterX - 115
				loading[n].y = display.contentCenterY+45
			end
			counter[n]=counter[n]+1
			if counter[n] ~= 5 then
				print("rieseguo")
				powerup_start[n] = timer.performWithDelay(700, function()
																			powerup(player, n, SegmentTransition, playerX, playerY);
																		end)
			else
				print("counter=5")
				staging_powerup[n]=rand[n]
				ready_to_randomize[n]=false
				powerup_start[n] = timer.performWithDelay(700, function()
																			powerup(player, n, SegmentTransition, playerX, playerY);
																		end)
				print("rieseguo")
			end
		elseif used[n] and not ready_to_randomize[n] then
			print("A libero, B pieno")
			power_button[n].alpha=0
			rand[n] = staging_powerup[n]
			if rand[n]==1 then
				if (global.fieldType == 1) then --neon
					power_button[n]=display.newImageRect("assets/powerups/powerup1N.png", 30, 30 )
				elseif (global.fieldType == 2) then --blak
					power_button[n]=display.newImageRect("assets/powerups/powerup1B.png", 30, 30 )
				else --white
					power_button[n]=display.newImageRect("assets/powerups/powerup1W.png", 30, 30 )
				end
			elseif rand[n]==2 then
				if (global.fieldType == 1) then --neon
					power_button[n]=display.newImageRect("assets/powerups/powerup2N.png", 30, 30 )
				elseif (global.fieldType == 2) then --blak
					power_button[n]=display.newImageRect("assets/powerups/powerup2B.png", 30, 30 )
				else --white
					power_button[n]=display.newImageRect("assets/powerups/powerup2W.png", 30, 30 )
				end
			elseif rand[n]==3 then
				if (global.fieldType == 1) then --neon
					power_button[n]=display.newImageRect("assets/powerups/powerup3N.png", 30, 30 )
				elseif (global.fieldType == 2) then --blak
					power_button[n]=display.newImageRect("assets/powerups/powerup3B.png", 30, 30 )
				else --white
					power_button[n]=display.newImageRect("assets/powerups/powerup3W.png", 30, 30 )
				end
			elseif rand[n]==4 then
				if (global.fieldType == 1) then --neon
					power_button[n]=display.newImageRect("assets/powerups/powerup4N.png", 30, 30 )
				elseif (global.fieldType == 2) then --blak
					power_button[n]=display.newImageRect("assets/powerups/powerup4B.png", 30, 30 )
				else --white
					power_button[n]=display.newImageRect("assets/powerups/powerup4W.png", 30, 30 )
				end
			elseif rand[n]==5 then
				if (global.fieldType == 1) then --neon
					power_button[n]=display.newImageRect("assets/powerups/powerup5N.png", 30, 30 )
				elseif (global.fieldType == 2) then --blak
					power_button[n]=display.newImageRect("assets/powerups/powerup5B.png", 30, 30 )
				else --white
					power_button[n]=display.newImageRect("assets/powerups/powerup5W.png", 30, 30 )
				end
			end
			if n==2 then
			 power_button[n].x = display.contentCenterX + 78
			 power_button[n].y = display.contentCenterY - 65
		 elseif n==1 then
			 power_button[n].x = display.contentCenterX - 78
			 power_button[n].y = display.contentCenterY + 65
		 end
		 current[n]=rand[n]
		 power_button[n]:addEventListener("tap", function()
					 powerup_usage(player, n, SegmentTransition, playerX, playerY);
					 end)
			used[n]=false
			ready_to_randomize[n]=true
			counter[n]=0
			powerup_start[n] = timer.performWithDelay(700, function()
																		powerup(player, n, SegmentTransition, playerX, playerY);
																	end)
			print("rieseguo")
		elseif not used[n] and not ready_to_randomize[n] then
			loading[n].alpha=1
			print("A pieno, B pieno")
			powerup_start[n] = timer.performWithDelay(700, function()
																	 powerup(player, n, SegmentTransition, playerX, playerY);
																 end)
			print("rieseguo")
		end
	end


	powerup_start[1]=timer.performWithDelay( 700, function()
																powerup(player1, 1, redSegmentTransition, redX, redY);
															end)

	if global.gameMode == 1 then
		powerup_start[2]=timer.performWithDelay( 700, function()
															powerup(player2, 2, blueSegmentTransition, blueX, blueY);
														end)
		end


	--MENU

	local function menuView()
		timer.pause(powerup_start[1])
		if powerup_start[2] then
			timer.pause(powerup_start[2])
		end
		if loading[1] then
			loading[1]:removeSelf()
			loading[1] = nil
		end
		if loading[2] then
			loading[2]:removeSelf()
			loading[2] = nil
		end
		if power_button[1] then
			power_button[1]:removeSelf()
			power_button[1] = nil
		end
		if power_button[2] then
			power_button[2]:removeSelf()
			power_button[2] = nil
		end
		if wall[1] then
			wall[1]:removeSelf()
			wall[1] = nil
		end
		if wall[2] then
			wall[2]:removeSelf()
			wall[2] = nil
		end
		if target1  ~= nil  then
			target1=nil
		end
		if target2 ~= nil  then
			target2 = nil
		end
		if target3 ~= nil  then
			target3=nil
		end
		if gameResumeBtn then
			gameResumeBtn:removeSelf()
		end
		global.game = 1
		composer.gotoScene( "scenes.menuView", "fade", 300 )
		return true
	end

----------------------------------------------------------------------------------------------------
--TRAINING SECTION
----------------------------------------------------------------------------------------------------

if global.gameMode == 2 then

	local cheers = audio.loadSound("assets/sounds/trainingCheers.mp3")

	local targetCounter = 0
	local trainingStage = 0

	local function onLocalCollision(object, event)
		if ( event.phase == "began" ) then
			if global.sfxFlag == 1 then
				audio.play(cheers, {channel=5})
			end
		elseif ( event.phase == "ended" ) then
			--il bersaglio non puo' essere distrutto qui: Box2D sta ancora
			--risolvendo la collisione. Si rimanda al frame successivo.
			timer.performWithDelay(1, function()
				display.remove(object)
			end)
			targetCounter = targetCounter + 1
			if targetCounter == 3 then
				targetCounter = 0
				trainingStage = trainingStage + 1
				targetSpawner()
			end
		end
	end

	function targetSpawner()
		if trainingStage == 0 then

			target1 = display.newImageRect("assets/training/target1.png", 40, 40)
			target1.x = display.contentCenterX
			target1.y = display.contentCenterY -longside - b

			target2 = display.newImageRect("assets/training/target1.png", 40, 40)
			target2.x = display.contentCenterX - 2.5*halfpost
			target2.y = display.contentCenterY - longside - halfpost

			target3 = display.newImageRect("assets/training/target1.png", 40, 40)
			target3.x = display.contentCenterX + 2.5*halfpost
			target3.y = display.contentCenterY - longside - halfpost

			physics.addBody(target1, "static", {filter = ballCollisionFilter})
			target1.collision = onLocalCollision
			target1:addEventListener( "collision" )

			physics.addBody(target2, "static", {filter = ballCollisionFilter})
			target2.collision = onLocalCollision
			target2:addEventListener( "collision" )

			physics.addBody(target3, "static", {filter = ballCollisionFilter})
			target3.collision = onLocalCollision
			target3:addEventListener( "collision" )

		elseif trainingStage >= 1 then
			menuView()

		end
	end

	targetSpawner()

end

--SOCIAL SHARE

	if "simulator" == system.getInfo( "environment" ) then
    native.showAlert( "Build for device", "This plugin is not supported on the Corona Simulator.", { "OK" } )
	end

	-- Use the Android "Holo Dark" theme for this sample
	widget.setTheme( "widget_theme_android_holo_dark" )

	-- Executed upon touching and releasing the button created below
	local function onShareButtonReleased(event)
		local serviceName = "share"
    --local serviceName = event.target.id
    local isAvailable = native.canShowPopup( "social", serviceName )

    -- If it is possible to show the popup
    if isAvailable then
        local listener = {}
        function listener:popup( event )
          print( "name(" .. event.name .. ") type(" .. event.type .. ") action(" .. tostring(event.action) .. ") limitReached(" .. tostring(event.limitReached) .. ")" )
        end
        -- Show the popup
        native.showPopup( "social",
        {
            service = serviceName, -- The service key is ignored on Android.
            message = "I just had an awesome game on Doink! Play now: https://goo.gl/snA2T3 #Doink!",
            listener = listener
        })
    else
      if isSimulator then
        native.showAlert( "Build for device", "This plugin is not supported on the Corona Simulator, please build for an iOS/Android device or the Xcode simulator", { "OK" } )
      else
        -- Popup isn't available.. Show error message
        native.showAlert( "Cannot send " .. serviceName .. " message.", "Please setup your " .. serviceName .. " account or check your network connection (on android this means that the package/app (ie Twitter) is not installed on the device)", { "OK" } )
      end
  	end
	end

	local function resumeView()

		if player1Score.text ~= winningCondition and player2Score.text ~= winningCondition then

			buttonIsEnabled = true

			physics.start()
			if powerup_start[1] then
				timer.resume(powerup_start[1])
			end
			if powerup_start[2] then
				timer.resume(powerup_start[2])
			end

			if not playerInPitch[1] then
				--transition.resume(player1)
				startMoving(player1, 1, redSegmentTransition, redX, redY)
			end
			if not playerInPitch[2] then
				--transition.resume(player2)
				startMoving(player2, 2, blueSegmentTransition, blueX, blueY)
			end
			gameResumeBtn:removeSelf()
			shareBtn:removeSelf()
			menuBtn2:removeSelf()
			if achievementText then
			achievementText:removeSelf()
				end

		end

	end

	local function menuPopUp(mode)

		if buttonIsEnabled then

			buttonIsEnabled = false

			physics.pause()
			if powerup_start[1] then
				timer.pause(powerup_start[1])
			end
			if powerup_start[2] then
				timer.pause(powerup_start[2])
			end

			if not playerInPitch[1] then
				transition.pause(player1)
			end

			if not playerInPitch[2] then
				transition.pause(player2)
			end


			if mode==1 then
				overlay=display.newImageRect("assets/images/pause.png", 320, 569)
			else
				overlay=display.newImageRect("assets/images/gg.png", 320, 569)
			end

			overlay.x = display.contentCenterX
			overlay.y = display.contentCenterY

			shareBtn = widget.newButton{
					defaultFile= "assets/buttons/back_roundW.png",
			    id = "share",
			    left = 0,
			    top = 430,
			    width = 250,
					height = 90,
			    --label = "Share on socials",
					onRelease = onShareButtonReleased,
			    --[[onRelease = function()
						onShareButtonReleased(event)
						timer.performWithDelay(300, function()
							overlay:removeSelf();
						end)
					end,]]
			}
			shareBtn.x = display.contentCenterX
			if mode==1 then
				shareBtn.y = display.contentCenterY+1*longside
			else
				shareBtn.y = display.contentCenterY+0.7*longside
			end

			menuBtn2 = widget.newButton{
				defaultFile= "assets/buttons/back_roundW.png",
				id = "menu",
				left = 0,
				top = 430,
				width = 240,
				height = 90,
				--label = "Return to Menu",
				onRelease = function()
					menuView()
					timer.performWithDelay(300, function()
						overlay:removeSelf();
					end)
				end,
			}

			menuBtn2.x = display.contentCenterX
			if mode==1 then
				menuBtn2.y = display.contentCenterY-0.6*longside
			else
				menuBtn2.y = display.contentCenterY-0*longside
			end

			if mode==1 then
				gameResumeBtn = widget.newButton{
					defaultFile= "assets/buttons/back_roundW.png",
					id = "resume",
					left = 0,
					top = 430,
					width = 240,
					height = 90,
					--label = "Resume game",
					onRelease = function()
						resumeView()
						overlay:removeSelf()
					end,
				}

				gameResumeBtn.x = display.contentCenterX
				gameResumeBtn.y = display.contentCenterY+0.2*longside
			end

			sceneGroup:insert( menuBtn2 )
			sceneGroup:insert( shareBtn )
			if mode==1 then
				sceneGroup:insert( gameResumeBtn )
			end

		end

	end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> BACKGROUND
	if (global.fieldType==1) then
		background = display.newImageRect( "assets/fields/field1.png", display.contentWidth, display.contentHeight*119/100 )
	elseif (global.fieldType==2) then
		background = display.newImageRect( "assets/fields/field2.png", display.contentWidth, display.contentHeight*119/100 )
	elseif (global.fieldType==3) then
		background = display.newImageRect( "assets/fields/field3.png", display.contentWidth, display.contentHeight*119/100 )
	else
		background = display.newImageRect( "assets/fields/field0.png", display.contentWidth, display.contentHeight*119/100 )
	end
	background.x = display.contentCenterX
	background.y = display.contentCenterY

--> ARENA

--player paths

--blueX and blueY tables, creation of timeTable
	X1 = display.contentCenterX - a - halfpost
	Y1 = display.contentCenterY
	X2 = display.contentCenterX - a - halfpost
	Y2 = display.contentCenterY - longside

	table.insert(blueX, X1)
	table.insert(blueX, X2)
	table.insert(blueY, Y1)
	table.insert(blueY, Y2)
	table.insert(timeTable, segmentTime(segmentLenght(X1, Y1, X2, Y2), v))
	X1 = X2
	Y1 = Y2

	for x = -a + 4, 0, 4 do
		X2 = display.contentCenterX + x - halfpost
		Y2 = display.contentCenterY - math.sqrt((1-(x^2)/(a^2))*b^2) - longside
		table.insert(blueX, X2)
		table.insert(blueY, Y2)
		table.insert(timeTable, segmentTime(segmentLenght(X1, Y1, X2, Y2), v))
		X1 = X2
		Y1 = Y2
	end

	X2 = display.contentCenterX + halfpost
	Y2 = display.contentCenterY - longside - b
	table.insert(blueX, X2)
	table.insert(blueY, Y2)
	table.insert(timeTable, segmentTime(segmentLenght(X1, Y1, X2, Y2), v)*netTimeK)
	X1 = X2
	Y1 = Y2

	for x = 4, a, 4 do
		X2 = display.contentCenterX + x + halfpost
		Y2 = display.contentCenterY - math.sqrt((1-(x^2)/(a^2))*b^2) - longside
		table.insert(blueX, X2)
		table.insert(blueY, Y2)
		table.insert(timeTable, segmentTime(segmentLenght(X1, Y1, X2, Y2), v))
		X1 = X2
		Y1 = Y2
	end

	X2 = display.contentCenterX + a + halfpost
	Y2 = display.contentCenterY
	table.insert(blueX, X2)
	table.insert(blueY, Y2)
	table.insert(timeTable, segmentTime(segmentLenght(X1, Y1, X2, Y2), v))

	lenXTable = tableSize(blueX)--lasciami qui
	print("AOO",blueX[lenXTable])


	--redX and redY tables
	redX = {display.contentCenterX - a - halfpost, display.contentCenterX - a - halfpost}
	redY = {display.contentCenterY, display.contentCenterY + longside}

	for x = - a + 4, 0, 4 do
		X = display.contentCenterX + x - halfpost
		Y = display.contentCenterY + math.sqrt((1-(x^2)/(a^2))*b^2) + longside
		table.insert(redX, X)
		table.insert(redY, Y)
	end

	for x = 0, a, 4 do
		X = display.contentCenterX + x + halfpost
		Y = display.contentCenterY + math.sqrt((1-(x^2)/(a^2))*b^2) + longside
		table.insert(redX, X)
		table.insert(redY, Y)
	end

	table.insert(redX, display.contentCenterX + a + halfpost)
	table.insert(redY, display.contentCenterY)

	lenredX = tableSize(redX)--lasciami qui
	print("AOO",redX[lenredX])


	--blueLine, blueTable and upBound physics
	local blueLine = display.newLine(display.contentCenterX - a - halfpost, display.contentCenterY, display.contentCenterX - a - halfpost, display.contentCenterY - longside)
	blueLine.strokeWidth = strokeWidth

	if (global.fieldType == 3) then
		blueLine:setStrokeColor( 0, 0, 1, 0.4)
	elseif (global.fieldType == 2) then
		blueLine:setStrokeColor( 0, 0, 1, 0.4)
	elseif (global.fieldType == 0) then
		blueLine.alpha=0
	elseif (global.fieldType == 1) then
		blueLine.alpha=0
	end

	blueTableL = {display.contentCenterX - a - halfpost, display.contentCenterY, display.contentCenterX - a - halfpost, display.contentCenterY - longside}
	for x = -a + 1, 0 do
		X = display.contentCenterX + x - halfpost
		Y = display.contentCenterY - math.sqrt((1-(x^2)/(a^2))*b^2) - longside
		blueLine:append(X,Y)
		table.insert(blueTableL, X)
		table.insert(blueTableL, Y)
	end

	for x = 0, a do
		X = display.contentCenterX + x + halfpost
		Y = display.contentCenterY - math.sqrt((1-(x^2)/(a^2))*b^2) - longside
		blueLine:append(X,Y)
		table.insert(blueTableR, X)
		table.insert(blueTableR, Y)
	end

	blueLine:append(display.contentCenterX + a + halfpost, display.contentCenterY)
	table.insert(blueTableR, display.contentCenterX + a + halfpost)
	table.insert(blueTableR, display.contentCenterY)

	upBoundL = display.newRect(0,0,21,21)
	upBoundL.alpha = 0
	physics.addBody(upBoundL, "static", {chain = blueTableL, filter = upperBoundCollisionFilter})
	upBoundR = display.newRect(0,0,21,21)
	upBoundR.alpha = 0
	physics.addBody(upBoundR, "static", {chain = blueTableR, filter = upperBoundCollisionFilter})


	--redLine, redTable and lowBound physics
	local redLine = display.newLine(display.contentCenterX - a - halfpost, display.contentCenterY, display.contentCenterX - a - halfpost, display.contentCenterY + longside)
	redLine.strokeWidth = strokeWidth

	if (global.fieldType == 3) then
		redLine:setStrokeColor( 1, 0, 0, 0.4)
	elseif (global.fieldType == 2) then
		redLine:setStrokeColor( 1, 0, 0, 0.4)
	elseif (global.fieldType == 0) then
		redLine.alpha=0
	elseif (global.fieldType == 1) then
		redLine.alpha=0
	end

	redTableL = {display.contentCenterX - a - halfpost, display.contentCenterY, display.contentCenterX - a - halfpost, display.contentCenterY + longside}
	for x = -a + 1, 0 do
		X = display.contentCenterX + x - halfpost
		Y = display.contentCenterY + math.sqrt((1-(x^2)/(a^2))*b^2) + longside
		redLine:append(X,Y)
		table.insert(redTableL, X)
		table.insert(redTableL, Y)
	end

	for x = 0, a do
		X = display.contentCenterX + x + halfpost
		Y = display.contentCenterY + math.sqrt((1-(x^2)/(a^2))*b^2) + longside
		redLine:append(X,Y)
		table.insert(redTableR, X)
		table.insert(redTableR, Y)
	end

	redLine:append(display.contentCenterX + a + halfpost, display.contentCenterY)
	table.insert(redTableR, display.contentCenterX + a + halfpost)
	table.insert(redTableR, display.contentCenterY)

	lowBoundL = display.newRect(0,0,21,21)
	lowBoundL.alpha = 0
	physics.addBody(lowBoundL, "static", {chain = redTableL, filter = lowerBoundCollisionFilter})
	lowBoundR = display.newRect(0,0,21,21)
	lowBoundR.alpha = 0
	physics.addBody(lowBoundR, "static", {chain = redTableR, filter = lowerBoundCollisionFilter})



--nets physics rectangles
	local upperNet = display.newRect(display.contentCenterX, display.contentCenterY - b - longside, 2*halfpost, netHeight)
	local lowerNet = display.newRect(display.contentCenterX, display.contentCenterY + b + longside, 2*halfpost, netHeight)
	upperNet.alpha = 0
	lowerNet.alpha = 0
	physics.addBody(upperNet, "static", {filter = upperNetCollisionFilter})
	physics.addBody(lowerNet, "static", {filter = LowerNetCollisionFilter})

--> SCORES
	player1Score = display.newText('0',display.contentCenterX, display.contentHeight*80/100, 'Courier-Bold',display.contentHeight*20/100)
	player1Score:setTextColor(1, 0, 0, 0.4)

if (global.fieldType==0) then
	player2Score = display.newText('0', display.contentCenterX, display.contentHeight*18/100, 'Courier-Bold', display.contentHeight*20/100)
	player2Score:setTextColor(0, 1, 0, 0.4)
else
	player2Score = display.newText('0', display.contentCenterX, display.contentHeight*18/100, 'Courier-Bold', display.contentHeight*20/100)
	player2Score:setTextColor(0, 0, 1, 0.4)
end

--> BALL
if(global.ballType==1) then
	ball = display.newImageRect( "assets/balls/ball1.png", ballDim, ballDim)
elseif(global.ballType==2) then
	ball = display.newImageRect( "assets/balls/ball2.png", ballDim, ballDim)
elseif(global.ballType==3) then
	ball = display.newImageRect( "assets/balls/ball3.png", ballDim, ballDim)
elseif(global.ballType==4) then
	ball = display.newImageRect( "assets/balls/ball4.png", ballDim, ballDim)
elseif(global.ballType==5) then
	ball = display.newImageRect( "assets/balls/ball5.png", ballDim, ballDim)
else
	ball = display.newImageRect( "assets/balls/ball6.png", ballDim, ballDim)
end
ball.x = display.contentCenterX
ball.y = display.contentCenterY
if global.gameMode == 1 then
	physics.addBody( ball, "dynamic", {density=0.4*playerDensity, radius=ballDim/1.5, bounce=1, filter = ballCollisionFilter})
end
if global.gameMode == 2 then
	ball.alpha = 0
end

--> PLAYERS

	player1 = display.newCircle(display.contentCenterX - a - halfpost, display.contentCenterY, pdim)
	player1:setFillColor(1, 0, 0, 1)
	physics.addBody(player1, "dynamic", {density=playerDensity, radius=pdim/2, bounce=1, filter = redPlayerCollisionFilter})

	player2 = display.newCircle(display.contentCenterX + a + halfpost, display.contentCenterY, pdim)
	if (global.fieldType == 0) then
		player2:setFillColor(0, 1, 0, 1)
	else
		player2:setFillColor(0, 0, 1, 1)
	end
	physics.addBody(player2, "dynamic", {density=playerDensity, radius=pdim/2, bounce=1, filter = bluePlayerCollisionFilter})

	if global.gameMode == 2 then
		player2.alpha = 0
	end

	i[1]=0
	i[2]=lenXTable
	j[1]=0
	j[2]=1
	delta[1]=1
	delta[2]=-1

	onCompleteMove(player1, 1, redSegmentTransition, redX, redY )  -- start moving
	if global.gameMode == 1 then
		onCompleteMove(player2, 2, blueSegmentTransition, blueX, blueY )  -- start moving
	end

--> BUTTONS
	if (global.fieldType == 1) then
		button1 = display.newImageRect( "assets/buttons/btnGreenNeon.png", 65, 65  )
		button1.x = display.contentWidth*10/100
		button1.y = display.contentHeight*102/100

		button2 = display.newImageRect( "assets/buttons/btnRedNeon.png", 65, 65  )
		button2.x = display.contentWidth*90/100
		button2.y = display.contentHeight*102/100

		button3 = display.newImageRect( "assets/buttons/btnGreenNeon.png", 65, 65  )
		button3.x = display.contentWidth*90/100
		button3.y = display.contentHeight*-2/100

		button4 = display.newImageRect( "assets/buttons/btnRedNeon.png", 65, 65  )
		button4.x = display.contentWidth*10/100
		button4.y = display.contentHeight*-2/100

		restartBtn = display.newImageRect( "assets/buttons/restartNeon.png", display.contentWidth*20/100, display.contentWidth*20/100)
		restartBtn.x = display.contentWidth*85/100
		restartBtn.y = display.contentWidth*90/100

		menuBtn=display.newImageRect('assets/buttons/menuNeon.png',  display.contentWidth*20/100, display.contentWidth*20/100)
		menuBtn.x = display.contentWidth*15/100
		menuBtn.y = display.contentWidth*60/100
		menuBtn:addEventListener('tap', function()
			menuPopUp(1);
			end)
	else
		button1 = display.newImageRect( "assets/buttons/btnGreenNeon.png", 65, 65  )
		button1.x = display.contentWidth*10/100
		button1.y = display.contentHeight*102/100

		button2 = display.newImageRect( "assets/buttons/btnRedNeon.png", 65, 65  )
		button2.x = display.contentWidth*90/100
		button2.y = display.contentHeight*102/100

		button3 = display.newImageRect( "assets/buttons/btnGreenNeon.png", 65, 65  )
		button3.x = display.contentWidth*90/100
		button3.y = display.contentHeight*-2/100

		button4 = display.newImageRect( "assets/buttons/btnRedNeon.png", 65, 65  )
		button4.x = display.contentWidth*10/100
		button4.y = display.contentHeight*-2/100

		if (global.fieldType == 2) then
			restartBtn = display.newImageRect( "assets/buttons/restartBlack.png", display.contentWidth*20/100, display.contentWidth*20/100)
			restartBtn.x = display.contentWidth*85/100
			restartBtn.y = display.contentWidth*90/100
		else
			restartBtn = display.newImageRect( "assets/buttons/restartWhite.png", display.contentWidth*20/100, display.contentWidth*20/100)
			restartBtn.x = display.contentWidth*85/100
			restartBtn.y = display.contentWidth*90/100
		end

		if (global.fieldType == 2) then
			menuBtn=display.newImageRect('assets/buttons/menuBlack.png',  display.contentWidth*20/100, display.contentWidth*20/100)
			menuBtn.x = display.contentWidth*15/100
			menuBtn.y = display.contentWidth*60/100
		else
			menuBtn=display.newImageRect('assets/buttons/menuWhite.png',  display.contentWidth*20/100, display.contentWidth*20/100)
			menuBtn.x = display.contentWidth*15/100
			menuBtn.y = display.contentWidth*60/100
		end
		menuBtn:addEventListener('tap', function()
			menuPopUp(1);
			end)
	end

	--button functions
	local function reset()
		if buttonIsEnabled then
			ball.x = display.contentCenterX
			ball.y = display.contentCenterY
			stopBall()
			playerInPitch[1] = true
			playerInPitch[2] = true
			transition.pause(player1)
			transition.pause(player2)
			player1.isAwake = false
			player2.isAwake = false
			player1.y = display.contentCenterY
			player2.y = display.contentCenterY
			player1.x = display.contentCenterX - halfpost - a
			player2.x = display.contentCenterX + halfpost + a
		end

	end

	local function removeGoal()
		display.remove(goal)
	end

	local flag=1

	local function check()
		if(flag==1) then
			if(ball.y > display.contentHeight) then
				goal = display.newImageRect("assets/goal/goalDown.png", display.contentWidth, display.contentHeight)
				goal.x = display.contentCenterX
				goal.y = display.contentCenterY
				if (global.soundFlag==1) then
					audio.play(goalSound, {channel=5})
				end
				timer.performWithDelay (1000, removeGoal)
	      player2Score.text = tostring(tonumber(player2Score.text) + 1)
	      reset()
				print(("GOAL"))
				if player2Score.text == winningCondition then
					physics.pause()
					menuPopUp(2)
					print(("GOAL"))
				else
 					return score
				end
	    elseif(ball.y < -5) then
				goal = display.newImageRect("assets/goal/goalUp.png", display.contentWidth, display.contentHeight)
				goal.x = display.contentCenterX
				goal.y = display.contentCenterY
				if (global.soundFlag==1) then
					audio.play(goalSound, {channel=5})
				end
				timer.performWithDelay (1000, removeGoal)
	      player1Score.text = tostring(tonumber(player1Score.text) + 1)
	      reset()
				print(("GOAL"))
				if player1Score.text == winningCondition then
				 physics.pause()
 				 menuPopUp(2)
				 print(("GOAL"))
 			 else
 				 return score
 			 end
	    end
		end
	end

--event listerner for goal check function
	Runtime:addEventListener("enterFrame", check)

--> EVENT listeners
Runtime:addEventListener( "enterFrame", function()
	Hooking(player1, 1, redSegmentTransition, redX, redY);
end)

if global.gameMode == 1 then
	Runtime:addEventListener( "enterFrame", function()
		Hooking(player2, 2, blueSegmentTransition, blueX, blueY);
	end)
end

--event listeners for buttons
	--un solo tocco genera piu' eventi (began, moved, ended): senza filtrare la
	--fase il tiro partiva 2-3 volte, applicando piu' impulsi. invert filtra gia'
	--su "ended" al proprio interno.
	button2:addEventListener( "touch", function( event )
		if event.phase == "began" then
			shoot(player1, 1, redSegmentTransition);
		end
		return true
	end)

	if global.gameMode == 1 then
		button4:addEventListener( "touch", function( event )
			if event.phase == "began" then
				shoot(player2, 2, blueSegmentTransition);
			end
			return true
		end)
	end

	button1:addEventListener( "touch", function(event)
		invert(event, player1, 1, redSegmentTransition, redX, redY);
	end)

	if global.gameMode == 1 then
		button3:addEventListener( "touch", function(event)
			invert(event, player2, 2, blueSegmentTransition, blueX, blueY);
		end)
	end

	restartBtn:addEventListener( "tap", reset)

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( redLine )
	sceneGroup:insert( blueLine )
	sceneGroup:insert( upperNet )
	sceneGroup:insert( lowerNet )
	sceneGroup:insert( player1Score )
	sceneGroup:insert( player2Score )
	sceneGroup:insert( ball )
	sceneGroup:insert( player1 )
	sceneGroup:insert( player2 )
	sceneGroup:insert( button1 )
	sceneGroup:insert( button2 )
	sceneGroup:insert( button3 )
	sceneGroup:insert( button4 )
	sceneGroup:insert( restartBtn )
	sceneGroup:insert( menuBtn )
	if global.gameMode == 2 then
		sceneGroup:insert( target1 )
		sceneGroup:insert( target2 )
		sceneGroup:insert( target3 )
	end

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function scene:hide( event )
	sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		-- INSERT code here to pause the scene
		physics.stop()
		composer.removeScene("scenes.gameView") -- rimuove completamente la scena
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function scene:destroy( event )
	sceneGroup = self.view
	package.loaded[physics] = nil
	physics = nil
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return scene
