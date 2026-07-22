-----------------------------------------------------------------------------------------
-- fieldView.lua
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--dichiarati qui e non dentro create: scene:destroy deve poterli vedere
local backBtn, field0, field1, field2, field3, text

-- include Corona's "widget" library
local widget = require "widget"
-- include global variables custom lua
local global = require( "lib.variables" )

--> FUNCTIONS
local function creditsView()
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function creditsView0()
	global.fieldType = 0
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function creditsView1()
  global.fieldType = 1
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function creditsView2()
  global.fieldType = 2
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function creditsView3()
  global.fieldType = 3
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end

--> SCENE FUNCTIONS
function scene:create( event )
	local sceneGroup = self.view

--background
	local background = display.newImageRect( "assets/images/backgroundNuovo.jpg", display.contentWidth, display.contentHeight*150/100 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

  --text
  text = display.newText('Pick your field',display.contentCenterX,display.contentCenterY)
	text:setFillColor( 0, 0, 0 )
  text.size = 32
	text.x = display.contentWidth*55/100
  text.y = display.contentHeight*1/100

  field0 = widget.newButton{
  	defaultFile= "assets/fields/field0.png",
  	width = display.contentWidth*40/100, height = display.contentWidth*71/100,
  	onRelease = creditsView0
  }
  field0.x = display.contentWidth*25/100
  field0.y = display.contentHeight*32/100

  field1 = widget.newButton{
  	defaultFile= "assets/fields/field1v.png",
  	width = display.contentWidth*40/100, height = display.contentWidth*71/100,
  	onRelease = creditsView1
  }
  field1.x = display.contentWidth*75/100
  field1.y = display.contentHeight*32/100

  field2 = widget.newButton{
  	defaultFile= "assets/fields/field2v.png",
  	width = display.contentWidth*40/100, height = display.contentWidth*71/100,
  	onRelease = creditsView2
  }
  field2.x = display.contentWidth*25/100
  field2.y = display.contentHeight*82/100

  field3 = widget.newButton{
  	defaultFile= "assets/fields/field3v.png",
  	width = display.contentWidth*40/100, height = display.contentWidth*71/100,
    onRelease = creditsView3
  }
  field3.x = display.contentWidth*75/100
  field3.y = display.contentHeight*82/100

  --back button
  backBtn = widget.newButton{
  	defaultFile= "assets/buttons/back_round.png",
  	width = display.contentWidth*20/100, height = display.contentWidth*20/100,
  	onRelease = creditsView
  }
  backBtn.x = display.contentWidth*13/100
  backBtn.y = display.contentHeight*1/100

-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( backBtn )
	sceneGroup:insert( text )
	sceneGroup:insert( field0 )
	sceneGroup:insert( field1 )
  sceneGroup:insert( field2 )
  sceneGroup:insert( field3 )
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
	text:removeSelf()
	text=nil
	backBtn:removeSelf()	-- widgets must be manually removed
	backBtn = nil
	field0:removeSelf()	-- widgets must be manually removed
	field0 = nil
	field1:removeSelf()	-- widgets must be manually removed
	field1 = nil
	field2:removeSelf()	-- widgets must be manually removed
	field2 = nil
	field3:removeSelf()	-- widgets must be manually removed
	field3 = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
--scene:addEventListener( "show", scene )
--scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
