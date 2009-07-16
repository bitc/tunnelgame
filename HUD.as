package
{
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.text.AntiAliasType;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class HUD extends Sprite
    {
        public function HUD(world_ : World)
        {
            mouseEnabled = false;
            mouseChildren = false;

            world = world_;

            ship = world.ship;

            healthBarShape = new Shape();
            setHealth(ship.getHealth());
            addChild(healthBarShape);

            scoreLabelFormat = new TextFormat();
            var rexliaFontInstance : Font = new RexliaFont();
            scoreLabelFormat.font = rexliaFontInstance.fontName;
            scoreLabelFormat.color = 0xFFFFFF;
            scoreLabelFormat.size = 16;

            scoreLabel = new TextField();
            scoreLabel.alpha = 0.8;

            scoreLabel.embedFonts = true;
            scoreLabel.antiAliasType = AntiAliasType.ADVANCED;
            scoreLabel.width = World.VIEWPORT_WIDTH;
            scoreLabel.height = 40;

            setScore(0);

            addChild(scoreLabel);
        }

        [Embed(source="rexlia.ttf", fontName="Rexlia")]
        private var RexliaFont : Class;

        private var scoreLabel : TextField;
        private var scoreLabelFormat : TextFormat;

        private var world : World;
        private var ship : Ship;

        private var healthBarShape : Shape;

        public function tick() : void
        {
            setHealth(ship.getHealth());

            setScore(world.scoreKeeper.getScore());
        }

        private function setHealth(amount : int) : void
        {
            healthBarShape.graphics.clear();
            healthBarShape.graphics.lineStyle();
            healthBarShape.graphics.beginFill(0x00FF00, 0.25);
            healthBarShape.graphics.drawRect(5, World.VIEWPORT_HEIGHT - amount - 5, 10, amount);
            healthBarShape.graphics.endFill();
        }

        private function setScore(amount : Number) : void
        {
            scoreLabel.text = "score: " + amount;
            scoreLabel.setTextFormat(scoreLabelFormat);
        }
    }
}


