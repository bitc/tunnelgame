package
{
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.geom.Point;

    public class World extends Sprite
    {
        public function World()
        {
            mouseEnabled = false;
            mouseChildren = false;

            tunnel = new Tunnel();
            ship = new Ship(tunnel);

            var startingPos : Number = 1;
            var startPoint : Point = tunnel.getPos(startingPos);
            ship.x = startPoint.x;
            ship.y = startPoint.y;
            ship.tunnelQuad = uint(tunnel.getRibsPerSegment() * startingPos);

            // Start in the middle of the tunnel
            tunnelPos = 1.0;

            cameraShake = 0;

            tunnelShape = new Shape();
            addChild(tunnelShape);
            addChild(ship);

            tunnel.drawQuads(tunnelShape.graphics);
        }

        private var tunnelShape : Shape;

        public static const VIEWPORT_WIDTH : int = 480;
        public static const VIEWPORT_HEIGHT : int = 480;

        public var tunnelPos : Number;

        // Number of frames left for camera shake effect
        private var cameraShake : int;

        public var tunnel : Tunnel;
        public var ship : Ship;

        public function doCameraShake(numFrames : int) : void
        {
            if (numFrames > cameraShake) // If camera already has a larger shake then don't lower it
                cameraShake = numFrames;
        }

        public function tick(controller : Controller) : void
        {
            if(cameraShake > 0)
            {
                cameraShake--;
                // TODO add random offset to camera x & y
            }

            var oldPos : Point = tunnel.getPos(tunnelPos);
            var advancementSpeed : Number = 0.005;
            tunnelPos += advancementSpeed;
            var pos : Point = tunnel.getPos(tunnelPos);
            var advancementVel : Point = pos.subtract(oldPos);

            var relativeShipVel : Point = (new Point(ship.velx, ship.vely)).subtract(advancementVel);

            // TODO this may be buggy...
            var viewportBounce : Number = 0.4;
            if(ship.x < pos.x - VIEWPORT_WIDTH/2)
            {
                ship.x = pos.x - VIEWPORT_WIDTH/2;
                ship.velx = -relativeShipVel.x*viewportBounce + advancementVel.x;
            }
            if(ship.y < pos.y - VIEWPORT_HEIGHT/2)
            {
                ship.y = pos.y - VIEWPORT_HEIGHT/2;
                ship.vely = -relativeShipVel.y*viewportBounce + advancementVel.y;
            }
            if(ship.x > pos.x + VIEWPORT_WIDTH/2)
            {
                ship.x = pos.x + VIEWPORT_WIDTH/2;
                ship.velx = -relativeShipVel.x*viewportBounce + advancementVel.x;
            }
            if(ship.y > pos.y + VIEWPORT_HEIGHT/2)
            {
                ship.y = pos.y + VIEWPORT_HEIGHT/2;
                ship.vely = -relativeShipVel.y*viewportBounce + advancementVel.y;
            }

            ship.tick(controller);

            if(Point.distance(pos, tunnel.getP3()) <= 450)
            {
                tunnel.nextSegment();
                tunnelShape.graphics.clear();
                tunnel.drawQuads(tunnelShape.graphics);
            }

            x = (VIEWPORT_WIDTH/2) - pos.x;
            y = (VIEWPORT_HEIGHT/2) - pos.y;
        }
    }
}

