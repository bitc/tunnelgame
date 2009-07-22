package
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class PauseMenu extends Sprite
    {
        public function PauseMenu()
        {
            var backDrop : Shape = new Shape();
            backDrop.graphics.lineStyle();
            backDrop.graphics.beginFill(0x000000, 0.5);
            backDrop.graphics.drawRect(0, 0, World.VIEWPORT_WIDTH, World.VIEWPORT_HEIGHT);
            backDrop.graphics.endFill();
            addChild(backDrop);

            var titleLabelFormat : TextFormat = new TextFormat();
            titleLabelFormat.font = FontCollection.Rexlia().fontName;
            titleLabelFormat.color = 0xFFFFFF;
            titleLabelFormat.size = 32;

            var titleLabel : TextField = new TextField();
            titleLabel.embedFonts = true;
            titleLabel.antiAliasType = AntiAliasType.ADVANCED;
            titleLabel.width = World.VIEWPORT_WIDTH;
            titleLabel.height = 80;

            titleLabel.text = "PAUSED";
            titleLabel.setTextFormat(titleLabelFormat);

            titleLabel.x = 240 - titleLabel.textWidth/2;
            titleLabel.y = 50;

            addChild(titleLabel);

            window = new GUIWindow();

            var resumeButton : GUIButton = new GUIButton("Resume Game", 240, 200, onResumeClick);
            window.addButton(resumeButton);
            addChild(resumeButton);

            var mainMenuButton : GUIButton = new GUIButton("Back to Main Menu", 240, 380, onMainMenuClick);
            window.addButton(mainMenuButton);
            addChild(mainMenuButton);

            menuResult = PauseMenu.CONTINUE;
        }

        private var window : GUIWindow;

        private var menuResult : int;

        private function onResumeClick() : void
        {
            menuResult = PauseMenu.RESUME;
        }

        private function onMainMenuClick() : void
        {
            menuResult = PauseMenu.MAIN_MENU;
        }

        public static const CONTINUE : int = 0;
        public static const RESUME : int = 1;
        public static const MAIN_MENU : int = 2;

        public function tick() : int
        {
            window.tick();

            return menuResult;
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

