package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.Orbit;

/**
 * ...
 * @author Munir Hussin
 */

class Arithmetic 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // (+ a b c d)
        g.defineSyntax("+", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var isStr:Bool = false;
            var i:Int = 0;
            var n:Int = a.length;
            var ret:Dynamic;
            
            while (i < n)
            {
                a[i] = orbit.eval(a[i], e);
                if (!isStr && Std.is(a[i], String)) isStr = true;
                i++;
            }
            
            if (isStr)
            {
                return a.join("");
            }
            else
            {
                if (a.length == 1) return a[0];
                ret = a[0] + a[1];
                for (i in 2...a.length) ret += a[i];
                return ret;
            }
        });
        
        // (- a b c d)
        g.defineSyntax("-", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            if (a.length == 1) return -a[0];
            var ret:Dynamic = a[0] - a[1];
            for (i in 2...a.length) ret -= a[i];
            return ret;
        });
        
        // (* a b c d)
        g.defineSyntax("*", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] * a[1];
            for (i in 2...a.length) ret *= a[i];
            return ret;
        });
        
        // (/ a b c d)
        g.defineSyntax("/", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] / a[1];
            for (i in 2...a.length) ret /= a[i];
            return ret;
        });
        
        // (% a b c d)
        g.defineSyntax("%", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            var ret:Dynamic = a[0] % a[1];
            for (i in 2...a.length) ret %= a[i];
            return ret;
        });
        
        // (++ a)  ===>   (= a (+ a 1))
        g.defineSyntax("++", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var x:Dynamic = orbit.eval(a[0], e);
            orbit.eval(["=", a[0], ++x], e);
            return x;
        });
        
        // (-- a)  ===>   (= a (+ a 1))
        g.defineSyntax("--", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var x:Dynamic = orbit.eval(a[0], e);
            orbit.eval(["=", a[0], --x], e);
            return x;
        });
        
        
        // we can procedurally generate the compound assignment operators
        var ops:Array<String> = ["+", "-", "*", "/", "%", "&", "|", "^", "<<", ">>", ">>>"];
        
        for (op in ops)
        {
            // (+= a b)  ===>   (= a (+ a b))
            g.defineSyntax(op + "=", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
            {
                // get the first arg
                var a0:Dynamic = a[0];
                
                // add the op to the inner array
                a.unshift(op);
                
                // add the assignment code
                var code:Array<Dynamic> = new Array<Dynamic>();
                code.push("=");
                code.push(a0);
                code.push(a);
                
                // execute the generated code
                return orbit.eval(code, e);
            });
        }
        
    }
    
}