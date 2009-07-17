package
{
    import flash.text.Font;

    public class FontCollection
    {
        [Embed(source="rexlia.ttf", fontName="Rexlia")]
        private static var RexliaFont : Class;

        public static function Rexlia() : Font
        {
            return new RexliaFont();
        }
    }
}

