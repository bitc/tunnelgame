package
{
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.display.Shape;
    import flash.display.BlendMode;

    public class Particle extends Sprite
    {
        public function Particle(world_ : World, pos_ : Point, vel_ : Point, color : uint)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;

            x = pos_.x;
            y = pos_.y;
            vel = vel_;

            age = 0;

            blendMode = BlendMode.ADD;

            graphics.lineStyle();
            graphics.beginFill(color);
            graphics.drawCircle(0, 0, 3);
            graphics.endFill();

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
                    throw new Error("tick() called on Particle that is dead");
            }

            x += vel.x;
            y += vel.y;

            age++;
            alpha -= 0.1;

            if(age == 10)
            {
                destroySelf();
            }
        }

        private function destroySelf() : void
        {
            world.removeParticle(this);
            CONFIG::debugging
            {
                dead = true;
            }
        }

        private var world : World;

        public var vel : Point;

        private var age : int;

        CONFIG::debugging
        {
            private var dead : Boolean;
        }
    }
}


