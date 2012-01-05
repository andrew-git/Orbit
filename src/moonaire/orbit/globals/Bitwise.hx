package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.Orbit;

/**
 * ...
 * @author Munir Hussin
 */

class Bitwise 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // (~ a)
        g.defineSyntax("~", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            return ~orbit.eval(a[0], e);
        });
        
        // (& a b c d)
        g.defineSyntax("&", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] & a[1];
            for (i in 2...a.length) ret &= a[i];
            return ret;
        });
        
        // (| a b c d)
        g.defineSyntax("|", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] | a[1];
            for (i in 2...a.length) ret |= a[i];
            return ret;
        });
        
        // (^ a b c d)
        g.defineSyntax("^", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] ^ a[1];
            for (i in 2...a.length) ret ^= a[i];
            return ret;
        });
        
        // (<< a b c d)
        g.defineSyntax("<<", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] << a[1];
            for (i in 2...a.length) ret <<= a[i];
            return ret;
        });
        
        // (>> a b c d)
        g.defineSyntax(">>", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] >> a[1];
            for (i in 2...a.length) ret >>= a[i];
            return ret;
        });
        
        // (>>> a b c d)
        g.defineSyntax(">>>", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] >>> a[1];
            for (i in 2...a.length) ret >>>= a[i];
            return ret;
        });
    }
    
}