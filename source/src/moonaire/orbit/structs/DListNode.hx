package moonaire.orbit.structs;

/**
 * ...
 * @author Munir Hussin
 */

class DListNode<T>
{
    public var prev:DListNode<T>;
    public var next:DListNode<T>;
    public var data:T;
    
    public function new(d:T) 
    {
        data = d;
    }
    
    public function toString():String
    {
        return Std.string(data);
    }
    
}