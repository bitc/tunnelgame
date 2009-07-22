package
{
    import flash.display.DisplayObjectContainer;

    public class Game
    {
        public function Game()
        {
            var scoreKeeper : ScoreKeeper = new ScoreKeeper();

            world = new World(scoreKeeper);
            hud = new HUD(world);
        }

        private var world : World;
        private var hud : HUD;

        public function addToDisplay(display : DisplayObjectContainer) : void
        {
            display.addChild(world);
            display.addChild(hud);
        }

        public function removeFromDisplay(display : DisplayObjectContainer) : void
        {
            display.removeChild(hud);
            display.removeChild(world);
        }

        public function tick(controller : Controller) : void
        {
            world.tick(controller);
            hud.tick();
        }
    }
}

