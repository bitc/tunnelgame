package
{
    public class ScoreKeeper
    {
        public function ScoreKeeper()
        {
            score = 0;
        }

        private var score : Number;

        public function getScore() : Number
        {
            return score;
        }

        public function addScore(amount : Number) : void
        {
            score += amount;
        }
    }
}

