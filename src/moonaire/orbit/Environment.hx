package moonaire.orbit;

import moonaire.orbit.globals.Arithmetic;
import moonaire.orbit.globals.Bitwise;
import moonaire.orbit.globals.Comparison;
import moonaire.orbit.globals.Core;
import moonaire.orbit.globals.Flow;
import moonaire.orbit.globals.Logical;
import moonaire.orbit.globals.Objects;

/**
 * ...
 * @author Munir Hussin
 */

class Environment 
{
    public static inline var TYPE_DEFAULT:Int = 0;
    public static inline var TYPE_BEGIN:Int = 1;
    public static inline var TYPE_LOOP:Int = 2;
    public static inline var TYPE_FUNCTION:Int = 3;
    
    public var name:String;
    
    public var orbit:Orbit;
    public var parent:Environment;
    public var symbols:Hash<Dynamic>;
    
    public var type:Int;
    public var hasReturned:Bool;
    
    public function new(orbit:Orbit, ?parent:Environment, ?keys:Array<Dynamic>, ?values:Array<Dynamic>, ?name:String) 
    {
        this.orbit = orbit;
        this.parent = parent;
        this.symbols = new Hash<Dynamic>();
        this.name = name;
        
        type = TYPE_DEFAULT;
        hasReturned = false;
        
        if (keys != null && values != null)
        {
            var k:String;
            var v:Dynamic;
            var vn:Int = values.length;
            
            for (i in 0...keys.length)
            {
                k = keys[i];
                v = (i < vn) ? values[i] : null;
                symbols.set(k, v);
            }
        }
    }
    
    public static function createGlobal(orbit:Orbit):Environment
    {
        var g:Environment = new Environment(orbit);
        g.name = "Global";
        orbit.global = g;
        
        Core.init(orbit, g);
        Arithmetic.init(orbit, g);
        Comparison.init(orbit, g);
        Logical.init(orbit, g);
        Bitwise.init(orbit, g);
        Flow.init(orbit, g);
        Objects.init(orbit, g);
        
        return g;
    }
    
    
    public function find(key:String):Environment
    {
        if (symbols.exists(key))
        {
            return this;
        }
        else if (parent != null)
        {
            return parent.find(key);
        }
        else
        {
            // error: can't find symbol
            return null;
        }
    }
    
    
    public function get(key:String):Dynamic
    {
        var env:Environment = find(key);
        
        if (env != null)
        {
            return env.symbols.get(key);
        }
        else
        {
            // error: can't find symbol
            return null;
        }
    }
    
    public function set(key:String, value:Dynamic):Void
    {
        var env:Environment = find(key);
        
        if (env != null)
        {
            env.symbols.set(key, value);
        }
        else
        {
            // can't find symbol, so create one in this environment
            symbols.set(key, value);
        }
    }
    
    public function setIfNotExist(key:String, value:Dynamic):Void
    {
        var env:Environment = find(key);
        
        if (env == null)
        {
            // can't find symbol, so create one in this environment
            symbols.set(key, value);
        }
    }
    
    public function put(key:String, value:Dynamic):Void
    {
        symbols.set(key, value);
    }
    
    public function declare(key:String):Dynamic
    {
        if (!symbols.exists(key))
        {
            // not yet declared, so we add it
            symbols.set(key, null);
            return null;
        }
        else
        {
            // already declared, so we return its value
            return symbols.get(key);
        }
    }
    
    public function defineVariable(key:String, value:Dynamic):Void
    {
        symbols.set(key, value);
    }
    
    public function defineSyntax(key:String, value:Array<Dynamic>->Environment->Dynamic->Dynamic):Void
    {
        var f:Function = new Function(value);
        symbols.set(key, f);
    }
    
    public function defineAlias(key:String, existingKey:String):Void
    {
        symbols.set(key, symbols.get(existingKey));
    }
    
    public function eval(x:Dynamic):Dynamic
    {
        return orbit.eval(x, this);
    }
    
    public function evalEach(expr:Array<Dynamic>):Dynamic
    {
        return orbit.evalEach(expr, this);
    }
    
    public function trace():Void
    {
        orbit.print("  " + name);
        if (parent != null) parent.trace();
    }
    
    
}