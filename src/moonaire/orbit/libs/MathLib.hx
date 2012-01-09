package moonaire.orbit.libs;

import moonaire.orbit.Environment;
import moonaire.orbit.Orbit;

/**
 * ...
 * @author Munir Hussin
 */

class MathLib
{
    public static var abs:Dynamic = Math.abs;
    public static var acos:Dynamic = Math.acos;
    public static var asin:Dynamic = Math.asin;
    public static var atan:Dynamic = Math.atan;
    public static var atan2:Dynamic = Math.atan2;
    public static var ceil:Dynamic = Math.ceil;
    public static var cos:Dynamic = Math.cos;
    public static var exp:Dynamic = Math.exp;
    public static var floor:Dynamic = Math.floor;
    public static var isFinite:Dynamic = Math.isFinite;
    public static var isNaN:Dynamic = Math.isNaN;
    public static var log:Dynamic = Math.log;
    public static var max:Dynamic = Math.max;
    public static var min:Dynamic = Math.min;
    
    public static var NaN:Float = Math.NaN;
    public static var NEGATIVE_INFINITY:Float = Math.NEGATIVE_INFINITY;
    public static var PI:Float = Math.PI;
    public static var TAU:Float = Math.PI * 2;
    public static var POSITIVE_INFINITY:Float = Math.POSITIVE_INFINITY;
    
    public static var pow:Dynamic = Math.pow;
    public static var random:Dynamic = Math.random;
    public static var round:Dynamic = Math.round;
    public static var sin:Dynamic = Math.sin;
    public static var sqrt:Dynamic = Math.sqrt;
    public static var tan:Dynamic = Math.tan;
    
    public static function interpolate(a:Float, b:Float, x:Float):Float
    {
        return a + (b - a) * x;
    }
    
    public static function oscillate(amplitude:Float=1, freq:Float=1, time:Float=0, phaseShift:Float=0, offset:Float=0):Float
    {
        // y = a * sin( 2 * pi * f * t + p ) + c
        return amplitude * Math.sin(TAU * freq * time + phaseShift) + offset;
    }
    
    public static function randomRange(lo:Float, hi:Float):Float
    {
        return Math.random() * (hi - lo) + lo;
    }
    
    public static function randomFuzzy(target:Float, fuzziness:Float):Float
    {
        return Math.random() * fuzziness - fuzziness * 0.5 + target;
    }
}