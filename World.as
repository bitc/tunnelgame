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
            ship = new Ship(this);

            shipBullets = new Array();

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

        public var shipBullets : Array;

        public function addShipBullet(bullet : ShipBullet) : void
        {
            shipBullets.push(bullet);
            addChild(bullet);
        }

        public function removeShipBullet(bullet : ShipBullet) : void
        {
            shipBullets.splice(shipBullets.indexOf(bullet), 1);
            removeChild(bullet);
        }

        public function doCameraShake(numFrames : int) : void
        {
            if (numFrames > cameraShake) // If camera already has a larger shake then don't lower it
                cameraShake = numFrames;
        }

        public function pointInViewport(p : Point, margin : Number) : Boolean
        {
            var pos : Point = tunnel.getPos(tunnelPos);
            if(p.x < pos.x - VIEWPORT_WIDTH/2 - margin)
                return false;
            if(p.x > pos.x + VIEWPORT_WIDTH/2 + margin)
                return false;
            if(p.y < pos.y - VIEWPORT_HEIGHT/2 - margin)
                return false;
            if(p.y > pos.y + VIEWPORT_WIDTH/2 + margin)
                return false;

            return true;
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

            x = (VIEWPORT_WIDTH/2) - pos.x + (Math.random()-0.5) * cameraShake * 2;
            y = (VIEWPORT_HEIGHT/2) - pos.y + (Math.random()-0.5) * cameraShake * 2;

            var i : uint;
            for(i = 0; i < shipBullets.length; ++i)
            {
                var bullet : ShipBullet = shipBullets[i];
                bullet.tick();
            }
        }
    }
}

