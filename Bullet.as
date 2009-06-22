package
{
    import flash.display.Sprite;
    import flash.geom.Point;

    public class Bullet extends Sprite
    {
        public function Bullet(world_ : World, pos_ : Point, vel_ : Point, tunnelQuad_ : uint)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;
            tunnel = world_.tunnel;

            x = pos_.x;
            y = pos_.y;
            vel = vel_;

            tunnelQuad = tunnelQuad_;

            CONFIG::debugging
            {
                dead = false;
            }
        }

        public function tick() : void
        {
            CONFIG::debugging
            {
                if(dead)
                    throw new Error("tick() called on Bullet that is dead");
            }

            var endPos : Point = new Point(x + vel.x, y + vel.y);

            var ir : IntersectionResult = tunnel.calcMovementCollision(new Point(x, y), endPos, tunnelQuad);
            tunnelQuad = ir.resultingQuad;
            if(ir.intersection)
            {
                handleTunnelWallCollision(ir);
                destroySelf();
                return;
            }

            x = endPos.x;
            y = endPos.y;

            if(!world.pointInViewport(endPos, 20))
            {
                destroySelf();
            }
        }

        public function handleTunnelWallCollision(ir : IntersectionResult) : void
        {
            // Bullet collided with tunnel wall
            var angle : Number = Math.atan2(ir.normal.y, ir.normal.x);
            var i : int;
            for(i = 0; i < 30; i++)
            {
                var speed : Number = Math.random() * 5;
                var rotationOffset : Number = Math.random() * 2 - 1;
                var dir : Point = new Point(
                        speed * Math.cos(angle + rotationOffset),
                        speed * Math.sin(angle + rotationOffset));
                var debrisParticle : Particle = new Particle(world, ir.intersectionPoint, dir, 0xAA8822);
                world.addParticle(debrisParticle);
            }
        }

        public function destroySelf() : void
        {
            CONFIG::debugging
            {
                dead = true;
            }
        }

        protected var world : World;
        protected var tunnel : Tunnel;

        public var vel : Point;

        public var tunnelQuad : uint;

        CONFIG::debugging
        {
            private var dead : Boolean;
        }
    }
}

