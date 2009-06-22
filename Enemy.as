package
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.display.Shape;

    public class Enemy extends Sprite
    {
        public function Enemy(world_ : World, pos_ : Point)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;

            x = pos_.x;
            y = pos_.y;

            vel = new Point(0, 0);

            graphics.lineStyle();
            graphics.beginFill(0x888888);
            graphics.drawCircle(0, 0, RADIUS);
            graphics.endFill();

            inViewport = false;

            CONFIG::debugging
            {
                dead = false;
            }
        }

        private static const RADIUS : Number = 20;

        public function tick() : void
        {
            CONFIG::debugging
            {
                if(dead)
                    throw new Error("tick() called on Enemy that is dead");
            }

            x += vel.x;
            y += vel.y;

            if(!inViewport)
            {
                if(world.pointInViewport(new Point(x, y), RADIUS))
                {
                    inViewport = true;

                    // TMP Temporary:
                    graphics.clear();
                    graphics.lineStyle();
                    graphics.beginFill(0xFF0000);
                    graphics.drawCircle(0, 0, RADIUS);
                    graphics.endFill();
                }
            }
            else
            {
                if(!world.pointInViewport(new Point(x, y), RADIUS))
                {
                    destroySelf();
                }
            }
        }

        private function destroySelf() : void
        {
            world.removeEnemy(this);
            CONFIG::debugging
            {
                dead = true;
            }
        }

        public function performBulletCollision(bullet : ShipBullet) : void
        {
            var distanceSquared : Number = (x - bullet.x)*(x - bullet.x) + (y - bullet.y)*(y - bullet.y);
            if(distanceSquared > RADIUS*RADIUS)
            {
                // No collision
                return;
            }

            bullet.destroySelf();
            destroySelf();

            // TODO add to the player's score

            var i : int;
            for(i = 0; i < 100; i++)
            {
                var angle : Number = Math.random() * 2 * Math.PI;
                var speed : Number = Math.random() * 5;
                var dir : Point = new Point(
                        speed * Math.cos(angle),
                        speed * Math.sin(angle));
                var debrisParticle : Particle = new Particle(world, new Point(x, y), dir, 0xAA8822);
                world.addParticle(debrisParticle);
            }
        }

        private var world : World;

        public var vel : Point;

        private var inViewport : Boolean;

        CONFIG::debugging
        {
            private var dead : Boolean;
        }
    }
}

