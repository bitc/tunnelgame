package
{
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class GUIButton extends Sprite
    {
        private static const width : Number = 300;
        private static const height : Number = 40;

        public function GUIButton(labelText : String, x : Number, y : Number, clickHandler : Function)
        {
            graphics.lineStyle(1, 0x00FF00);
            graphics.beginFill(0x000000);
            graphics.drawRect(-getWidth()*0.5, -getHeight()*0.5, getWidth(), getHeight());
            graphics.endFill();

            var labelFormat : TextFormat = new TextFormat();
            labelFormat.font = FontCollection.Rexlia().fontName;
            labelFormat.color = 0xFFFFFF;
            labelFormat.size = 18;

            var label : TextField = new TextField();
            label.embedFonts = true;
            label.antiAliasType = AntiAliasType.ADVANCED;
            label.width = getWidth();
            label.height = getHeight();

            label.text = labelText;
            label.setTextFormat(labelFormat);

            label.x = -label.textWidth*0.5;
            label.y = -label.textHeight*0.5;

            addChild(label);

            setX(x);
            setY(y);

            this.clickHandler = clickHandler;

            mouseIsIn = false;
            fadingOutIntensity = 0;
        }

        private var clickHandler : Function;

        public function setX(x : Number) : void
        {
            this.x = x;
        }

        public function getX() : Number
        {
            return x;
        }

        public function setY(y : Number) : void
        {
            this.y = y;
        }

        public function getY() : Number
        {
            return y;
        }

        public function getWidth() : Number
        {
            return GUIButton.width;
        }

        public function getHeight() : Number
        {
            return GUIButton.height;
        }

        public function tick() : void
        {
            scaleX = 1.0;
            scaleY = 1.0;
            if(mouseIsIn)
            {
                graphics.clear();
                if(mouseDowned)
                {
                    scaleX = 0.98;
                    scaleY = 0.96;
                    graphics.lineStyle(1, 0xFFFFFF);
                }
                else
                {
                    graphics.lineStyle(1, 0x00FF00);
                }
                graphics.beginFill(currentColorFromAnimationPhase() << 8);
                graphics.drawRect(-getWidth()*0.5, -getHeight()*0.5, getWidth(), getHeight());
                graphics.endFill();

                animationPhase++;
                if(animationPhase == GUIButton.animationCycle)
                {
                    animationPhase = 0;
                }
            }
            else
            {
                if(fadingOutIntensity > 0)
                {
                    fadingOutIntensity -= GUIButton.fadingOutSpeed;
                    if(fadingOutIntensity < 0)
                        fadingOutIntensity = 0;

                    graphics.clear();
                    graphics.lineStyle(1, 0x00FF00);
                    graphics.beginFill(fadingOutIntensity << 8);
                    graphics.drawRect(-getWidth()*0.5, -getHeight()*0.5, getWidth(), getHeight());
                    graphics.endFill();
                }
            }
        }

        private var mouseIsIn : Boolean;

        private static const animationCycle : int = 10;
        private var animationPhase : int;

        private static const fadingOutSpeed : int = 8;
        private var fadingOutIntensity : int;

        private var mouseDowned : Boolean;

        private function currentColorFromAnimationPhase() : int
        {
            const val : Number = Math.sin(Number(animationPhase) / Number(GUIButton.animationCycle) * 2 * Math.PI);
            return 120 + 40*val;
        }

        private function isPointInButton(x : Number, y : Number) : Boolean
        {
            return x >= getX() - getWidth()*0.5 && x <= getX() + getWidth()*0.5 &&
                    y >= getY() - getHeight()*0.5 && y <= getY() + getHeight()*0.5;
        }

        public function mouseMove(x : Number, y : Number) : void
        {
            if(isPointInButton(x, y))
            {
                if(!mouseIsIn)
                {
                    mouseIsIn = true;
                    animationPhase = 0;
                }
            }
            else
            {
                if(mouseIsIn)
                {
                    mouseIsIn = false;
                    fadingOutIntensity = currentColorFromAnimationPhase();
                }
            }
        }

        public function mouseDown(x : Number, y : Number) : void
        {
            if(isPointInButton(x, y))
            {
                mouseDowned = true;
            }
        }

        public function mouseUp(x : Number, y : Number) : void
        {
            if(!mouseDowned)
                return;

            mouseDowned = false;

            if(isPointInButton(x, y))
            {
                clickHandler();
            }
        }
    }
}

