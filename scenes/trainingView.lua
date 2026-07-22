--------------------------------------------------------------------------------------------
-- trainingView.lua
----------------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--dichiarati qui e non dentro create: scene:destroy deve poterli vedere
local backBtn

-- include Corona's "widget" library
local widget = require "widget"

--> FUNCTIONS
local function menuView()
	composer.gotoScene( "scenes.menuView", "fade", 300 )
	return true
end

--> SCENE FUNCTIONS
function scene:create( event )
	local sceneGroup = self.view

--background
	local background = display.newImageRect( "assets/images/backgroundDark.jpg", display.contentWidth, display.contentHeight*150/100 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

--buttons
	backBtn = widget.newButton{
		defaultFile= "assets/buttons/back_round.png",
		width = display.contentWidth*20/100, height = display.contentWidth*20/100,
		onRelease = menuView
	}
	backBtn.x = display.contentWidth*13/100
	backBtn.y = display.contentHeight*1/100

-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert (backBtn)
end

--[[
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
end
]]

function scene:destroy( event )

	local sceneGroup = self.view
	backBtn:removeSelf()
	backBtn = nil

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
--scene:addEventListener( "show", scene )
--scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
