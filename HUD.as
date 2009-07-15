package
{
    import flash.display.Sprite;
    import flash.display.Shape;

    public class HUD extends Sprite
    {
        public function HUD(world_ : World)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;

            ship = world.ship;

            healthBarShape = new Shape();
            setHealth(400);
            addChild(healthBarShape);
        }

        private var world : World;
        private var ship : Ship;

        private var healthBarShape : Shape;

        public function tick() : void
        {
        }

        private function setHealth(amount : int) : void
        {
            healthBarShape.graphics.clear();
            healthBarShape.graphics.lineStyle();
            healthBarShape.graphics.beginFill(0x00FF00, 0.25);
            healthBarShape.graphics.drawRect(5, World.VIEWPORT_HEIGHT - amount - 5, 10, amount);
            healthBarShape.graphics.endFill();
        }
    }
}


