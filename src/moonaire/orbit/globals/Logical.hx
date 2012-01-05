package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.Orbit;

/**
 * ...
 * @author Munir Hussin
 */

class Logical 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // (? a)
        g.defineVariable("?", function (value:Dynamic):Dynamic
        {
            return value ? true : false;
        });
        
        // (! a)
        g.defineVariable("!", function (value:Dynamic):Dynamic
        {
            return !value;
        });
        
        // (&& a b c true false 0)
        g.defineSyntax("&&", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            var i:Int = 0;
            var n:Int = a.length;
            var v:Dynamic;
            
            while (i < n)
            {
                v = a[i];
                // short-circuiting
                if (!orbit.eval(v, e)) return false;
                i++;
            }
            
            return true;
        });
        
        // (|| a b c true false 0)
        g.defineSyntax("||", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            var i:Int = 0;
            var n:Int = a.length;
            var v:Dynamic;
            
            while (i < n)
            {
                v = a[i];
                // short-circuiting
                if (orbit.eval(v, e)) return true;
                i++;
            }
            
            return false;
        });
    }
    
}