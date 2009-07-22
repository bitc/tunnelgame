package
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.system.System;
    import flash.display.Stage;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.ui.Keyboard;
    import flash.ui.Mouse;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import Tunnel;

    [SWF(width="480", height="480", backgroundColor="#000000")]
    [Frame(factoryClass="Preloader")]

    public class tunnelgame extends Sprite
    {
        CONFIG::debugging
        {
            private var blackBars : Shape;
        }

        private var state : GameState;

        public function tunnelgame()
        {
            // the start() function acts as a constructor. Can't do any
            // initialization in the real constructor because the Preloader
            // requires that it instantiate this class and and inserts it
            // into the stage, so here in the constructor we don't yet have
            // access to the stage.
        }

        public function start() : void
        {
            stage.quality = StageQuality.LOW;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.showDefaultContextMenu = false;
            mouseEnabled = false;
            mouseChildren = false;

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

            controller = new Controller();

            CONFIG::debugging
            {
                var squaresOverlay : Shape = new Shape();
                squaresOverlay.graphics.lineStyle(1, 0x000000);
                squaresOverlay.graphics.drawRect(-1, -1, 481, 481);
                squaresOverlay.graphics.drawRect(-5, -5, 489, 489);
                addChild(squaresOverlay);

                blackBars = new Shape();
                blackBars.graphics.lineStyle();
                var barSize : int = 300;
                blackBars.graphics.beginFill(0x000000);
                blackBars.graphics.drawRect(-barSize, 0, barSize, 480);
                blackBars.graphics.drawRect(480, 0, barSize, 480);
                blackBars.graphics.drawRect(-barSize, -barSize, barSize*2+480, barSize);
                blackBars.graphics.drawRect(-barSize, 480, barSize*2+480, barSize);
                blackBars.graphics.endFill();
                addChild(blackBars);
                blackBars.visible = true;
            }

            registerMouseEvents();
            setStateMainMenu();
        }

        private function registerMouseEvents() : void
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
            stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        }

        private function unregisterMouseEvents() : void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
            stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeave);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
        }

        private function registerFocusEvents() : void
        {
            stage.addEventListener(Event.DEACTIVATE, deactivate);
        }

        private function unregisterFocusEvents() : void
        {
            stage.removeEventListener(Event.DEACTIVATE, deactivate);
        }

        private function setStateMainMenu() : void
        {
            state = GameState.MAIN_MENU;
            mainMenu = new MainMenu();
            addChild(mainMenu);
        }

        private function setStatePauseGame() : void
        {
            pauseMenu = new PauseMenu();
            addChild(pauseMenu);
            state = GameState.PAUSE_MENU;
            Mouse.show();
            registerMouseEvents();
            unregisterFocusEvents();
        }

        private function setStateUnpauseGame() : void
        {
            state = GameState.IN_GAME;
            Mouse.hide();
            unregisterMouseEvents();
            registerFocusEvents();
        }

        private var mainMenu : MainMenu;
        private var game : Game
        private var pauseMenu : PauseMenu;

        private function tick(event : Event) : void
        {
            if(state === GameState.IN_GAME)
            {
                game.tick(controller);
            }
            else if(state === GameState.MAIN_MENU)
            {
                var stayInMenu : Boolean = mainMenu.tick();
                if(!stayInMenu)
                {
                    removeChild(mainMenu);
                    mainMenu = null;

                    controller.reset();

                    game = new Game();
                    game.addToDisplay(this);
                    CONFIG::debugging
                    {
                        // Move the debugging overlays to the top
                        addChild(removeChildAt(0));
                        addChild(removeChildAt(0));
                    }

                    state = GameState.IN_GAME;
                    Mouse.hide();
                    unregisterMouseEvents();
                    registerFocusEvents();
                }
            }
            else if(state === GameState.PAUSE_MENU)
            {
                var result : int = pauseMenu.tick();
                if(result == PauseMenu.CONTINUE)
                {
                    // Don't do anything
                }
                else if(result == PauseMenu.RESUME)
                {
                    removeChild(pauseMenu);
                    pauseMenu = null;

                    setStateUnpauseGame();
                }
                else if(result == PauseMenu.MAIN_MENU)
                {
                    removeChild(pauseMenu);
                    pauseMenu = null;

                    game.removeFromDisplay(this);
                    game = null;

                    setStateMainMenu();
                }
                else
                {
                    throw new Error("PauseMenu tick() returned an unknown result");
                }
            }
            else
            {
                throw new Error("tick() called and there is no valid GameState");
            }
        }

        private var controller : Controller;

        private function keyDown(event : KeyboardEvent) : void
        {
            if(event.keyCode == 90) // Z
                controller.fire = true;
            else if(event.keyCode == Keyboard.UP)
                controller.up = true;
            else if(event.keyCode == Keyboard.DOWN)
                controller.down = true;
            else if(event.keyCode == Keyboard.LEFT)
                controller.left = true;
            else if(event.keyCode == Keyboard.RIGHT)
                controller.right = true;
            else if(event.keyCode == Keyboard.ESCAPE || event.keyCode == 80) // P
            {
                if(state === GameState.IN_GAME)
                {
                    setStatePauseGame();
                }
                else if(state === GameState.PAUSE_MENU)
                {
                    removeChild(pauseMenu);
                    pauseMenu = null;

                    setStateUnpauseGame();
                }
            }

            CONFIG::debugging
            {
                if(event.keyCode == 66) // B
                    blackBars.visible = !blackBars.visible;
            }
        }

        private function keyUp(event : KeyboardEvent) : void
        {
            if(event.keyCode == 90) // Z
                controller.fire = false;
            else if(event.keyCode == Keyboard.UP)
                controller.up = false;
            else if(event.keyCode == Keyboard.DOWN)
                controller.down = false;
            else if(event.keyCode == Keyboard.LEFT)
                controller.left = false;
            else if(event.keyCode == Keyboard.RIGHT)
                controller.right = false;
        }

        private function mouseMove(event : MouseEvent) : void
        {
            if(state === GameState.MAIN_MENU)
            {
                mainMenu.mouseMove(event.stageX, event.stageY);
            }
            else if(state === GameState.PAUSE_MENU)
            {
                pauseMenu.mouseMove(event.stageX, event.stageY);
            }
        }

        private function mouseLeave(event : Event) : void
        {
            if(state === GameState.MAIN_MENU)
            {
                mainMenu.mouseMove(-1, -1);
            }
            else if(state === GameState.PAUSE_MENU)
            {
                pauseMenu.mouseMove(-1, -1);
            }
        }

        private function mouseDown(event : MouseEvent) : void
        {
            if(state === GameState.MAIN_MENU)
            {
                mainMenu.mouseDown(event.stageX, event.stageY);
            }
            else if(state === GameState.PAUSE_MENU)
            {
                pauseMenu.mouseDown(event.stageX, event.stageY);
            }
        }

        private function mouseUp(event : MouseEvent) : void
        {
            if(state === GameState.MAIN_MENU)
            {
                mainMenu.mouseUp(event.stageX, event.stageY);
            }
            else if(state === GameState.PAUSE_MENU)
            {
                pauseMenu.mouseUp(event.stageX, event.stageY);
            }
        }

        private function deactivate(event : Event) : void
        {
            setStatePauseGame();

            controller.reset();
        }
    }
}

class GameState
{
    public static const MAIN_MENU : GameState = new GameState();
    public static const IN_GAME : GameState = new GameState();
    public static const PAUSE_MENU : GameState = new GameState();
}

