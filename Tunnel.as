package
{
    import flash.geom.Point;
    import flash.display.Graphics;

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

            var segmentLength : Number = 900;
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

        private static function lineRayIntersection(p1 : Point, p2 : Point, p3 : Point, p4 : Point) : Number
        {
            var denom : Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
            if (denom == 0)
            {
                return NaN;
            }

            var ub : Number = ((p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x)) / denom;

            if(ub >= 0 && ub <= 1)
            {
                return ub;
            }
            else
            {
                return NaN;
            }
        }

        private static function rayHalfSpaceIntersection(p1 : Point, p2 : Point, p3 : Point, p4 : Point) : Number
        {
            var normal : Point = new Point(p4.y - p3.y, p3.x - p4.x);
            var traj : Point = p2.subtract(p1);
            if(pointDot(traj, normal) >= 0)
                return NaN;

            var denom : Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
            if (denom == 0)
            {
                return NaN;
            }

            var ua : Number = ((p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x)) / denom;

            if(ua >= -100000 && ua <= 1)
            {
                return ua;
            }
            else
            {
                return NaN;
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

        public function getHead() : Number
        {
            return pCount;
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

        public function getP3() : Point
        {
            return p3;
        }

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

            do
            {
                var rib0 : LineSegment = ribGetLineSegment(currentQuad);
                var rib1 : LineSegment = ribGetLineSegment(currentQuad + 1);

                var u0 : Number = rayHalfSpaceIntersection(currentPos, endPos, rib0.p0, rib1.p0);
                var u1 : Number = rayHalfSpaceIntersection(currentPos, endPos, rib1.p1, rib0.p1);
                var u2 : Number = rayHalfSpaceIntersection(currentPos, endPos, rib0.p1, rib0.p0);
                var u3 : Number = rayHalfSpaceIntersection(currentPos, endPos, rib1.p0, rib1.p1);

                var traj : Point = endPos.subtract(currentPos);

                if(!isNaN(u0) && (isNaN(u2) || u0 <= u2) && (isNaN(u3) || u0 <= u3))
                {
                    result.resultingQuad = currentQuad;
                    result.intersection = true;
                    result.intersectionPoint = currentPos.add(pointMul(u0, traj));
                    result.normal = new Point(rib1.p0.y - rib0.p0.y, rib0.p0.x - rib1.p0.x);
                    return result;
                }
                if(!isNaN(u1) && (isNaN(u2) || u1 <= u2) && (isNaN(u3) || u1 <= u3))
                {
                    result.resultingQuad = currentQuad;
                    result.intersection = true;
                    result.intersectionPoint = currentPos.add(pointMul(u1, traj));
                    result.normal = new Point(rib0.p1.y - rib1.p1.y, rib1.p1.x - rib0.p1.x);
                    return result;
                }

                restart = false;

                if(!isNaN(u2))
                {
                    currentQuad -= 1;
                    currentPos = currentPos.add(pointMul(u2, traj));
                    restart = true;
                }
                if(!isNaN(u3))
                {
                    currentQuad += 1;
                    currentPos = currentPos.add(pointMul(u3, traj));
                    restart = true;
                }
            } while(restart);

            result.resultingQuad = currentQuad;
            result.intersection = false;
            return result;
        }

        public function drawQuads(g : Graphics) : void
        {
            var i : uint;
            for(i = getFirstRibIndex(); i < getFirstRibIndex() + ribsPerSegment * 2 - 1; ++i)
            {
                var r0 : LineSegment = ribGetLineSegment(i);
                var r1 : LineSegment = ribGetLineSegment(i+1);

                var v0 : Point = r0.p0;
                var v1 : Point = r0.p1;
                var v2 : Point = r1.p1;
                var v3 : Point = r1.p0;
                g.moveTo(v0.x, v0.y);
                g.beginFill(0x221818);
                g.lineStyle();
                g.lineTo(v1.x, v1.y);
                g.lineTo(v2.x, v2.y);
                g.lineTo(v3.x, v3.y);
                g.endFill();
            }
        }

        public function drawLines(g : Graphics) : void
        {
            var i : uint;
            var r0 : LineSegment;
            var v0 : Point;

            g.lineStyle(16, 0x000000);
            r0 = ribGetLineSegment(getFirstRibIndex());
            v0 = r0.p0;
            g.moveTo(v0.x, v0.y);
            for(i = getFirstRibIndex()+1; i < getFirstRibIndex() + ribsPerSegment * 2; ++i)
            {
                r0 = ribGetLineSegment(i);
                v0 = r0.p0;
                g.lineTo(v0.x, v0.y);
            }
            r0 = ribGetLineSegment(getFirstRibIndex());
            v0 = r0.p1;
            g.moveTo(v0.x, v0.y);
            for(i = getFirstRibIndex()+1; i < getFirstRibIndex() + ribsPerSegment * 2; ++i)
            {
                r0 = ribGetLineSegment(i);
                v0 = r0.p1;
                g.lineTo(v0.x, v0.y);
            }
        }

        public function drawDebug(g : Graphics) : void
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
        var maxAngle : Number = 0.7 * Math.PI;
        var angle : Number = lastAngle + Math.random() * maxAngle - maxAngle / 2;
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

