package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.libs.MathLib;
import moonaire.orbit.Orbit;

/**
 * ...
 * @author Munir Hussin
 */

class Objects 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // classes
        g.defineVariable("Void", Void);
        g.defineVariable("Int", Int);
        g.defineVariable("Float", Float);
        g.defineVariable("String", String);
        g.defineVariable("Bool", Bool);
        g.defineVariable("Class", Class);
        g.defineVariable("Dynamic", Dynamic);
        g.defineVariable("Array", Array);
        g.defineVariable("Table", Hash);
        g.defineVariable("List", List);
        //g.defineVariable("Math", Math);
        g.defineVariable("Math", MathLib);
        
        
        // (new x a b c) === new x(a, b, c)
        g.defineSyntax("new", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            var a0:Dynamic = a[0];
            var ax:Dynamic = orbit.eval(a0, e);
            var cl:Class<Dynamic>;
            
            // if it's a class, we're good. otherwise if it's an object, get the class
            // this allows you to instantiate an object based on an already instantiated object
            if (Std.is(ax, Class)) cl = ax;
            else cl = Type.getClass(ax);
            
            // if we managed to get the class, instantiate it
            if (cl != null)
            {
                // prepare args
                a.shift();
                
                // instantiate
                var obj:Dynamic = Type.createInstance(cl, a);
                return obj;
            }
            
            trace("Error: " + a0 + " is not a class.");
            return null;
        });
        
        
        // (typeof a)
        g.defineVariable("typeof", function (value:Dynamic):Dynamic
        {
            return Type.typeof(value);
        });
        
        // (array a b c d e)
        g.defineSyntax("array", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            return a;
        });
        
        // (list a b c d e)
        g.defineSyntax("list", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            return Lambda.list(a);
        });
        
        // (table (a b) (c d) (e f))
        g.defineSyntax("table", function (a:Array<Dynamic>, e:Environment):Dynamic
        {
            var hash:Hash<Dynamic> = new Hash<Dynamic>();
            var i:Int = 0;
            var n:Int = a.length;
            var pair:Array<Dynamic>;
            var key:Dynamic;
            var value:Dynamic;
            
            while (i < n)
            {
                pair = a[i];
                key = pair[0];
                value = orbit.eval(pair[1], e);
                
                hash.set(key, value);
                i++;
            }
            
            return hash;
        });
        
        
        /*
        g.defineVariable("push", function(array:Array<Dynamic>, item:Dynamic):Dynamic
        {
            return array.push(item);
        });
        
        g.defineVariable("pop", function(array:Array<Dynamic>, item:Dynamic):Dynamic
        {
            return array.pop();
        });
        
        g.defineVariable("unshift", function(array:Array<Dynamic>, item:Dynamic):Dynamic
        {
            return array.unshift(item);
        });
        
        g.defineVariable("shift", function(array:Array<Dynamic>, item:Dynamic):Dynamic
        {
            return array.shift();
        });
        */
    }
    
}