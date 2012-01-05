package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.Orbit;

/**
 * ...
 * @author Munir Hussin
 */

class Comparison 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // (== a b c true false 0)
        g.defineSyntax("==", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            // short-circuiting
            var a0:Dynamic = orbit.eval(a[0], e);
            
            for (i in 1...a.length)
            {
                var ax = orbit.eval(a[i], e);
                if (a0 != ax) return false;
            }
            return true;
        });
        
        // (!= a b c true false 0)
        g.defineSyntax("!=", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            // short-circuiting
            var a0:Dynamic = orbit.eval(a[0], e);
            
            for (i in 1...a.length)
            {
                var ax = orbit.eval(a[i], e);
                if (a0 == ax) return false;
            }
            return true;
        });
        
        // (< 1 4 3 7) === 1 < 4 < 3 < 7
        g.defineSyntax("<", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            // short-circuiting
            var al:Dynamic = orbit.eval(a[0], e);
            var ar:Dynamic;
            
            for (i in 1...a.length)
            {
                ar = orbit.eval(a[i], e);
                if (al >= ar) return false;
                al = ar;
            }
            return true;
        });
        
        // (> 1 4 3 7) === 1 > 4 > 3 > 7
        g.defineSyntax(">", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            // short-circuiting
            var al:Dynamic = orbit.eval(a[0], e);
            var ar:Dynamic;
            
            for (i in 1...a.length)
            {
                ar = orbit.eval(a[i], e);
                if (al <= ar) return false;
                al = ar;
            }
            return true;
        });
        
        // (<= 1 4 3 7) === 1 <= 4 <= 3 <= 7
        g.defineSyntax("<=", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            // short-circuiting
            var al:Dynamic = orbit.eval(a[0], e);
            var ar:Dynamic;
            
            for (i in 1...a.length)
            {
                ar = orbit.eval(a[i], e);
                if (al > ar) return false;
                al = ar;
            }
            return true;
        });
        
        // (>= 1 4 3 7) === 1 >= 4 >= 3 >= 7
        g.defineSyntax(">=", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            // short-circuiting
            var al:Dynamic = orbit.eval(a[0], e);
            var ar:Dynamic;
            
            for (i in 1...a.length)
            {
                ar = orbit.eval(a[i], e);
                if (al < ar) return false;
                al = ar;
            }
            return true;
        });
    }
    
}