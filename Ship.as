package
{
    import flash.display.Sprite;
    import flash.geom.Point;

    public class Ship extends Sprite
    {
        public function Ship(tunnel_ : Tunnel)
        {
            mouseEnabled = false;
            mouseChildren = false;

            graphics.lineStyle(1, 0x008800);
            graphics.moveTo(-20, -10);
            graphics.lineTo(-20, 10);
            graphics.lineTo(20, 0);
            graphics.lineTo(-20, -10);
            graphics.drawCircle(0, 0, 1);

            x = 0;
            y = 0;

            tunnel = tunnel_;

            velx = 0;
            vely = 0;
        }

        private var velx : Number;
        private var vely : Number;

        private var tunnel : Tunnel;

        public var tunnelQuad : uint;

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

            var endPos : Point = new Point(x + velx, y + vely);

            var ir : IntersectionResult = tunnel.calcMovementCollision(new Point(x, y), endPos, tunnelQuad);

            trace(tunnelQuad);
            tunnelQuad = ir.resultingQuad;
            if(ir.intersection)
            {
                var vel : Point = new Point(velx, vely);
                var d : Number = Tunnel.pointDot(vel, new Point(-ir.normal.x, -ir.normal.y)) / (vel.length*ir.normal.length);
                //ir.normal.normalize(d * vel.length); // * (1 + bounce);
                ir.normal.normalize(d * vel.length * (1 + 0.5));

                vel = vel.add(ir.normal)
                velx = vel.x;
                vely = vel.y;

                x = ir.intersectionPoint.x;
                y = ir.intersectionPoint.y;
            }
            else
            {
                x += velx;
                y += vely;
            }
        }
    }
}

