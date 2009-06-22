package
{
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.display.Bitmap;

    public class World extends Sprite
    {
        public function World()
        {
            mouseEnabled = false;
            mouseChildren = false;

            tunnel = new Tunnel();
            ship = new Ship(this);

            shipBullets = new Array();
            enemyBullets = new Array();
            particles = new Array();
            enemies = new Array();

            var startingPos : Number = 1;
            var startPoint : Point = tunnel.getPos(startingPos);
            ship.x = startPoint.x;
            ship.y = startPoint.y;
            ship.tunnelQuad = uint(tunnel.getRibsPerSegment() * startingPos);

            // Start in the middle of the tunnel
            tunnelPos = 1.0;

            cameraShake = 0;

            surface = new Surface();

            surfaceShape = new Shape();
            surfaceShape.graphics.beginFill(0x0000FF);
            surfaceShape.graphics.beginBitmapFill(surface.bitmapData);
            surfaceShape.graphics.lineStyle();
            surfaceShape.graphics.drawRect(-100000, -100000, 200000, 200000);
            surfaceShape.graphics.endFill();

            tunnelShape = new Shape();

            addChild(surfaceShape);
            addChild(tunnelShape);
            addChild(ship);

            drawTunnel();
        }

        [Embed(source="surface.jpg")]
        private var Surface : Class;
        private var surface : Bitmap;

        private var tunnelShape : Shape;
        private var surfaceShape : Shape;

        public static const VIEWPORT_WIDTH : int = 480;
        public static const VIEWPORT_HEIGHT : int = 480;

        public var tunnelPos : Number;

        // Number of frames left for camera shake effect
        private var cameraShake : int;

        public var tunnel : Tunnel;
        public var ship : Ship;

        public var shipBullets : Array;
        public var enemyBullets : Array;
        public var particles : Array;
        public var enemies : Array;

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
        public function addEnemyBullet(bullet : EnemyBullet) : void
        {
            enemyBullets.push(bullet);
            addChild(bullet);
        }

        public function removeEnemyBullet(bullet : EnemyBullet) : void
        {
            enemyBullets.splice(enemyBullets.indexOf(bullet), 1);
            removeChild(bullet);
        }

        public function addParticle(particle : Particle) : void
        {
            particles.push(particle);
            addChild(particle);
        }

        public function removeParticle(particle : Particle) : void
        {
            particles.splice(particles.indexOf(particle), 1);
            removeChild(particle);
        }

        public function addEnemy(enemy : Enemy) : void
        {
            enemies.push(enemy);
            addChild(enemy);
        }

        public function removeEnemy(enemy : Enemy) : void
        {
            enemies.splice(enemies.indexOf(enemy), 1);
            removeChild(enemy);
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
                drawTunnel();

                spawnEnemies();
            }

            x = (VIEWPORT_WIDTH/2) - pos.x + (Math.random()-0.5) * cameraShake * 2;
            y = (VIEWPORT_HEIGHT/2) - pos.y + (Math.random()-0.5) * cameraShake * 2;

            tickEntities();
            checkCollisions();
        }

        private function tickEntities() : void
        {
            // Traverse over copies of the arrays because they might be modified during traversal
            var i : uint;

            var shipBulletsCopy : Array = shipBullets.slice();
            for(i = 0; i < shipBulletsCopy.length; ++i)
            {
                var shipBullet : ShipBullet = shipBulletsCopy[i];
                shipBullet.tick();
            }
            var enemyBulletsCopy : Array = enemyBullets.slice();
            for(i = 0; i < enemyBulletsCopy.length; ++i)
            {
                var enemyBullet : EnemyBullet = enemyBulletsCopy[i];
                enemyBullet.tick();
            }

            var particlesCopy : Array = particles.slice();
            for(i = 0; i < particlesCopy.length; ++i)
            {
                var particle : Particle = particlesCopy[i];
                particle.tick();
            }

            var enemiesCopy : Array = enemies.slice();
            for(i = 0; i < enemiesCopy.length; ++i)
            {
                var enemy : Enemy = enemiesCopy[i];
                enemy.tick();
            }
        }

        private function checkCollisions() : void
        {
            // Traverse over copies of the arrays because they might be modified during traversal
            var i : uint;
            var j : uint;

            var shipBulletsCopy : Array = shipBullets.slice();
            var enemiesCopy : Array = enemies.slice();
            for(i = 0; i < shipBulletsCopy.length; i++)
            {
                for(j = 0; j < enemiesCopy.length; j++)
                {
                    // Verify that the current ShipBullet and Enemy have not been destroyed
                    if(shipBullets.indexOf(shipBulletsCopy[i]) >= 0 && enemies.indexOf(enemiesCopy[j]) >= 0)
                    {
                        var bullet : ShipBullet = shipBulletsCopy[i];
                        var enemy : Enemy = enemiesCopy[j];
                        enemy.performBulletCollision(bullet);
                    }
                }
            }
        }

        private function drawTunnel() : void
        {
            tunnelShape.graphics.clear();
            tunnel.drawLines(tunnelShape.graphics);
            tunnel.drawQuads(tunnelShape.graphics);
        }

        private function spawnEnemies() : void
        {
            var i : int;
            var head : Number = tunnel.getHead();
            for(i = 0; i < 8; i++)
            {
                if(Math.random() <= 0.2)
                {
                    var pos : Point = tunnel.getPos(head + 1 + (Number(i)/8));
                    var newEnemy : Enemy = new Enemy(this, pos);
                    addEnemy(newEnemy);
                }
            }
        }
    }
}

