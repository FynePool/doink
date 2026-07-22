-----------------------------------------------------------------------------------------
-- ballView.lua
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--dichiarati qui e non dentro create: scene:destroy deve poterli vedere
local backBtn, ball0, ball1, ball2, ball3, leftBtn, rightBtn

-- include Corona's "widget" library
local widget = require "widget"
-- include global variables custom lua
local global = require( "lib.variables" )

--> FUNCTIONS
local function menuView()
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function menuView0()
  global.ballType = 0
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function menuView1()
  global.ballType = 1
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function menuView2()
  global.ballType = 2
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function menuView3()
  global.ballType = 3
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )
  return true
end
local function ballView2()
	composer.gotoScene( "scenes.ballView2", "crossFade", 300 )	-- event listener function
  return true
end


--> SCENE FUNCTIONS
function scene:create( event )
	local sceneGroup = self.view

--background
	local background = display.newImageRect( "assets/images/background.jpg", display.contentWidth, display.contentHeight*150/100 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	--back button
	backBtn = widget.newButton{
		defaultFile= "assets/buttons/back_round.png",
		width = display.contentWidth*20/100, height = display.contentWidth*20/100,
		onRelease = menuView
	}
	backBtn.x = display.contentWidth*13/100
	backBtn.y = display.contentHeight*1/100

--balls
ball0 = widget.newButton{
	defaultFile= "assets/balls/ball0S.png",
	overFile="assets/balls/ball0P.png",
	width = display.contentWidth*40/100, height = display.contentWidth*40/100,
	onRelease = menuView0
}
ball0.x = display.contentWidth*25/100
ball0.y = display.contentHeight*35/100

ball1 = widget.newButton{
	defaultFile= "assets/balls/ball1S.png",
	overFile="assets/balls/ball1P.png",
	width = display.contentWidth*40/100, height = display.contentWidth*40/100,
	onRelease = menuView1
}
ball1.x = display.contentWidth*75/100
ball1.y = display.contentHeight*35/100

ball2 = widget.newButton{
	defaultFile= "assets/balls/ball2S.png",
	overFile="assets/balls/ball2P.png",
	width = display.contentWidth*40/100, height = display.contentWidth*40/100,
	onRelease = menuView2
}
ball2.x = display.contentWidth*25/100
ball2.y = display.contentHeight*70/100

ball3 = widget.newButton{
	defaultFile= "assets/balls/ball3S.png",
	overFile="assets/balls/ball3P.png",
	width = display.contentWidth*40/100, height = display.contentWidth*40/100,
	onRelease = menuView3
}
ball3.x = display.contentWidth*75/100
ball3.y = display.contentHeight*70/100

--arrow buttons
rightBtn = widget.newButton{
	defaultFile= "assets/buttons/buttonRight.png",
	width = display.contentWidth*15/100, height = display.contentWidth*15/100,
	onRelease = ballView2
}
rightBtn.x = display.contentCenterX+35
rightBtn.y = display.contentHeight

leftBtn = widget.newButton{
	defaultFile= "assets/buttons/buttonLeft.png",
	width = display.contentWidth*15/100, height = display.contentWidth*15/100,
}
leftBtn.x = display.contentCenterX-35
leftBtn.y = display.contentHeight

-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( backBtn )
	sceneGroup:insert( rightBtn )
	sceneGroup:insert( leftBtn )
	sceneGroup:insert( ball0 )
	sceneGroup:insert( ball1 )
	sceneGroup:insert( ball2 )
	sceneGroup:insert( ball3 )
end

function scene:destroy( event )
	local sceneGroup = self.view
	backBtn:removeSelf()	-- widgets must be manually removed
	backBtn = nil
	rightBtn:removeSelf()	-- widgets must be manually removed
	rightBtn = nil
	leftBtn:removeSelf()	-- widgets must be manually removed
	leftBtn = nil
	ball0:removeSelf()	-- widgets must be manually removed
	ball0 = nil
  ball1:removeSelf()	-- widgets must be manually removed
	ball1 = nil
  ball2:removeSelf()	-- widgets must be manually removed
	ball2 = nil
  ball3:removeSelf()	-- widgets must be manually removed
	ball3 = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
