package moonaire.orbit;

/**
 * ...
 * @author Munir Hussin
 */

class Function 
{
    public var f:Array<Dynamic>->Environment->Dynamic->Dynamic;
    
    public function new(fn:Array<Dynamic>->Environment->Dynamic->Dynamic)
    {
        f = fn;
    }
    
    public function call(o:Dynamic, a:Array<Dynamic>, e:Environment):Dynamic
    {
        if (Reflect.isFunction(f))
        {
            return Reflect.callMethod(o, f, [a, e, o]);
        }
        else
        {
            return null;
        }
    }
    
    public static function define(f:Dynamic):Void
    {
        
    }
    
    public static function apply(o:Dynamic, f:Dynamic, a:Array<Dynamic>, e:Environment):Dynamic
    {
        // if it's a function, call the function
        if (Std.is(f, Function))
        {
            var fn:Function = f;
            return fn.call(o, a, e);
        }
        // if it's a haxe function, call the haxe function
        else if (Reflect.isFunction(f))
        {
           return Reflect.callMethod(o, f, a);
        }
        
        return null;
    }
    
}