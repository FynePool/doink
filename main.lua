-----------------------------------------------------------------------------------------
-- main.lua
-----------------------------------------------------------------------------------------
	system.activate( "multitouch" )

-- include global variables custom lua
	local global = require( "variables" )
--load sound file to prevent delay when activated or disabled
	global.sound = audio.loadSound("sounds/mainSound.wav")
--> HIDE ANDROID SYSTEM UI
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )

--> INCLUDI COMPOSER MODULE
  local composer = require "composer"

--> Default variables for beta
	global.ballType = 0
	global.fieldType = 0
	global.soundFlag = 0
	global.sfxFlag = 0
	global.difficulty = 2
	--global.playerType = 0

-- load menu screen
  composer.gotoScene( "menuView" )
