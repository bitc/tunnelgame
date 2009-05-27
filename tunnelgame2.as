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
        private var pathShape : Shape;

        private var slidingPath : SlidingPath;
        private var circle : Shape;

        private var world : Sprite;

        private var tunnel : Tunnel;

        public function tunnelgame()
        {
            stage.quality = StageQuality.LOW;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.showDefaultContextMenu = false;

            //var path : Path = Path.createRandomPath(16, 100);

            graphics.lineStyle(1, 0x000000);
            graphics.drawRect(0, 0, 480, 480);
            graphics.drawRect(-4, -4, 488, 488);

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

            slidingPath = new SlidingPath(640, windowRadius);
            circle = new Shape();
            circle.graphics.lineStyle(1, 0xFF0000);
            circle.graphics.drawCircle(0, 0, windowRadius);
            circle.graphics.drawCircle(0, 0, 1);
            world.addChild(circle);

            slidingPath.getPath().draw(pathShape.graphics);
            slidingPath.drawTangents(pathShape.graphics);

            spaceKeyDown = false;
            controller = new Controller();
            ship = new Ship();
            ship.x = slidingPath.getPos().x;
            ship.y = slidingPath.getPos().y;

            world.addChild(ship);
        }

        private var ship : Ship;

        private function tick(event : Event) : void
        {
            if(!spaceKeyDown)
            {
                if(slidingPath.advance(3))
                {
                    pathShape.graphics.clear();
                    //slidingPath.getPath().draw(pathShape.graphics);
                    slidingPath.drawTangents(pathShape.graphics);
                }
            }
            var pos : Point = slidingPath.getPos();
            circle.x = pos.x;
            circle.y = pos.y;

            world.x = 240 - pos.x;
            world.y = 240 - pos.y;

            ship.tick(controller);
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

import flash.display.Graphics;
import flash.geom.Point;
import flash.display.Sprite;

class Path
{
    public var points : Array;

    public function Path()
    {
        points = new Array();
    }

    public function draw(target : Graphics) : void
    {
        target.lineStyle(1, 0x000088);
        var startingPoint : Point = points[0];
        target.moveTo(startingPoint.x, startingPoint.y);
        var i : uint;
        for(i = 1; i < points.length; ++i)
        {
            var currentPoint : Point = points[i];
            target.lineTo(currentPoint.x, currentPoint.y);
        }
    }

    public static function createRandomPath(stepSize : Number, numSteps : uint) : Path
    {
        var path : Path = new Path();
        var lastPoint : Point = new Point(0, 0);
        var lastAngle : Number = Math.random() * 2 * Math.PI;
        path.points.push(lastPoint);
        var i : uint;
        for(i = 0; i < numSteps; ++i)
        {
            var angle : Number = lastAngle + Math.random() * Math.PI - Math.PI / 2;
            lastAngle = angle;
            var nextPoint : Point = new Point(
                    lastPoint.x + stepSize * Math.cos(angle),
                    lastPoint.y + stepSize * Math.sin(angle));
            path.points.push(nextPoint);
            lastPoint = nextPoint;
        }
        return path;
    }
}

class SlidingPath
{
    public function SlidingPath(segmentLength : Number, windowRadius : Number)
    {
        this.segmentLength = segmentLength;
        this.windowRadius = windowRadius;

        lastPoint = new Point(0, 0);
        lastAngle = Math.random() * 2 * Math.PI;

        p0 = new Point(0, 0);
        p1 = nextPoint();
        p2 = nextPoint();
        p3 = nextPoint();
        p4 = nextPoint();

        pos = 0;
    }

    // Returns true if the advance caused a new segment to be created
    public function advance(distance : Number) : Boolean
    {
        pos += distance / segmentLength;
        if (Point.distance(getPos(), p3) <= windowRadius)
        {
            pos -= 1.0;
            p0 = p1; p1 = p2; p2 = p3; p3 = p4;
            p4 = nextPoint();
            return true;
        }
        else
        {
            return false;
        }
    }


    private var lastPoint : Point;
    private var lastAngle : Number;
    public function nextPoint() : Point
    {
        var angle : Number = lastAngle + Math.random() * Math.PI - Math.PI / 2;
        lastAngle = angle;
        var nextPoint : Point = new Point(
                lastPoint.x + segmentLength * Math.cos(angle),
                lastPoint.y + segmentLength * Math.sin(angle));
        lastPoint = nextPoint;
        return nextPoint;
    }

    private static function catmullRom(t : Number, p0:Point, p1:Point, p2:Point, p3:Point) : Point
    {
        return new Point(0.5 * (        (         2*p1.x                ) +
                                    t * ( -p0.x +            p2.x       ) +
                                  t*t * (2*p0.x - 5*p1.x + 4*p2.x - p3.x) +
                                t*t*t * ( -p0.x + 3*p1.x - 3*p2.x + p3.x)),
                         0.5 * (        (         2*p1.y                ) +
                                    t * ( -p0.y +            p2.y       ) +
                                  t*t * (2*p0.y - 5*p1.y + 4*p2.y - p3.y) +
                                t*t*t * ( -p0.y + 3*p1.y - 3*p2.y + p3.y)));
    }

    private static function catmullRomTangent(t : Number, p0:Point, p1:Point, p2:Point, p3:Point) : Point
    {
        // first try, no good!
        //var t0 : Point = p2.subtract(p0);
        //var t1 : Point = p3.subtract(p1);
        //return Point.interpolate(t1, t0, t); // interpolate function has backwards argument order

        // second try, no good!
        //var t0 : Point = Point.interpolate(p1, p0, t);
        //var t1 : Point = Point.interpolate(p3, p2, t);
        //return t1.subtract(t0);

        // third try... seems to work!
        return new Point(0.5 * (
                                        ( -p0.x +            p2.x       ) +
                                  2*t * (2*p0.x - 5*p1.x + 4*p2.x - p3.x) +
                                3*t*t * ( -p0.x + 3*p1.x - 3*p2.x + p3.x)),
                         0.5 * (
                                        ( -p0.y +            p2.y       ) +
                                  2*t * (2*p0.y - 5*p1.y + 4*p2.y - p3.y) +
                                3*t*t * ( -p0.y + 3*p1.y - 3*p2.y + p3.y)));
    }

    public function getPos() : Point
    {
        // calculate based on pos and p's
        if (pos < 1.0)
        {
            return catmullRom(pos, p0, p1, p2, p3);
        }
        else
        {
            return catmullRom(pos - 1.0, p1, p2, p3, p4);
        }
    }

    public function getPath() : Path
    {
        var path : Path = new Path();
        if (true)//(pos < 1.0)
        {
            var t : Number;
            for(t = 0; t < 1.0; t += 0.1)
            {
                path.points.push(catmullRom(t, p0, p1, p2, p3));
            }
            for(t = 1; t < 2.0; t += 0.1)
            {
                path.points.push(catmullRom(t - 1.0, p1, p2, p3, p4));
            }
            path.points.push(p3);
        }
        else
        {
            path.points.push(p1, p2, p3);
        }
        return path;
    }

    public function drawTangents(target : Graphics) : void
    {
        target.lineStyle(1, 0xFFFF00);

        var t : Number;
        for(t = 0; t < 1.0; t += 0.1)
        {
            var pos : Point = catmullRom(t, p0, p1, p2, p3);
            var tangent : Point = catmullRomTangent(t, p0, p1, p2, p3);
            tangent.normalize(700);

            tangent.normalize(Math.random() * 400 + 500);
            target.moveTo(pos.x, pos.y);
            target.lineTo(pos.x + 0.2*tangent.y, pos.y - 0.2*tangent.x);
            tangent.normalize(Math.random() * 400 + 500);
            target.moveTo(pos.x, pos.y);
            target.lineTo(pos.x - 0.2*tangent.y, pos.y + 0.2*tangent.x);
        }
        for(t = 0; t <= 1.0; t += 0.1)
        {
            pos = catmullRom(t, p1, p2, p3, p4);
            tangent = catmullRomTangent(t, p1, p2, p3, p4);
            tangent.normalize(700);

            tangent.normalize(Math.random() * 400 + 500);
            target.moveTo(pos.x, pos.y);
            target.lineTo(pos.x + 0.2*tangent.y, pos.y - 0.2*tangent.x);
            tangent.normalize(Math.random() * 400 + 500);
            target.moveTo(pos.x, pos.y);
            target.lineTo(pos.x - 0.2*tangent.y, pos.y + 0.2*tangent.x);
        }
    }

    private var segmentLength : Number;
    private var windowRadius : Number;

    // Always true:  0.0 <= pos < 2.0
    private var pos : Number;

    private var p0 : Point, p1 : Point, p2 : Point, p3 : Point, p4 : Point;
}

class Controller
{
    public function Controller()
    {
        up = down = left = right = false;
    }

    public var up : Boolean;
    public var down : Boolean;
    public var left : Boolean;
    public var right : Boolean;
}

class Ship extends Sprite
{
    public function Ship()
    {
        graphics.lineStyle(1, 0x008800);
        graphics.moveTo(-20, -10);
        graphics.lineTo(-20, 10);
        graphics.lineTo(20, 0);
        graphics.lineTo(-20, -10);
        graphics.drawCircle(0, 0, 1);

        x = 0;
        y = 0;

        velx = 0;
        vely = 0;
    }

    private var velx : Number;
    private var vely : Number;

    public function tick(controller : Controller) : void
    {
        var rotationSpeed : Number = 5;
        var acceleration : Number = 0.2;

        if(controller.up)
        {
            velx += acceleration * Math.cos(rotation * Math.PI / 180);
            vely += acceleration * Math.sin(rotation * Math.PI / 180);
        }
        if(controller.down)
        {
            velx -= acceleration * Math.cos(rotation * Math.PI / 180);
            vely -= acceleration * Math.sin(rotation * Math.PI / 180);
        }
        if(controller.left)
            rotation -= rotationSpeed;
        if(controller.right)
            rotation += rotationSpeed;

        x += velx;
        y += vely;
    }
}

