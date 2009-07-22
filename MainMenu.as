package
{
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class MainMenu extends Sprite
    {
        public function MainMenu()
        {
            var titleLabelFormat : TextFormat = new TextFormat();
            titleLabelFormat.font = FontCollection.Rexlia().fontName;
            titleLabelFormat.color = 0xFFFFFF;
            titleLabelFormat.size = 32;

            var titleLabel : TextField = new TextField();
            titleLabel.embedFonts = true;
            titleLabel.antiAliasType = AntiAliasType.ADVANCED;
            titleLabel.width = World.VIEWPORT_WIDTH;
            titleLabel.height = 80;

            titleLabel.text = "tunnelgame";
            titleLabel.setTextFormat(titleLabelFormat);

            titleLabel.x = 20;
            titleLabel.y = 20;

            addChild(titleLabel);

            mainMenuFinished = false;

            window = new GUIWindow();

            var newGameButton : GUIButton = new GUIButton("New Game", 240, 200, onNewGameClick);
            window.addButton(newGameButton);
            addChild(newGameButton);

            var instructionsButton : GUIButton = new GUIButton("Instructions", 240, 260, onInstructionsClick);
            window.addButton(instructionsButton);
            addChild(instructionsButton);

            var achievementsButton : GUIButton = new GUIButton("Achievements", 240, 320, onAchievementsClick);
            window.addButton(achievementsButton);
            addChild(achievementsButton);

            var creditsButton : GUIButton = new GUIButton("Credits", 240, 380, onCreditsClick);
            window.addButton(creditsButton);
            addChild(creditsButton);
        }

        private var window : GUIWindow;

        private function onNewGameClick() : void
        {
            trace("NEW GAME");
            mainMenuFinished = true;
        }

        private var mainMenuFinished : Boolean;

        private function onAchievementsClick() : void
        {
            trace("ACHIEVEMENTS");
            // TODO
        }

        private function onInstructionsClick() : void
        {
            trace("INSTRUCTIONS");
            // TODO
        }

        private function onCreditsClick() : void
        {
            trace("CREDITS");
            // TODO
        }

        public function tick() : Boolean
        {
            window.tick();

            return !mainMenuFinished;
        }

        public function mouseMove(x : Number, y : Number) : void
        {
            window.mouseMove(x, y);
        }

        public function mouseDown(x : Number, y : Number) : void
        {
            window.mouseDown(x, y);
        }

        public function mouseUp(x : Number, y : Number) : void
        {
            window.mouseUp(x, y);
        }
    }
}

