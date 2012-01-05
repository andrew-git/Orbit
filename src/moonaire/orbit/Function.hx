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
    
}