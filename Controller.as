package
{
    public class Controller
    {
        public function Controller()
        {
            reset();
        }

        public function reset() : void
        {
            up = down = left = right = fire = false;
        }

        public var up : Boolean;
        public var down : Boolean;
        public var left : Boolean;
        public var right : Boolean;
        public var fire : Boolean;
    }
}

