-----------------------------------------------------------------------------------------
-- main.lua
-----------------------------------------------------------------------------------------
	system.activate( "multitouch" )

-- include global variables custom lua
	local global = require( "lib.variables" )
--load sound file to prevent delay when activated or disabled
--loadStream e non loadSound: il brano dura oltre 4 minuti e loadSound lo
--terrebbe interamente decompresso in memoria
	global.sound = audio.loadStream("assets/sounds/mainSound.mp3")
--> HIDE ANDROID SYSTEM UI
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )

--> INCLUDI COMPOSER MODULE
  local composer = require "composer"

--> Default variables for beta
	global.ballType = 0
	global.fieldType = 0
	global.soundFlag = 0
	global.sfxFlag = 1
	global.difficulty = 2
	--global.playerType = 0

-- load menu screen
  composer.gotoScene( "scenes.menuView" )
