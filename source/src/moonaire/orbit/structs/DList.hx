package moonaire.orbit.structs;

/**
 * ...
 * @author Munir Hussin
 */

class DList<T>
{
    public var head:DListNode<T>;
    public var tail:DListNode<T>;
    public var length(getLength, null):Int;
    private var size:Int;
    
    
    public function new() 
    {
        head = null;
        tail = null;
        size = 0;
    }
    
    private function getLength():Int
    {
        return size;
    }
    
    /// Returns the first item on the list
    public function first():T
    {
        if (head == null) return null;
        return head.data;
    }
    
    /// Returns the last item on the list
    public function last():T
    {
        if (tail == null) return null;
        return tail.data;
    }
    
    
    public function _insertAfter(node:DListNode<T>, newNode:DListNode<T>):Void
    {
        newNode.prev = node;
        newNode.next = node.next;
        if (node.next == null) tail = newNode;
        else node.next.prev = newNode;
        node.next = newNode;
        size++;
    }
    
    public function _insertBefore(node:DListNode<T>, newNode:DListNode<T>):Void
    {
        newNode.prev = node.prev;
        newNode.next = node;
        if (node.prev == null) head = newNode;
        else node.prev.next = newNode;
        node.prev = newNode;
        size++;
    }
    
    public function _insertFront(newNode:DListNode<T>):Void
    {
        if (head == null)
        {
            head = newNode;
            tail = newNode;
            newNode.prev = null;
            newNode.next = null;
            size++;
        }
        else
        {
            _insertBefore(head, newNode);
        }
    }
    
    public function _insertBack(newNode:DListNode<T>):Void
    {
        if (tail == null) _insertFront(newNode);
        else _insertAfter(tail, newNode);
    }
    
    public function _remove(node:DListNode<T>):T
    {
        if (node.prev == null) head = node.next;
        else node.prev.next = node.next;
        
        if (node.next == null) tail = node.prev;
        else node.next.prev = node.prev;
        
        size--;
        return node.data;
    }
    
    /// Retrieve the element by the given position (slow)
    public function index(i:Int):T
    {
        var n:DListNode<T> = head;
        
        // optimization for specific cases
        if (i >= size) return null;
        else if (i == size - 1) return tail != null ? tail.data : null;
        
        while (n != null)
        {
            if (i <= 0) return n.data;
            i--;
            n = n.next;
        }
        
        return null;
    }
    
    /// Removes the first matching element in the list
    public function remove(v:T):Bool
    {
        var it:DListIterator<T> = new DListIterator<T>(this);
        it.seekNext(v);
        return it.remove() != null;
    }
    
    /// Adds an item to the end of the list
    public function push(v:T):Void
    {
        _insertBack(new DListNode<T>(v));
    }
    
    /// Removes an item from the end of the list
    public function pop():T
    {
        return _remove(tail);
    }
    
    /// Adds an item to the beginning of the list
    public function unshift(v:T):Void
    {
        _insertFront(new DListNode<T>(v));
    }
    
    /// Removes an item from the beginning of the list
    public function shift():T
    {
        return _remove(head);
    }
    
    
    public function iterator():DListIterator<T>
    {
        return new DListIterator<T>(this);
    }
    
    public function find(v:T):DListIterator<T>
    {
        var it:DListIterator<T> = new DListIterator<T>(this);
        it.seekNext(v);
        return it;
    }
    
    
    public function toString():String
    {
        var n:DListNode<T> = head;
        var s:String = "{";
        
        while (n != null)
        {
            s += n.data;
            if (n.next != null) s += ", ";
            n = n.next;
        }
        
        s += "}";
        return s;
    }
    
}