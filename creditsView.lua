-----------------------------------------------------------------------------------------
-- creditsView.lua
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- include global variables custom lua
	local global = require( "variables" )

-----------------------------------------------------------------------------------------

--> COMPOSER FUNCTIONS
local function menuView()
	composer.gotoScene( "menuView", "fade", 300 )	-- event listener function
	return true
end
local function guideView()
	composer.gotoScene( "guideView", "slideLeft", 300)
end
local function fieldView()
	composer.gotoScene( "fieldView", "slideLeft", 300)
end
local function ballView()
	composer.gotoScene( "ballView", "slideLeft", 300 )	-- event listener function
	return true
end
local function bug()
	system.openURL( "https://it.surveymonkey.com/r/KHY83LL" )
	return true
end

-----------------------------------------------------------------------------------------
--> Switch FUNCTIONS

function playSound()
  if ( global.soundFlag==1 ) then
    global.sound = audio.loadSound("sounds/mainSound.wav")
		audio.play(global.sound, {loops=-1})
  elseif ( global.soundFlag==0 ) then
    global.sound = audio.loadSound("sounds/mainSound.wav")
    audio.pause(global.sound)
  end
end

function playSfx()
  if ( global.sfxFlag==1 ) then
    --global.sound = audio.loadSound("sounds/mainSound.wav")
		--audio.play(global.sound, {loops=-1})
  elseif ( global.fxFlag==0 ) then
    --global.sound = audio.loadSound("sounds/mainSound.wav")
    --audio.pause(global.sound)
  end
end

function musicX() -- 1=on 0=off
  if ( global.soundFlag == 1 ) then
    N = display.contentWidth*36.5/100
  elseif ( global.soundFlag == 0 ) then
    N = display.contentWidth*38.5/100
  end
  return N;
end
function musicState() -- 1=true/on 0=false/off
  if ( global.soundFlag == 1 ) then
    return true
  elseif ( global.soundFlag == 0 ) then
    return false
  end
  return N;
end

function sfxX() -- 1=on 0=off
  if ( global.sfxFlag == 1) then
    N = display.contentWidth*80.5/100
  elseif ( global.sfxFlag == 0 ) then
    N = display.contentWidth*82.5/100
  end
  return N;
end
function sfxState() -- 1=true/on 0=false/off
  if ( global.sfxFlag == 1 ) then
    return true
  elseif ( global.sfxFlag == 0 ) then
    return false
  end
  return N;
end
-----------------------------------------------------------------------------------------

--> SCENE FUNCTIONS
function scene:create( event )
	local sceneGroup = self.view

--background
	local background = display.newImageRect( "background.jpg", display.contentWidth, display.contentHeight*150/100 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

-----------------------------------------------------------------------------------------
--SEGMENT CONTROL

--DifficultyControl
	local function onSegmentPress( event )
	    local target = event.target
	    print( "Selected:", target.segmentLabel )
			global.difficulty = target.segmentNumber
			print( "Difficulty set:", global.difficulty)
	end
	local optionsDiffSmall = {
			frames =
			{
					{ x=0, y=0, width=15, height=26 },
					{ x=10, y=0, width=15, height=26 },
					{ x=20, y=0, width=15, height=26 },
					{ x=0, y=27, width=10, height=26 },
					{ x=10, y=27, width=10, height=26 },
					{ x=20, y=27, width=10, height=26 },
					{ x=35, y=27, width=4, height=26 }
			},
			sheetContentWidth = 43,
			sheetContentHeight = 85
	}
	local optionsDiff = {
			frames =
			{
					{ x=0, y=0, width=15, height=40 },
					{ x=15, y=0, width=15, height=40 },
					{ x=30, y=0, width=15, height=40 },
					{ x=0, y=40, width=15, height=40 },
					{ x=15, y=40, width=15, height=40 },
					{ x=30, y=40, width=15, height=40 },
					{ x=45, y=40, width=6, height=40 }
			},
			sheetContentWidth = 64,
			sheetContentHeight = 128
	}
	local difficultySheet = graphics.newImageSheet( "widgets/SegmentedControlBlue.png", optionsDiff )
	local difficultyControl = widget.newSegmentedControl({
	        left = display.contentWidth*36.5/100,
	        top = display.contentHeight*5/100,
	        segmentWidth = 60,
	        segments = { "Easy", "Normal", "Hard" },
	        defaultSegment = global.difficulty,
	        --labelSize=20,
		      labelColor = { default = { 1, 1, 1 }, over = { 1, 1, 1 } },
	        sheet = difficultySheet,
	        leftSegmentFrame = 1,
	        middleSegmentFrame = 2,
	        rightSegmentFrame = 3,
	        leftSegmentSelectedFrame = 4,
	        middleSegmentSelectedFrame = 5,
	        rightSegmentSelectedFrame = 6,
	        segmentFrameWidth = 15,
	        segmentFrameHeight = 40,
	        onPress = onSegmentPress
	    })

-----------------------------------------------------------------------------------------
--SWITCHES
--music
	local function musicPress( event )
	    local switch = event.target
	    print( "Switch '"..switch.id.."' is on: "..tostring(switch.isOn) )
			if ( global.soundFlag == 0) then --quando off turn on
				global.soundFlag = 1
			elseif ( global.soundFlag == 1) then --quando on turn off
				global.soundFlag = 0
			end
			print("soundFlag: ", global.soundFlag)
			playSound()
	end
	local options = {
	    frames = {
	        { x=0, y=0, width=160, height=44 },
	        { x=0, y=45, width=42, height=42 },
	        { x=44, y=45, width=42, height=42 },
	        { x=88, y=44, width=96, height=44 }
	    },
	    sheetContentWidth = 184,
	    sheetContentHeight = 88
	}
	local musicSwitchSheet = graphics.newImageSheet( "widgets/switchSheetSquare.png", options )
	local musicSwitch = widget.newSwitch(
	    {
	        x = musicX(),
	        y = display.contentHeight*28/100,
					initialSwitchState = musicState(),
	        style = "onOff",
	        id = "music",
	        onPress = musicPress,

	        sheet = musicSwitchSheet,

	        onOffBackgroundFrame = 1,
	        onOffBackgroundWidth = 160,
	        onOffBackgroundHeight = 44,
	        onOffMask = "widgets/switchMaskSquare.png",

	        onOffHandleDefaultFrame = 2,
	        onOffHandleOverFrame = 3,

	        onOffOverlayFrame = 4,
	        onOffOverlayWidth = 96,
	        onOffOverlayHeight = 44
	    }
	)
	musicSwitch.xScale = 0.7
	musicSwitch.yScale = 0.7

--sfx
	local function sfxPress( event )
	    local switch = event.target
	    print( "Switch '"..switch.id.."' is on: "..tostring(switch.isOn) )
			if ( global.sfx == 0) then
				global.sfx = 1
			else
				global.sfx = 0
			end
			print("Sfx: ", global.sfx)
			playSfx()
	end
	local options = {
			    frames = {
	        { x=0, y=0, width=160, height=44 },
	        { x=0, y=45, width=42, height=42 },
	        { x=44, y=45, width=42, height=42 },
	        { x=88, y=44, width=96, height=44 }
	    },
	    sheetContentWidth = 184,
	    sheetContentHeight = 88
	}
	local sfxSwitchSheet = graphics.newImageSheet( "widgets/switchSheetSquare.png", options )
	local sfxSwitch = widget.newSwitch(
	    {
					x = sfxX(),
	        y = display.contentHeight*28/100,
					initialSwitchState = sfxState(),
	        style = "onOff",
	        id = "sfx",
	        onPress = sfxPress,

	        sheet = sfxSwitchSheet,

	        onOffBackgroundFrame = 1,
	        onOffBackgroundWidth = 160,
	        onOffBackgroundHeight = 44,
	        onOffMask = "widgets/switchMaskSquare.png",

	        onOffHandleDefaultFrame = 2,
	        onOffHandleOverFrame = 3,

	        onOffOverlayFrame = 4,
	        onOffOverlayWidth = 96,
	        onOffOverlayHeight = 44
	    }
	)
	sfxSwitch.xScale = 0.7
	sfxSwitch.yScale = 0.7

-----------------------------------------------------------------------------------------
--> SLIDERS
-----------------------------------------------------------------------------------------
-->TEXTS

--difficulty
	local textDiff = display.newText('Difficulty:', display.contentWidth*17/100, display.contentHeight*8.8/100)
	textDiff:setFillColor( 0, 0, 0 )
	textDiff.size = 20

--music
	local textMusic = display.newText('Music:', display.contentWidth*13.5/100, display.contentHeight*28/100)
	textMusic:setFillColor( 0, 0, 0 )
	textMusic.size = 20

--sfx
	local textSfx = display.newText('SFX:', display.contentWidth*59/100, display.contentHeight*28/100)
	textSfx:setFillColor( 0, 0, 0 )
	textSfx.size = 20

--credits
	local textCrd = display.newText('App a cura di:\nAlessandro Chiabrera, Matteo Ferrini\nLuca Montenero, Riccardo Rocco', display.contentCenterX, display.contentHeight*99/100)
	textCrd:setFillColor( 0, 0, 0 )
	textCrd.size = 18

-----------------------------------------------------------------------------------------
--buttons
--back button
local backBtn = widget.newButton{
	defaultFile= "buttons/back_round.png",
	width = display.contentWidth*18/100, height = display.contentWidth*18/100,
	onRelease = menuView
}
backBtn.x = display.contentWidth*10/100
backBtn.y = display.contentHeight*1/100-15

--guide button
local guideBtn = widget.newButton{
	defaultFile= "buttons/button.png",
	overFile= "buttons/button-over.png",
	label= "Guida",
	labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } },
	width = display.contentWidth*30/100, height = display.contentWidth*15/100,
	onRelease = guideView
}
guideBtn.x = display.contentCenterX
guideBtn.y = display.contentHeight*45/100

--balls button
local ballBtn = widget.newButton{
	defaultFile= "buttons/ballView.png",
	width = display.contentWidth*30/100, height = display.contentWidth*30/100,
	onRelease = ballView
}
ballBtn.x = display.contentCenterX-65
ballBtn.y = display.contentHeight*65/100

--fields button
local fieldBtn = widget.newButton{
	defaultFile= "buttons/fieldView.png",
	width = display.contentWidth*28.125/100, height = display.contentWidth*25/100,
	onRelease = fieldView
}
fieldBtn.x = display.contentCenterX+65
fieldBtn.y = display.contentHeight*65/100

--bugs button
local bugBtn = widget.newButton{
	defaultFile= "buttons/bugBtn.png",
	width = display.contentWidth*90/100, height = display.contentWidth*21/100,
	onRelease = bug
}
bugBtn.x = display.contentCenterX-1
bugBtn.y = display.contentHeight*83/100

-----------------------------------------------------------------------------------------

-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( textCrd )
	sceneGroup:insert( textMusic )
	sceneGroup:insert( textSfx )
	sceneGroup:insert( textDiff )
	sceneGroup:insert( backBtn )
	sceneGroup:insert( guideBtn )
	sceneGroup:insert( ballBtn )
	sceneGroup:insert( fieldBtn )
	sceneGroup:insert( bugBtn )
	sceneGroup:insert( musicSwitch )
	sceneGroup:insert( sfxSwitch )
	sceneGroup:insert( difficultyControl )
end

---------------------------------------------------------------------------------

function scene:destroy( event )
	display.remove(textCrd)
	display.remove(textDiff)
	display.remove(textMusic)
	display.remove(textSfx)
	display.remove(backBtn)
	display.remove(guideBtn)
	display.remove(background)
	display.remove(bugBtn)
	musicSwitch:removeSelf()	-- widgets must be manually removed
	musicSwitch = nil
	sfxSwitch:removeSelf()	-- widgets must be manually removed
	sfxSwitch = nil
	difficultyControl:removeSelf()	-- widgets must be manually removed
	difficultyControl = nil
	backBtn:removeSelf()	-- widgets must be manually removed
	backBtn = nil
	guideBtn:removeSelf()
	guideBtn = nil
	ballBtn:removeSelf()	-- widgets must be manually removed
	ballBtn = nil
	fieldBtn:removeSelf()
	fieldBtn = nil
	bugBtn:removeSelf()
	bugBtn = nil

	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
