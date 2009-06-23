package
{
    import flash.display.Sprite;
    import flash.geom.Point;

    public class Ship extends Sprite
    {
        public function Ship(world_ : World)
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

            weaponCharge = 0;

            world = world_;
            tunnel = world_.tunnel;

            velx = 0;
            vely = 0;
        }

        public var velx : Number;
        public var vely : Number;

        private var world : World;
        private var tunnel : Tunnel;

        private var weaponCharge : uint;

        public var tunnelQuad : uint;

        public function tick(controller : Controller) : void
        {
            var rotationSpeed : Number = 5;
            var acceleration : Number = 0.2;

            if(controller.up)
            {
                velx += acceleration * Math.cos(rotation * Math.PI / 180);
                vely += acceleration * Math.sin(rotation * Math.PI / 180);

                var i : int;
                for(i=0; i<15; i++)
                {
                    var speed : Number = Math.random() * 10;
                    var rotationOffset : Number = Math.random() * 40 - 20;
                    var dir : Point = new Point(
                            -speed * Math.cos((rotation + rotationOffset) * Math.PI / 180),
                            -speed * Math.sin((rotation + rotationOffset) * Math.PI / 180));
                    var thrustParticle : Particle = new Particle(world, new Point(
                                x - 20 * Math.cos(rotation * Math.PI / 180),
                                y - 20 * Math.sin(rotation * Math.PI / 180)),
                            dir.add(new Point(velx, vely)), 0x3333FF);
                    world.addParticle(thrustParticle);
                }
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

                var damage : Number = d * vel.length;
                world.doCameraShake(int(damage));

                // TODO decrease health
            }
            else
            {
                x += velx;
                y += vely;
            }

            if(weaponCharge > 0)
                weaponCharge--;

            if(controller.fire && weaponCharge == 0)
            {
                const weaponChargeTime : uint = 10;
                weaponCharge = weaponChargeTime;

                var bulletSpeed : Number = 10;
                var shipVel : Point = new Point(velx, vely);
                var shipDir : Point = new Point(
                        bulletSpeed * Math.cos(rotation * Math.PI / 180),
                        bulletSpeed * Math.sin(rotation * Math.PI / 180));
                var newBullet : ShipBullet = new ShipBullet(world, new Point(x, y), shipDir.add(shipVel), tunnelQuad);
                world.addShipBullet(newBullet);
            }
        }

        public function performBulletCollision(bullet : EnemyBullet) : void
        {
            var distanceSquared : Number = (x - bullet.x)*(x - bullet.x) + (y - bullet.y)*(y - bullet.y);
            const radius : Number = 10;
            if(distanceSquared > radius*radius)
            {
                // No collision
                return;
            }

            bullet.destroySelf();
            world.doCameraShake(10);

            // TODO decrease health
        }

        public function performEnemyCollision(enemy : Enemy) : void
        {
            var distanceSquared : Number = (x - enemy.x)*(x - enemy.x) + (y - enemy.y)*(y - enemy.y);
            var totalRadius : Number = 10 + enemy.getRadius();
            if(distanceSquared > totalRadius*totalRadius)
            {
                // No collision
                return;
            }

            world.doCameraShake(10);

            enemy.explodeAndDestroy();

            var normal : Point = new Point(x - enemy.x, y - enemy.y);

            var vel : Point = new Point(velx, vely);
            var d : Number = Tunnel.pointDot(vel, new Point(-normal.x, -normal.y)) / (vel.length*normal.length);
            normal.normalize(d * vel.length * (1 + 0.7));

            vel = vel.add(normal)
            velx = vel.x;
            vely = vel.y;


            // TODO decrease health
        }
    }
}

