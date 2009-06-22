package
{
    import flash.geom.Point;

    public class EnemyBullet extends Bullet
    {
        public function EnemyBullet(world_ : World, pos_ : Point, vel_ : Point, tunnelQuad_ : uint)
        {
            super(world_, pos_, vel_, tunnelQuad_);
            graphics.lineStyle(1, 0xFF0000);
            graphics.drawCircle(0, 0, 6);
        }

        public override function tick() : void
        {
            super.tick();
        }

        public override function destroySelf() : void
        {
            super.destroySelf();
            world.removeEnemyBullet(this);
        }
    }
}

