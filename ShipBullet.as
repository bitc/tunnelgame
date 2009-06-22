package
{
    import flash.geom.Point;

    public class ShipBullet extends Bullet
    {
        public function ShipBullet(world_ : World, pos_ : Point, vel_ : Point, tunnelQuad_ : uint)
        {
            super(world_, pos_, vel_, tunnelQuad_);
            graphics.lineStyle(1, 0xFFFF00);
            graphics.drawCircle(0, 0, 5);
        }

        public override function tick() : void
        {
            super.tick();
        }

        public override function destroySelf() : void
        {
            super.destroySelf();
            world.removeShipBullet(this);
        }
    }
}

