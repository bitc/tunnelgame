package
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.display.Shape;

    public class ShipBullet extends Sprite
    {
        public function ShipBullet(world_ : World, pos_ : Point, vel_ : Point)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;

            x = pos_.x;
            y = pos_.y;
            vel = vel_;

            var shape : Shape = new Shape();
            shape.graphics.lineStyle(1, 0xFF0000);
            shape.graphics.drawCircle(0, 0, 5);

            addChild(shape);
        }

        public function tick() : void
        {
            x += vel.x;
            y += vel.y;

            if(!world.pointInViewport(new Point(x, y)))
            {
                world.removeShipBullet(this);
            }
        }

        private var world : World;

        public var vel : Point;
    }
}

