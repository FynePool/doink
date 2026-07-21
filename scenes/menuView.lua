-----------------------------------------------------------------------------------------
-- menuView.lua
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
-- include global variables custom lua
	local global = require( "lib.variables" )

-----------------------------------------------------------------------------------------

--> FUNCTIONS
local function creditsView()
	composer.gotoScene( "scenes.creditsView", "fade", 300 )	-- event listener function
	return true
end
local function gameView()
	composer.gotoScene( "scenes.gameView", "fade", 300 )
	return true
end
local function trainingView()
	composer.gotoScene( "scenes.trainingView", "fade", 300)
end

-----------------------------------------------------------------------------------------

--> SCENE FUNCTIONS
function scene:create( event )
	local sceneGroup = self.view

--background
	local background = display.newImageRect( "assets/images/backgroundDark.jpg", display.contentWidth, display.contentHeight*150/100 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

--play button (avvia il game)
	local playBtn = widget.newButton{
		defaultFile="assets/buttons/playBtn.png",
		overFile="assets/buttons/playBtnPressed.png",
		width= display.contentWidth*67.5/100,
		height= display.contentHeight*16.5/100,
		onRelease = gameView
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight*30/100

	--training button
	local trnBtn = widget.newButton{
		defaultFile="assets/buttons/trnBtn.png",
		overFile="assets/buttons/trnBtnPressed.png",
		width= display.contentWidth*67.5/100,
		height= display.contentHeight*16.5/100,
		onRelease = trainingView
	}
	trnBtn.x = display.contentCenterX
	trnBtn.y = display.contentHeight*60/100

--credits button
	local crdBtn = widget.newButton{
		defaultFile="assets/buttons/settings.png",
		overFile="assets/buttons/settingsPressed.png",
		width=35, height=35,
		onRelease = creditsView
	}
	crdBtn.x = display.contentWidth*88/100
	crdBtn.y = display.contentHeight*102/100

-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( crdBtn )
	sceneGroup:insert ( trnBtn )
end

-----------------------------------------------------------------------------------------

function scene:destroy( event )
	local sceneGroup = self.view
	playBtn:removeSelf()	-- widgets must be manually removed
	playBtn = nil
	crdBtn:removeSelf()
	crdBtn = nil
	trnBtn:removeSelf()
	trnBtn = nil
end

-----------------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
