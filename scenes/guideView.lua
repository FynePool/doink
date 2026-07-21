-----------------------------------------------------------------------------------------
-- guideView.lua
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
	composer.gotoScene( "scenes.creditsView", "slideRight", 300 )	-- event listener function
	return true
end

-----------------------------------------------------------------------------------------

--> SCENE FUNCTIONS
function scene:create( event )
	local sceneGroup = self.view

--background
	local background = display.newImageRect( "assets/images/background.jpg", display.contentWidth, display.contentHeight*150/100 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

-----------------------------------------------------------------------------------------
--> SCROLL view
-- ScrollView listener
  local function scrollListener( event )
      local phase = event.phase
      local direction = event.direction

      if event.limitReached then
        if ( "up" == direction ) then
          print("Reached top limit")
        elseif ( "down" == direction ) then
          print("Reached bottom limit")
        end
      end

      return true
  end

--Creating scroll view
local scrollView = widget.newScrollView
                {
                    top = 20,
                    left = 0,
                    width = display.contentWidth,
                    height = display.contentHeight,
                    scrollWidth = 0, --320,
                    scrollHeight = display.contentHeight, --800,
										topPadding = 350,
										bottomPadding = -270,
                    horizontalScrollDisabled = true,
                    backgroundColor = {255,255,255,0},  -- r,g,b, alpha
                    listener = scrollListener
                }

--adding text to scrollview
local filePath01 = "Come si gioca:\n1) Il gioco prevede due giocatori per la \nmodalità match. La modalità allenamento \nconsente invece di allenarsi in assenza \ndi un compagno di gioco. \n2) L'obiettivo del gioco è segnare più \ngoal dell'avversario prima dello \nscadere del timer di gioco. \n3) Ogni giocatore ha a disposizione \ndue bottoni con cui può interagire: \n     - Il tasto rosso spara il vostro player \n        all'interno del campo per colpire la \n        palla. \n     - Il tasto verde ne inverte il moto \n        lungo il bordo campo per poter \n        angolare più facilmente il tiro. \n4) A centro campo, dal lato di ciascun \ngiocatore, vengono visualizzati i powerup. \nEssi sono sorteggiati in ordine casuale \ne possono essere di tipo offensivo \no difensivo. \n"
local filePath02 = "Ogni giocatore potrà sapere quale è il \npowerup attivabile in quel momento \n(powerup di destra) e quale è il powerup \nsuccessivo che otterrà (powerup di \nsinistra); si potranno così applicare \nstrategie di gioco per sopraffare \nl'avversario. \nI powerup disponibili sono: \n     - Fiocco di neve: ferma la palla se in \n        movimento.\n     - Pugno: il giocatore viene lanciato\n        molto più velocemente per eseguire\n        un tiro più potente.\n     - Muro: il player che lo utilizza crea un\n        muro davanti alla propria porta. Se il\n        giocatore utilizza questo powerup \n        mentre non si sta muovendo sulla \n        sua metà campo ma è sganciato a \n        seguito di un tiro, il muro viene creato \n        all'altezza del player, ovunque\n        esso si trovi.\n     - Teletrasporto: teletrasporta il player \n        davanti la sua porta riagganciandolo \n        al bordo del campo. É utilizzabile \n"
local filePath03 = "        solo se il player è stato tirato.\n     - Divieto: questo powerup non ha\n        nessuna azione. É un powerup nullo, \n        introdotto solamente per rendere\n        più avvincenti le partite.\n"
local guideText01 = display.newText( filePath01 .. filePath02 .. filePath03, 0, 150)
guideText01:setFillColor(0, 0, 0)
guideText01.x = 160
scrollView:insert( guideText01 )
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
--> BUTTONS
--back button
local backBtn = widget.newButton{
	defaultFile= "assets/buttons/back_round.png",
	width = display.contentWidth*18/100, height = display.contentWidth*18/100,
	onRelease = creditsView
}
backBtn.x = display.contentWidth*10/100
backBtn.y = display.contentHeight*1/100-15
-----------------------------------------------------------------------------------------

-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( backBtn )
  sceneGroup:insert( scrollView )
  --sceneGroup:insert( guideText )
end

---------------------------------------------------------------------------------

function scene:destroy( event )
	display.remove(backBtn)
	display.remove(background)
  display.remove(scrollView)
	backBtn:removeSelf()	-- widgets must be manually removed
	backBtn = nil

	local sceneGroup = self.view
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
