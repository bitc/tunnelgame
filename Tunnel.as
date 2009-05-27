package
{
    import flash.geom.Point;
    import flash.display.Graphics;
    import flash.display.Bitmap;

    public class Tunnel
    {
        public function Tunnel()
        {
            pCount = 0;

            ribsPerSegment = 8;
            //ribsPerSegment = 16;
            minRibLength = 120;
            maxRibLength = 200;
            //maxRibLength = 400;

            var segmentLength : Number = 700;
            tunnelBuilder = new TunnelBuilder(segmentLength);

            p0 = tunnelBuilder.nextPoint();
            p1 = tunnelBuilder.nextPoint();
            p2 = tunnelBuilder.nextPoint();
            p3 = tunnelBuilder.nextPoint();
            p4 = tunnelBuilder.nextPoint();

            ribs = new Array();
            var i : uint;
            for(i = 0; i < ribsPerSegment * 2; ++i)
            {
                pushRib();
            }

            // TODO delete this (temporary):
            nebula = new Nebula();
        }

        private static function testLineSegmentIntersection(p1 : Point, p2 : Point, p3 : Point, p4 : Point) : Boolean
        {
            var denom : Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
            if (denom == 0)
                return false;

            var ua : Number = ((p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x)) / denom;
            var ub : Number = ((p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x)) / denom;

            if(ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1)
                return true;
            else
                return false;
        }

        
        private static function lineSegmentIntersection(p1 : Point, p2 : Point, p3 : Point, p4 : Point) : Point
        {
            var denom : Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
            if (denom == 0)
            {
                return null;
            }

            var ua : Number = ((p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x)) / denom;
            var ub : Number = ((p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x)) / denom;

            if(ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1)
            {
                return p1.add(pointMul(ua, p2.subtract(p1)));
            }
            else
            {
                return null;
            }
        }

        private static function lineRayIntersection(p1 : Point, p2 : Point, p3 : Point, p4 : Point) : uint
        {
            var denom : Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
            if (denom == 0)
            {
                return null;
            }

            var ua : Number = ((p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x)) / denom;
            var ub : Number = ((p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x)) / denom;

            if(ub >= 0 && ub <= 1)
            {
                return ub;
            }
            else
            {
                return null;
            }
        }

        private function pushRib() : void
        {
            var newRibIsBad : Boolean;
            do
            {
                var rib : Rib = new Rib(
                        Math.random() * (maxRibLength - minRibLength) + minRibLength,
                        Math.random() * (maxRibLength - minRibLength) + minRibLength);
                ribs.push(rib);

                var newRib : LineSegment = ribGetLineSegment(getFirstRibIndex() + ribs.length - 1);
                newRibIsBad = false;
                var i : uint;
                for(i = getFirstRibIndex(); i < getFirstRibIndex() + ribs.length - 1; ++i)
                {
                    var currentRib : LineSegment = ribGetLineSegment(i);
                    if(testLineSegmentIntersection(currentRib.p0, currentRib.p1, newRib.p0, newRib.p1))
                    {
                        newRibIsBad = true;
                        trace("------- bad -------" + (getFirstRibIndex() + ribs.length - 1) + ", " + i);
                    }
                }
                if(newRibIsBad)
                    ribs.pop();
                // TODO instead of loop, shrink the rib on the side of the intersection
            } while(newRibIsBad);
        }

        private var ribsPerSegment : uint;
        private var minRibLength : Number;
        private var maxRibLength : Number;

        public function getRibsPerSegment() : uint
        {
            return ribsPerSegment;
        }

        public function nextSegment() : void
        {
            ribs.splice(0, ribsPerSegment);
            pCount++;
            p0 = p1; p1 = p2; p2 = p3; p3 = p4;
            p4 = tunnelBuilder.nextPoint();
            var i : uint;
            for(i = 0; i < ribsPerSegment; ++i)
            {
                pushRib();
            }
        }

        public function getPos(d : Number) : Point
        {
            if(d < pCount)
                throw new Error("getPos out of range (too small)");
            if(d > pCount + 2)
                throw new Error("getPos out of range (too large)");

            if(d <= pCount + 1)
                return catmullRom(d - pCount, p0, p1, p2, p3);
            else
                return catmullRom(d - pCount - 1, p1, p2, p3, p4);
        }

        public function getTangent(d : Number) : Point
        {
            if(d < pCount)
                throw new Error("getTangent out of range (too small)");
            if(d > pCount + 2)
                throw new Error("getTangent out of range (too large)");

            if(d <= pCount + 1)
                return catmullRomTangent(d - pCount, p0, p1, p2, p3);
            else
                return catmullRomTangent(d - pCount - 1, p1, p2, p3, p4);
        }

        public function getRib(n : uint) : Rib
        {
            if(n < pCount*ribsPerSegment)
                throw new Error("getRib out of range (too small)");
            if(n >= pCount*ribsPerSegment + ribsPerSegment*2)
                throw new Error("getRib out of range (too large)");

            return ribs[n - pCount*ribsPerSegment];
        }

        private var p0 : Point, p1 : Point, p2 : Point, p3 : Point, p4 : Point;

        private var ribs : Array;

        private var pCount : uint;

        private var tunnelBuilder : TunnelBuilder;

        private static function catmullRom(t : Number, p0:Point, p1:Point, p2:Point, p3:Point) : Point
        {
            return new Point(0.5 * (        (         2*p1.x                ) +
                                        t * ( -p0.x +            p2.x       ) +
                                      t*t * (2*p0.x - 5*p1.x + 4*p2.x - p3.x) +
                                    t*t*t * ( -p0.x + 3*p1.x - 3*p2.x + p3.x)),
                             0.5 * (        (         2*p1.y                ) +
                                        t * ( -p0.y +            p2.y       ) +
                                      t*t * (2*p0.y - 5*p1.y + 4*p2.y - p3.y) +
                                    t*t*t * ( -p0.y + 3*p1.y - 3*p2.y + p3.y)));
        }

        private static function catmullRomTangent(t : Number, p0:Point, p1:Point, p2:Point, p3:Point) : Point
        {
            return new Point(0.5 * (
                                            ( -p0.x +            p2.x       ) +
                                      2*t * (2*p0.x - 5*p1.x + 4*p2.x - p3.x) +
                                    3*t*t * ( -p0.x + 3*p1.x - 3*p2.x + p3.x)),
                             0.5 * (
                                            ( -p0.y +            p2.y       ) +
                                      2*t * (2*p0.y - 5*p1.y + 4*p2.y - p3.y) +
                                    3*t*t * ( -p0.y + 3*p1.y - 3*p2.y + p3.y)));
        }

        static public function pointMul(s : Number, p : Point) : Point
        {
            return new Point(s * p.x, s * p.y);
        }

        static public function pointDot(p0 : Point, p1 : Point) : Number
        {
            return p0.x*p1.x + p0.y*p1.y;
        }

        // TODO delete this (temporary):
        [Embed(source="nebula.png")]
        private var Nebula : Class;
        private var nebula : Bitmap;

        private function getFirstRibIndex() : uint
        {
            return pCount * ribsPerSegment;
        }

        private function ribGetLineSegment(n : uint) : LineSegment
        {
            var p0 : Point = getPos(n / ribsPerSegment);
            var t0 : Point = getTangent(n / ribsPerSegment);
            t0.normalize(1);
            t0 = new Point(t0.y, -t0.x);

            var v0 : Point = p0.subtract(pointMul(ribs[n - pCount*ribsPerSegment].negativeLength, t0));
            var v1 : Point = p0.add(pointMul(ribs[n - pCount*ribsPerSegment].positiveLength, t0));

            return new LineSegment(v0, v1);
        }

        public function calcMovementCollision(startPos : Point, endPos : Point, startQuad : uint) : IntersectionResult
        {
            var currentQuad : uint = startQuad;
            var currentPos : Point = startPos;
            var restart : Boolean;
            var result : IntersectionResult = new IntersectionResult();
            var p : Point;

            trace("----- T0 -------");
            do
            {
                var rib0 : LineSegment = ribGetLineSegment(currentQuad);
                var rib1 : LineSegment = ribGetLineSegment(currentQuad + 1);

                var traj : Point = endPos.subtract(currentPos);

                var normal : Point = new Point(rib1.p0.y - rib0.p0.y, rib0.p0.x - rib1.p0.x);
                if(pointDot(traj, normal) < 0)
                {
                    p = lineSegmentIntersection(rib1.p0, rib0.p0, currentPos, endPos);
                    if(p)
                    {
                        trace("----- TL -------");
                        result.resultingQuad = currentQuad;
                        result.intersection = true;
                        result.intersectionPoint = p;
                        result.normal = normal;
                        return result;
                    }
                }
                normal = new Point(rib0.p1.y - rib1.p1.y, rib1.p1.x - rib0.p1.x);
                if(pointDot(traj, normal) < 0)
                {
                    p = lineSegmentIntersection(rib1.p1, rib0.p1, currentPos, endPos);
                    if(p)
                    {
                        trace("----- TR -------");
                        result.resultingQuad = currentQuad;
                        result.intersection = true;
                        result.intersectionPoint = p;
                        result.normal = normal;
                        return result;
                    }
                }

                restart = false;

                normal = new Point(rib0.p0.y - rib0.p1.y, rib0.p1.x - rib0.p0.x);
                if(pointDot(traj, normal) < 0)
                {
                    p = lineSegmentIntersection(rib0.p0, rib0.p1, currentPos, endPos);
                    if(p)
                    {
                        trace("----- T- -------");
                        currentQuad -= 1;
                        currentPos = p;
                        restart = true;
                    }
                }

                normal = new Point(rib1.p1.y - rib1.p0.y, rib1.p0.x - rib1.p1.x);
                if(pointDot(traj, normal) < 0)
                {
                    p = lineSegmentIntersection(rib1.p0, rib1.p1, currentPos, endPos);
                    if(p)
                    {
                        trace("----- T+ -------");
                        currentQuad += 1;
                        currentPos = p;
                        restart = true;
                    }
                }
            } while(restart);

            trace("----- T1 -------");
            result.resultingQuad = currentQuad;
            result.intersection = false;
            return result;
        }

        public function drawQuads(g : Graphics) : void
        {
            g.lineStyle(3, 0x00FFFF);

            g.moveTo(0, 0);
            g.lineTo(p0.x, p0.y);
            g.lineTo(p1.x, p1.y);
            g.lineTo(p2.x, p2.y);
            g.lineTo(p3.x, p3.y);
            g.lineTo(p4.x, p4.y);

            g.lineStyle(1, 0xFFFF00);

            g.drawCircle(p0.x, p0.y, 5);
            g.drawCircle(p1.x, p1.y, 5);
            g.drawCircle(p2.x, p2.y, 5);
            g.drawCircle(p3.x, p3.y, 5);
            g.drawCircle(p4.x, p4.y, 5);

            var i : uint;
            for(i = getFirstRibIndex(); i < getFirstRibIndex() + ribsPerSegment * 2 - 1; ++i)
            {
                var r0 : LineSegment = ribGetLineSegment(i);
                var r1 : LineSegment = ribGetLineSegment(i+1);

                var v0 : Point = r0.p0;
                var v1 : Point = r0.p1;
                var v2 : Point = r1.p1;
                var v3 : Point = r1.p0;
                //g.beginFill(0x0000FF);
                //g.beginBitmapFill(nebula.bitmapData);
                //g.lineStyle();
                g.lineStyle(1, 0xFFFF00);
                g.moveTo(v0.x, v0.y);
                g.lineTo(v1.x, v1.y);
                g.lineTo(v2.x, v2.y);
                g.lineTo(v3.x, v3.y);
                //g.endFill();

                var p0 : Point = getPos(i / ribsPerSegment);
                var t0 : Point = getTangent(i / ribsPerSegment);
                t0.normalize(1);
                g.lineStyle(1, 0x00FF00);
                g.drawCircle(p0.x, p0.y, 3);
                g.moveTo(p0.x, p0.y);
                g.lineTo(p0.x + 10*t0.y, p0.y - 10*t0.x);
            }
            return;

            for(i = 0; i < ribsPerSegment * 2 - 1; ++i)
            {
                var p0 : Point = getPos(pCount + i / ribsPerSegment);
                var t0 : Point = getTangent(pCount + i / ribsPerSegment);
                t0.normalize(1);
                t0 = new Point(t0.y, -t0.x);

                var p1 : Point = getPos(pCount + (i+1) / ribsPerSegment);
                var t1 : Point = getTangent(pCount + (i+1) / ribsPerSegment);
                t1.normalize(1);
                t1 = new Point(t1.y, -t1.x);

                var v0 : Point = p0.subtract(pointMul(ribs[i].negativeLength, t0));
                var v1 : Point = p0.add(pointMul(ribs[i].positiveLength, t0));
                var v2 : Point = p1.add(pointMul(ribs[i+1].positiveLength, t1));
                var v3 : Point = p1.subtract(pointMul(ribs[i+1].negativeLength, t1));

                //g.beginFill(0x0000FF);
                //g.beginBitmapFill(nebula.bitmapData);
                //g.lineStyle();
                g.lineStyle(1, 0xFFFF00);
                g.moveTo(v0.x, v0.y);
                g.lineTo(v1.x, v1.y);
                g.lineTo(v2.x, v2.y);
                g.lineTo(v3.x, v3.y);
                //g.endFill();

                g.lineStyle(1, 0x00FF00);
                g.drawCircle(p0.x, p0.y, 3);
                g.moveTo(p0.x, p0.y);
                g.lineTo(p0.x + 10*t0.y, p0.y - 10*t0.x);
            }
        }
    }
}

import flash.geom.Point;

class LineSegment
{
    public function LineSegment(p0_ : Point, p1_ : Point)
    {
        p0 = p0_;
        p1 = p1_;
    }

    public var p0 : Point;
    public var p1 : Point;
}

class Rib
{
    public function Rib(n : Number, p : Number)
    {
        negativeLength = n;
        positiveLength = p;
    }

    public var negativeLength : Number;
    public var positiveLength : Number;
}

class TunnelBuilder
{
    public function TunnelBuilder(segmentLength : Number)
    {
        this.segmentLength = segmentLength;

        lastPoint = new Point(0, 0);
        lastAngle = Math.random() * 2 * Math.PI;
    }

    public function nextPoint() : Point
    {
        var angle : Number = lastAngle + Math.random() * Math.PI - Math.PI / 2;
        lastAngle = angle;

        var nextPoint : Point = new Point(
                lastPoint.x + segmentLength * Math.cos(angle),
                lastPoint.y + segmentLength * Math.sin(angle));
        lastPoint = nextPoint;

        return nextPoint;
    }

    private var segmentLength : Number;
    private var lastPoint : Point;
    private var lastAngle : Number;
}

