package
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.display.Shape;

    public class ShipBullet extends Sprite
    {
        public function ShipBullet(world_ : World, pos_ : Point, vel_ : Point, tunnelQuad_ : uint)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;
            tunnel = world_.tunnel;

            x = pos_.x;
            y = pos_.y;
            vel = vel_;

            tunnelQuad = tunnelQuad_;

            var shape : Shape = new Shape();
            shape.graphics.lineStyle(1, 0xFF0000);
            shape.graphics.drawCircle(0, 0, 5);

            addChild(shape);

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
                    throw new Error("tick() called on ShipBullet that is dead");
            }

            var endPos : Point = new Point(x + vel.x, y + vel.y);

            var ir : IntersectionResult = tunnel.calcMovementCollision(new Point(x, y), endPos, tunnelQuad);
            tunnelQuad = ir.resultingQuad;
            if(ir.intersection)
            {
                // Bullet collided with tunnel wall
                // TODO spawn debris particles
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

        private function destroySelf() : void
        {
            world.removeShipBullet(this);
            CONFIG::debugging
            {
                dead = true;
            }
        }

        private var world : World;
        private var tunnel : Tunnel;

        public var vel : Point;

        public var tunnelQuad : uint;

        CONFIG::debugging
        {
            private var dead : Boolean;
        }
    }
}

