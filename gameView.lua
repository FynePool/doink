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
local global = require( "variables" )

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

	local ballDensity = 0.0030
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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> GAME
	function scene:create( event )
	physics.start()
	physics.setGravity(0,0)
	sceneGroup = self.view


--> SOUND
	local goalSound = audio.loadSound('sounds/goal.wav')

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

	local i = {}
	i[1]=0
	i[2]=0
	local j = {}
	j[1]=0
	j[2]=0
	local delta = {}
	delta[1]=1
	delta[2]=1


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
	local function invert(player, n, SegmentTransition, playerX, playerY)
		if not playerInPitch[n] then
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
		if not playerInPitch[n] then
			if player.x == display.contentCenterX - a - halfpost then
				transition.pause(player)
        player:applyLinearImpulse( shootPowerDefault, 0, player.x, player.y)
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
      elseif player.x == display.contentCenterX + a + halfpost then
				transition.pause(player)
      	player:applyLinearImpulse( -shootPowerDefault, 0, player.x, player.y)
      end
			playerInPitch[n] = true
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
	  shootPowerDefault=0.01
	end

	local function restoreWall(n)
		if wall[n] then
			physics.removeBody( wall[n] )
			wall[n]:removeSelf()
		end
	end

	--funzione che regola l'uso dei powerups
	local function powerup_usage(player, n, SegmentTransition, playerX, playerY)
			--power_button_red.fill.effect = "filter.grayscale"
			power_button[n].alpha=0
			used[n]=true
			print ("X")
			if current[n]==1 then
				print ("a")
				powerup_sound[n] = audio.loadSound( "sounds/powerup1_sound.wav")
				audio.play(powerup1_sound, {channel=6})
				ball.isAwake=false
			elseif current[n]==2 then
				print ("b")
				if not wall[n] then
					powerup_sound[n] = audio.loadSound( "sounds/powerup2_sound.wav" )
					audio.play(powerup2_sound, {channel=6})
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
					powerup_sound[n] = audio.loadSound( "sounds/powerup4a_sound.wav" )
					audio.play(powerup_sound[n], {channel=6})
				end
			elseif current[n]==3 then
				print ("c")
				powerup_sound[n] = audio.loadSound( "sounds/powerup3_sound.wav" )
				audio.play(powerup_sound[n], {channel=6})
				shootPowerDefault=shootPowerDefault*2
				timer.performWithDelay(4000, restorePower)
			elseif current[n]==4 then
				print ("d")
				if playerInPitch[n] then
					powerup_sound[n] = audio.loadSound( "sounds/powerup4_sound.wav" )
					audio.play(powerup_sound[n], {channel=6})
					goNet(player, n, SegmentTransition, playerX, playerY)
				else
					powerup_sound[n] = audio.loadSound( "sounds/powerup4a_sound.wav" )
					audio.play(powerup_sound[n], {channel=6})
				end
			elseif current[n]==5 then
				powerup_sound[n] = audio.loadSound( "sounds/powerup4a_sound.wav" )
				audio.play(powerup_sound[n], {channel=6})
			end
			print ("Y")
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
				loading[n]=display.newImageRect("powerups/powerup1.png", 30, 30 )
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==2 then
				loading[n]=display.newImageRect("powerups/powerup2.png", 30, 30 )
				loading[n].alpha=1
				print("B2")
			elseif rand[n]==3 then
				loading[n]=display.newImageRect("powerups/powerup3.png", 30, 30 )
				loading[n].alpha=1
				print("B3")
			elseif rand[n]==4 then
				loading[n]=display.newImageRect("powerups/powerup4.png", 30, 30 )
				loading[n].alpha=1
				print("B4")
			elseif rand[n]==5 then
				loading[n]=display.newImageRect("powerups/powerup5.png", 30, 30 )
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
					power_button[n]=display.newImageRect("powerups/powerup1.png", 30, 30 )
				elseif rand[n]==2 then
					power_button[n]=display.newImageRect("powerups/powerup2.png", 30, 30 )
				elseif rand[n]==3 then
					power_button[n]=display.newImageRect("powerups/powerup3.png", 30, 30 )
				elseif rand[n]==4 then
					power_button[n]=display.newImageRect("powerups/powerup4.png", 30, 30 )
				elseif rand[n]==5 then
					power_button[n]=display.newImageRect("powerups/powerup5.png", 30, 30 )
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
				loading[n]=display.newImageRect("powerups/powerup1.png", 30, 30 )
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==2 then
				loading[n]=display.newImageRect("powerups/powerup2.png", 30, 30 )
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==3 then
				loading[n]=display.newImageRect("powerups/powerup3.png", 30, 30 )
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==4 then
				loading[n]=display.newImageRect("powerups/powerup4.png", 30, 30 )
				loading[n].alpha=1
				print("B1")
			elseif rand[n]==5 then
				loading[n]=display.newImageRect("powerups/powerup5.png", 30, 30 )
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
				power_button[n]=display.newImageRect("powerups/powerup1.png", 30, 30 )
			elseif rand[n]==2 then
				power_button[n]=display.newImageRect("powerups/powerup2.png", 30, 30 )
			elseif rand[n]==3 then
				power_button[n]=display.newImageRect("powerups/powerup3.png", 30, 30 )
			elseif rand[n]==4 then
				power_button[n]=display.newImageRect("powerups/powerup4.png", 30, 30 )
			elseif rand[n]==5 then
				power_button[n]=display.newImageRect("powerups/powerup5.png", 30, 30 )
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


	powerup_start[2]=timer.performWithDelay( 700, function()
																powerup(player2, 2, blueSegmentTransition, blueX, blueY);
															end)
	powerup_start[1]=timer.performWithDelay( 700, function()
																powerup(player1, 1, redSegmentTransition, redX, redY);
															end)

--MENU
local function menuView()
	timer.pause(powerup_start[1])
	timer.pause(powerup_start[2])
	if loading[1] then
		loading[1]:removeSelf()
	end
	if loading[2] then
		loading[2]:removeSelf()
	end
	if power_button[1] then
		power_button[1]:removeSelf()
	end
	if power_button[2] then
		power_button[2]:removeSelf()
	end
	if wall[1] then
		wall[1]:removeSelf()
	end
	if wall[2] then
		wall[2]:removeSelf()
	end
	composer.gotoScene( "menuView", "fade", 300 )
	return true
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> BACKGROUND
	if (global.fieldType==1) then
		background = display.newImageRect( "fields/field1.png", display.contentWidth, display.contentHeight*119/100 )
		background.x = display.contentCenterX
		background.y = display.contentCenterY
	elseif (global.fieldType==2) then
		background = display.newImageRect( "fields/field2.png", display.contentWidth, display.contentHeight*119/100 )
		background.x = display.contentCenterX
		background.y = display.contentCenterY
	elseif (global.fieldType==3) then
		background = display.newImageRect( "fields/field3.png", display.contentWidth, display.contentHeight*119/100 )
		background.x = display.contentCenterX
		background.y = display.contentCenterY
	else
		background = display.newImageRect( "fields/field0.png", display.contentWidth, display.contentHeight*119/100 )
		background.x = display.contentCenterX
		background.y = display.contentCenterY
	end

	--> GOALS
	if (global.fieldType==0) then
		porta1 = display.newImageRect("fields/porta100.png", 80, 80)
		porta1.x = display.contentCenterX
		porta1.y = display.contentHeight*3.6/100
		porta2 = display.newImageRect("fields/porta200.png", 80, 80)
		porta2.x = display.contentCenterX
		porta2.y = display.contentHeight*96.4/100
	end

--[[ lasciate commentato plz
if (global.fieldType==0) then
	porta1 = display.newImageRect(".png", 80, 80)
	porta1.x = display.contentCenterX
	porta1.y = display.contentHeight*3.6/100
	porta2 = display.newImageRect(".png", 80, 80)
	porta2.x = display.contentCenterX
	porta2.y = display.contentHeight*96.4/100
elseif (global.fieldType==1) then
	porta1 = display.newImageRect(".png", 80, 80)
	porta1.x = display.contentCenterX
	porta1.y = display.contentHeight*3.6/100
	porta2 = display.newImageRect(".png", 80, 80)
	porta2.x = display.contentCenterX
	porta2.y = display.contentHeight*96.4/100
end
]]
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

	if (global.fieldType==2) then
		--blueLine:setStrokeColor(0, 1, 0, 0.6)
	else
		--blueLine:setStrokeColor(0, 0, 1, 0.4)
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

	if (global.fieldType==3) then
		--redLine:setStrokeColor(153, 0, 153, 0.4)
	elseif (global.fieldType==2) then
		--redLine:setStrokeColor(1, 0, 0, 0.6)
	else
		--redLine:setStrokeColor(1, 0, 0, 0.4)
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
if (global.fieldType==3) then
	player1Score = display.newText('0',display.contentCenterX, display.contentHeight*80/100, 'Courier-Bold',display.contentHeight*20/100)
	player1Score:setTextColor(153, 0, 153, 0.4)
else
	player1Score = display.newText('0',display.contentCenterX, display.contentHeight*80/100, 'Courier-Bold',display.contentHeight*20/100)
	player1Score:setTextColor(1, 0, 0, 0.4)
end

if (global.fieldType==2) then
	player2Score = display.newText('0', display.contentCenterX, display.contentHeight*18/100, 'Courier-Bold', display.contentHeight*20/100)
	player2Score:setTextColor(0, 1, 0, 0.4)
else
	player2Score = display.newText('0', display.contentCenterX, display.contentHeight*18/100, 'Courier-Bold', display.contentHeight*20/100)
	player2Score:setTextColor(0, 0, 1, 0.4)
end

--> BALL

if(global.ballType==1) then
	ball = display.newImageRect( "balls/ball1.png", ballDim, ballDim)
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	physics.addBody( ball, "dynamic", {radius=ballDim/2, bounce=1, filter = ballCollisionFilter})
elseif(global.ballType==2) then
	ball = display.newImageRect( "balls/ball2.png", ballDim, ballDim)
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	physics.addBody( ball, "dynamic", {radius=ballDim/2, bounce=1, filter = ballCollisionFilter})
elseif(global.ballType==3) then
	ball = display.newImageRect( "balls/ball3.png", ballDim, ballDim)
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	physics.addBody( ball, "dynamic", {radius=ballDim/2, bounce=1, filter = ballCollisionFilter})
elseif(global.ballType==4) then
	ball = display.newImageRect( "balls/ball4.png", ballDim, ballDim)
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	physics.addBody( ball, "dynamic", {radius=ballDim/2, bounce=1, filter = ballCollisionFilter})
elseif(global.ballType==5) then
	ball = display.newImageRect( "balls/ball5.png", ballDim, ballDim)
	ball.x = display.contentCenterX
	ball.y = display.contentCenterY
	physics.addBody( ball, "dynamic", {radius=ballDim/2, bounce=1, filter = ballCollisionFilter})
else
	ball = display.newCircle(display.contentCenterX, display.contentCenterY, ballDim/2)
	ball:setFillColor(1)
	physics.addBody(ball, "dynamic", {density=ballDensity, radius=ballDim/2, bounce=1, filter = ballCollisionFilter})
end

--> PLAYERS

	player1 = display.newCircle(display.contentCenterX - a - halfpost, display.contentCenterY, pdim)
	player1:setFillColor(1, 0, 0, 1)
	physics.addBody(player1, "dynamic", {density=playerDensity, radius=pdim/2, bounce=1, filter = redPlayerCollisionFilter})

	player2 = display.newCircle(display.contentCenterX - a - halfpost, display.contentCenterY, pdim)
	player2:setFillColor(0, 0, 1, 1)
	physics.addBody(player2, "dynamic", {density=playerDensity, radius=pdim/2, bounce=1, filter = bluePlayerCollisionFilter})

	onCompleteMove(player2, 2, blueSegmentTransition, blueX, blueY )  -- start moving
	onCompleteMove(player1, 1, redSegmentTransition, redX, redY )  -- start moving

--> BUTTONS

	button1 = display.newImageRect( "buttons/bottone2_prova.png", 180, 180  )
	button1.x = display.contentWidth*10/100
	button1.y = display.contentHeight*102/100

	button2 = display.newImageRect( "buttons/bottone1_prova.png", 180, 180  )
	button2.x = display.contentWidth*90/100
	button2.y = display.contentHeight*102/100

	button3 = display.newImageRect( "buttons/bottone2_prova.png", 180, 180  )
	button3.x = display.contentWidth*90/100
	button3.y = display.contentHeight*-2/100

	button4 = display.newImageRect( "buttons/bottone1_prova.png", 180, 180  )
	button4.x = display.contentWidth*10/100
	button4.y = display.contentHeight*-2/100

	restartBtn = display.newImageRect( "buttons/restart_round.png", display.contentWidth*20/100, display.contentWidth*20/100)
	restartBtn.x = display.contentWidth*85/100
	restartBtn.y = display.contentWidth*25/100

	menuBtn=display.newImageRect('buttons/menu_round.png',  display.contentWidth*20/100, display.contentWidth*20/100)
	menuBtn.x = display.contentWidth*15/100
	menuBtn.y = display.contentWidth*25/100
	menuBtn:addEventListener('tap', menuView)

	--button functions
	local function reset()
		ball.x = display.contentCenterX
		ball.y = display.contentCenterY
		ball.isAwake = false
	end

	local function removeGoal()
		display.remove(goal)
	end

	local flag=1

	local function check()
		if(flag==1) then
			if(ball.y > display.contentHeight) then
				goal = display.newImageRect("goal/goalDown.png", display.contentWidth, display.contentHeight)
				goal.x = display.contentCenterX
				goal.y = display.contentCenterY
				if (global.soundFlag==1) then
					audio.play(goalSound, {channel=5})
				end
				timer.performWithDelay (1000, removeGoal)
	      player2Score.text = tostring(tonumber(player2Score.text) + 1)
	      ball.x = display.contentCenterX
	      ball.y = display.contentCenterY
	      ball.isAwake = false
	      score = score+1
	      return score
	    elseif(ball.y < -5) then
				goal = display.newImageRect("goal/goalUp.png", display.contentWidth, display.contentHeight)
				goal.x = display.contentCenterX
				goal.y = display.contentCenterY
				if (global.soundFlag==1) then
					audio.play(goalSound, {channel=5})
				end
				timer.performWithDelay (1000, removeGoal)
	      player1Score.text = tostring(tonumber(player1Score.text) + 1)
	      ball.x = display.contentCenterX
	      ball.y = display.contentCenterY
	      ball.isAwake = false
	      score = score+1
	      return score
	    end
		end
	end

--> EVENT LISTENERS

--event listeners for powerup4_sound
	--timer.performWithDelay(9000, powerup, 0)

--event listerner for goal check function
	Runtime:addEventListener("enterFrame", check)

--event listeners for buttons
	button2:addEventListener( "touch", function()
		shoot(player1, 1, redSegmentTransition);
	end)

	button4:addEventListener( "touch", function()
		shoot(player2, 2, blueSegmentTransition);
	end)

	button1:addEventListener( "touch", function()
		invert(player1, 1, redSegmentTransition, redX, redY);
	end)

	button3:addEventListener( "touch", function()
		invert(player2, 2, blueSegmentTransition, blueX, blueY);
	end)

	Runtime:addEventListener( "enterFrame", function()
		Hooking(player1, 1, redSegmentTransition, redX, redY);
	end)

	Runtime:addEventListener( "enterFrame", function()
		Hooking(player2, 2, blueSegmentTransition, blueX, blueY);
	end)

	restartBtn:addEventListener( "tap", reset)



	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	if (porta1) then
	sceneGroup:insert( porta1 )
	end
	if (porta2) then
		sceneGroup:insert( porta2 )
	end
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
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function scene:hide( event )
	sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		-- INSERT code here to pause the scene
		physics.stop()
		composer.removeScene("gameView") -- rimuove completamente la scena
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
