package
{
    public class GUIWindow
    {
        public function GUIWindow()
        {
            buttons = new Array();
        }

        public function addButton(button : GUIButton) : void
        {
            buttons.push(button);
        }

        private var buttons : Array;

        public function tick() : void
        {
            var i : int;
            for(i = 0; i < buttons.length; i++)
            {
                var button : GUIButton = buttons[i];
                button.tick();
            }
        }

        public function mouseMove(x : Number, y : Number) : void
        {
            var i : int;
            for(i = 0; i < buttons.length; i++)
            {
                var button : GUIButton = buttons[i];
                button.mouseMove(x, y);
            }
        }

        public function mouseDown(x : Number, y : Number) : void
        {
            var i : int;
            for(i = 0; i < buttons.length; i++)
            {
                var button : GUIButton = buttons[i];
                button.mouseDown(x, y);
            }
        }

        public function mouseUp(x : Number, y : Number) : void
        {
            var i : int;
            for(i = 0; i < buttons.length; i++)
            {
                var button : GUIButton = buttons[i];
                button.mouseUp(x, y);
            }
        }
    }
}

