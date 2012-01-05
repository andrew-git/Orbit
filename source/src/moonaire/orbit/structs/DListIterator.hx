package moonaire.orbit.structs;

/**
 * ...
 * @author Munir Hussin
 */

class DListIterator<T>
{
    private var list:DList<T>;
    private var node:DListNode<T>;
    
    public function new(list:DList<T>)
    {
        this.list = list;
        node = list.head;
    }
    
    public function hasNext():Bool
    {
        return node != null;
    }
    
    /// returns the current value and move the pointer forward
    public function next():T
    {
        var data:T = node.data;
        node = node.next;
        return data;
    }
    
    /// returns the current value and move the pointer backward
    public function prev():T
    {
        var data:T = node.data;
        node = node.next;
        return data;
    }
    
    /// returns the current value without incrementing the pointer
    public function peek():T
    {
        return node != null ? node.data : null;
    }
    
    /// returns the previous value without incrementing the pointer
    public function peekNext():T
    {
        return node != null && node.next != null ? node.next.data : null;
    }
    
    /// returns the previous value without incrementing the pointer
    public function peekPrev():T
    {
        return node != null && node.prev != null ? node.prev.data : null;
    }
    
    /// removes the current element
    public function remove():T
    {
        return node != null ? list._remove(node) : null;
    }
    
    /// Inserts a new element before the current node
    public function insertBefore(v:T):Void
    {
        if (node == null) return;
        list._insertBefore(node, new DListNode<T>(v));
    }
    
    /// Inserts a new element after the current node
    public function insertAfter(v:T):Void
    {
        if (node == null) return;
        list._insertAfter(node, new DListNode<T>(v));
    }
    
    /// Finds the next matching element
    public function seekNext(v:T):Bool
    {
        while (node != null)
        {
            if (node.data == v) return true;
            node = node.next;
        }
        return false;
    }
    
    /// Finds the previous matching element
    public function seekPrev(v:T):Bool
    {
        while (node != null)
        {
            if (node.data == v) return true;
            node = node.prev;
        }
        return false;
    }
    
    /// Sets the pointer to the beginning of the list
    public function first():Void
    {
        node = list.head;
    }
    
    /// Sets the pointer to the end of the list
    public function last():Void
    {
        node = list.tail;
    }
    
    /// Is the pointer currently pointing to the beginning of the list?
    public function isFirst():Bool
    {
        return node == list.head;
    }
    
    /// Is the pointer currently pointing to the end of the list?
    public function isLast():Bool
    {
        return node == list.tail;
    }
    
    /// Moves the pointer to the specific index (slow)
    public function index(i:Int):Void
    {
        node = list.head;
        
        // optimization for specific cases
        if (i >= list.length) node = null;
        else if (i == list.length - 1) node = list.tail;
        
        while (node != null)
        {
            if (i <= 0) return;
            i--;
            node = node.next;
        }
    }
    
    /// Sets the value of the current node
    public function set(v:T):Void
    {
        if (node != null) node.data = v;
    }
    
}