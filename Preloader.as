package
{
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;

    public class Preloader extends MovieClip
    {
        public function Preloader()
        {
            stop();

            stage.quality = StageQuality.LOW;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.showDefaultContextMenu = false;

            progressBar = new Shape();
            drawProgress();
            addChild(progressBar);

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private var progressBar : Shape;

        private function drawProgress() : void
        {
            const percentage : Number =
                Number(root.loaderInfo.bytesLoaded) /
                Number(root.loaderInfo.bytesTotal);

            progressBar.graphics.clear();
            progressBar.graphics.lineStyle(4, 0x008800);
            progressBar.graphics.drawRect(36, 226, 408, 28);
            progressBar.graphics.lineStyle();
            progressBar.graphics.beginFill(0x00CC00);
            progressBar.graphics.drawRect(40, 230, percentage * 400, 20);
            progressBar.graphics.endFill();
        }

        private function onEnterFrame(event : Event) : void
        {
            if(framesLoaded == totalFrames)
            {
                removeChild(progressBar);

                // So that the shape can get garbage collected, since this
                // Preloader instance lives on forever:
                progressBar = null;

                removeEventListener(Event.ENTER_FRAME, onEnterFrame);

                nextFrame();

                var mainClass : Class = Class(getDefinitionByName("tunnelgame"));
                var app : Object = new mainClass();
                parent.addChild(app as DisplayObject);
                app.start(); // start function called dynamically
            }
            else
            {
                drawProgress();
            }
        }
    }
}

