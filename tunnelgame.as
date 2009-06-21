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
    import flash.events.KeyboardEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import Tunnel;

    public class tunnelgame extends Sprite
    {
        //private var slidingPath : SlidingPath;
        private var circle : Shape;

        private var world : World;

        CONFIG::debugging
        {
            private var blackBars : Shape;
        }

        private var paused : Boolean;

        public function tunnelgame()
        {
            stage.quality = StageQuality.LOW;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.showDefaultContextMenu = false;
            mouseEnabled = false;
            mouseChildren = false;

            //var path : Path = Path.createRandomPath(16, 100);

            graphics.lineStyle(1, 0x000000);
            graphics.drawRect(-1, -1, 481, 481);
            graphics.drawRect(-5, -5, 489, 489);

            world = new World();
            addChild(world);

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
            stage.addEventListener(Event.ACTIVATE, activate);
            stage.addEventListener(Event.DEACTIVATE, deactivate);

            controller = new Controller();

            CONFIG::debugging
            {
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

            paused = false;
        }

        private function tick(event : Event) : void
        {
            if(paused)
                return;

            world.tick(controller);
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

        private function activate(event : Event) : void
        {
            trace("ACTIVATE");
            paused = false;
        }

        private function deactivate(event : Event) : void
        {
            trace("DEACTIVATE");
            paused = true;
        }
    }
}

