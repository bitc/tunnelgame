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
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import Tunnel;

    public class tunnelgame extends Sprite
    {
        private var pathShape : Shape;

        //private var slidingPath : SlidingPath;
        private var circle : Shape;

        private var world : Sprite;

        private var tunnel : Tunnel;

        CONFIG::debugging
        {
            private var blackBars : Shape;
        }

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

            world = new Sprite();
            addChild(world);

            pathShape = new Shape();
            world.addChild(pathShape);
            pathShape.x = 0;
            pathShape.y = 0;

            stage.addEventListener(Event.ENTER_FRAME, tick);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

            var windowRadius : Number = 340;

            tunnel = new Tunnel();

            //slidingPath = new SlidingPath(640, windowRadius);
            circle = new Shape();
            circle.graphics.lineStyle(1, 0xFF0000);
            circle.graphics.drawCircle(0, 0, windowRadius);
            circle.graphics.drawCircle(0, 0, 1);
            world.addChild(circle);

            //slidingPath.getPath().draw(pathShape.graphics);
            //slidingPath.drawTangents(pathShape.graphics);

            spaceKeyDown = false;
            controller = new Controller();
            ship = new Ship(tunnel);
            //ship.x = slidingPath.getPos().x;
            //ship.y = slidingPath.getPos().y;

            ship.x = tunnel.getPos(1).x;
            ship.y = tunnel.getPos(1).y;
            ship.tunnelQuad = tunnel.getRibsPerSegment();

            world.addChild(ship);

            tunnel.drawQuads(pathShape.graphics);

            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);

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
                blackBars.visible = false;
            }
        }
        private function mouseDown(event : MouseEvent) : void
        {
            tunnel.nextSegment();
            pathShape.graphics.clear();
            tunnel.drawQuads(pathShape.graphics);
        }

        private var ship : Ship;

        private function tick(event : Event) : void
        {
            if(!spaceKeyDown)
            {
                //if(slidingPath.advance(3))
                //{
                //    pathShape.graphics.clear();
                //    //slidingPath.getPath().draw(pathShape.graphics);
                //    slidingPath.drawTangents(pathShape.graphics);
                //}
            }
            //var pos : Point = slidingPath.getPos();
            ship.tick(controller);
            var pos : Point = new Point(ship.x, ship.y);
            circle.x = pos.x;
            circle.y = pos.y;

            world.x = 240 - pos.x;
            world.y = 240 - pos.y;
        }

        private var spaceKeyDown : Boolean;
        private var controller : Controller;

        private function keyDown(event : KeyboardEvent) : void
        {
            if(event.keyCode == Keyboard.SPACE)
                spaceKeyDown = true;
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
            if(event.keyCode == Keyboard.SPACE)
                spaceKeyDown = false;
            else if(event.keyCode == Keyboard.UP)
                controller.up = false;
            else if(event.keyCode == Keyboard.DOWN)
                controller.down = false;
            else if(event.keyCode == Keyboard.LEFT)
                controller.left = false;
            else if(event.keyCode == Keyboard.RIGHT)
                controller.right = false;
        }
    }
}

