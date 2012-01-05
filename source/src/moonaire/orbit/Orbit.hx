package moonaire.orbit;

import moonaire.orbit.libs.MathLib;

using StringTools;

/**
 * Orbit is a language I created which is heavily inspired by Lisp,
 * with influences from Lua and Javascript as well. It's currently
 * designed to be used as a flexible structured data/markup format
 * for my projects, though it can also be used for scripting as well.
 * 
 * As opposed to XML or JSON, Lisp is much more expressive. However,
 * it isn't popular, probably due to its huge list of keywords and
 * the code may sometimes contain many special characters which makes
 * it hard to read, especially for beginners.
 * 
 * Orbit is my way of simplifying Lisp, adding the familiarity of
 * popular modern languages, while trying to retain some of the
 * expressiveness of Lisp.
 * 
 * Orbit has the structure of Lisp, the modular system of Lua, the
 * keywords of Javascript, and the dot/index (obj.prop, arr[i])
 * infix operators found in many modern languages.
 * 
 * -----
 * TODO: I currently implemented this using arrays. That's before
 * I wrote the DList data structure. So at some point, I'll be
 * changing the Array instances to DList instances. Or maybe not.
 * 
 * @author Munir Hussin
 */

class Orbit 
{
    public static var classpath:String = "orb/";
    private static inline var CHAR_DOUBLE_QUOTE:Int = '"'.fastCodeAt(0);
    private static inline var CHAR_LCASE_M:Int = "m".fastCodeAt(0);
    private static inline var CHAR_LCASE_G:Int = "g".fastCodeAt(0);
    
    //private var parser:Parser;
    public var global:Environment;
    public var modules:Hash<Dynamic>;
    
    public function new() 
    {
        modules = new Hash<Dynamic>();
        Environment.createGlobal(this);
        Parser.init(this);
        
        bind(MathLib, "Math");
    }
    
    
    public function read(code:String, ?env:Environment):Dynamic
    {
        env = (env == null) ? global : env;
        
        var parser:Parser = Parser.read(code);
        
        // execute the code
        var code:Dynamic = parser.parse();
        var out:Dynamic = eval(code, env);
        //print(out);
        
        return out;
    }
    
    public function print(?v:Dynamic):Void
    {
        if (v == null) v = "";
        
        #if cpp
            cpp.Lib.println(v);
        #elseif flash
            flash.Lib.trace(v);
        #else
            trace(v);
        #end
    }
    
    public function bind(c:Class<Dynamic>, as:String):Void
    {
        // bind a class to the script
        // the script will be able to have access to the class
        // and able to instantiate objects with it
        modules.set(as, c);
    }
    
    
    public function require(module:String):Dynamic
    {
        // it's dynamic because a module can be a class or a hashmap
        
        if (modules.exists(module))
        {
            // if the module has already loaded, then directly return it
            return modules.get(module);
        }
        else
        {
            var parser:Parser = Parser.load(classpath + module + ".orb");
            
            if (parser != null)
            {
                var env1:Environment = new Environment(this, global);
                var env2:Environment = new Environment(this, env1);
                env2.name = module;
                env1.symbols.set("module", env2.symbols);
                
                modules.set(module, env2.symbols);
                
                // execute the code
                var code:Dynamic = parser.parse();
                var out:Dynamic = eval(code, env2);
                //print(out);
                
                return env2.symbols;
            }
            else
            {
                print("Error: Can't load module " + module);
                return null;
            }
        }
    }
    
    public function unrequire(module:String):Bool
    {
        return modules.remove(module);
    }
    
    public function document(doc:String):Dynamic
    {
        var parser:Parser = Parser.load(classpath + doc + ".orb");
        
        if (parser != null)
        {
            // parse and return the document
            var code:Array<Dynamic> = new Array<Dynamic>();
            code.push("quote");
            code.push(parser.parse());
            return code;
        }
        else
        {
            print("Error: Can't load document " + doc);
            return null;
        }
    }
    
    public function lambda(a:Array<Dynamic>, e:Environment, ?shouldEvalArgs:Bool = false):Dynamic
    {
        var a0:Dynamic = a[0];
        
        var args:Array<Dynamic>;                            // (a b c)
        var expr:Dynamic;                                   // (+ a b)
        var name:String = null;
        var f:Dynamic;
        var fn:Function;
        
        if (Std.is(a0, String))
        {
            name = a[0];
            args = a[1];
            expr = a[2];
        }
        else
        {
            args = a[0];
            expr = a[1];
        }
        
        f = function(a0:Array<Dynamic>, e0:Environment, obj:Dynamic):Dynamic
        {
            // evaluate each arg based on the callee's environment
            if (shouldEvalArgs) evalEach(a0, e0);
            
            // add magic variables which can be accessed within the function
            var env:Environment = new Environment(this, e, args, a0);
            env.name = "@function";
            env.type = Environment.TYPE_FUNCTION;
            env.defineVariable("arguments", a0);
            env.defineVariable("environment", e0);
            env.defineVariable("this", obj);
            
            // evaluate the expression based on the original environment
            return eval(expr, env);
        };
        
        fn = new Function(f);
        
        if (name != null)
        {
            var def:Array<Dynamic> = new Array<Dynamic>();
            def.push("var");
            def.push(name);
            def.push(fn);
            return eval(def, e);
        }
        else
        {
            return fn;
        }
    }
    
    public function call(obj:Dynamic, f:Dynamic, args:Array<Dynamic>, env:Environment):Dynamic
    {
        // execute a custom function
        // (f a b c)
        // f is a variable/literal which must evaluate into a function
        // ((function (a b) (+ a b 2)) 5 6)     ==>  defining an anonymous function, and call it by passing in 5 and 6
        
        
        // always evaluate f, and it should return a function
        // if f is already a literal function, it is expected to return
        // another function as well
        var a0:Dynamic = f;
        
        //if (!(Std.is(f, Function) || Reflect.isFunction(f)))
        //{
            f = eval(f, env);
        //}
        
        // check if fn is a function first
        if (Std.is(f, Function))                        // script function
        {
            // call the function
            var fn:Function = f;
            return fn.call(obj, args, env);
        }
        else if (Reflect.isFunction(f))                 // external function
        {
            // prepare argument list
            evalEach(args, env);
            
            // call it
            return Reflect.callMethod(obj, f, args);
        }
        else
        {
            print("Error: " + a0 + " is not a function.");
            return null;
        }
    }
    
    public function eval(x:Dynamic, env:Environment):Dynamic
    {
        if (Std.is(x, String))                                  // x
        {
            var s:String = x;
            
            if (s.fastCodeAt(0) == CHAR_DOUBLE_QUOTE)
            {
                // it's a string
                return s.substr(1, -2);
            }
            else
            {
                // it's a symbol
                return env.get(x);
            }
        }
        else if (Std.is(x, Array))                              // (x y z)
        {
            var a:Array<Dynamic> = x;
            var f:Dynamic = a[0];
            
            if (f == "quote")                                   // (quote expr)
            {
                // returns the expression without evaluating it
                return a[1];
            }
            else if (f == "index")                              // (index obj a b c)
            {
                return evalIndexGet(a, env);
            }
            else if (f == "if")                                 // (if cond t f)
            {
                var cond:Dynamic = eval(a[1], env);
                
                if (cond) return eval(a[2], env);
                else return (a.length > 3) ? eval(a[3], env) : null;
            }
            else if (f == "set" || f == "=")                    // (set sym expr)
            {
                // check sym
                // if it's a string, then don't evaluate it     ==> (set foo 3)                                 ==> foo = 3
                // if it's an array,                            ==> (set (index foo (index bar a) faz) 3)       ==> foo[bar[a]][faz] = 3
                // then we're dealing with properties           ==> (set (index foo 'bar faz)                   ==> foo.bar[faz]
                
                var target:Dynamic = a[1];
                var expr:Dynamic = eval(a[2], env);
                
                if (Std.is(target, String))
                {
                    env.set(target, expr);
                }
                else if (Std.is(target, Array))
                {
                    var arr:Array<Dynamic> = target;
                    
                    if (arr[0] == "index")
                    {
                        return evalIndexSet(arr, env, expr);
                    }
                }
                
                return expr;
            }
            else if (f == "delete")                             // (delete sym)
            {
                var target:Dynamic = a[1];
                
                if (Std.is(target, String))
                {
                    // deleting a variable from the environment
                    env = env.find(target);
                    if (env != null) return env.symbols.remove(target);
                }
                else if (Std.is(target, Array))
                {
                    var arr:Array<Dynamic> = target;
                    
                    if (arr[0] == "index")
                    {
                        return evalIndexDelete(arr, env);
                    }
                }
                
                return false;
            }
            else if (f == "var")                                // (var sym expr)
            {
                // if already declared, and called without expression,
                // it doesnt change the value
                var sym:Dynamic = a[1];
                
                if (a.length == 2)
                {
                    // called without expression, so just declare
                    return env.declare(sym);
                }
                else
                {
                    // called with expression, so set the value
                    var expr:Dynamic = eval(a[2], env);
                    env.symbols.set(sym, expr);
                    return expr;
                }
            }
            else if (f == "module" || f == "global")            // (module sym expr) (global sym expr)
            {
                // declaring module-level or global-level variable
                var sym:Dynamic = a[1];
                
                var hash:Hash<Dynamic> = env.get(f);
                var expr:Dynamic = a.length > 2 ? eval(a[2], env) : hash.get(sym);
                
                hash.set(sym, expr);
                return expr;
            }
            else if (f == "begin")                              // (begin expr*)
            {
                var ret:Dynamic = null;
                var i:Int = 1;
                var n:Int = a.length;
                
                // create a new begin environment
                env = new Environment(this, env);
                env.name = "@begin";
                env.type = Environment.TYPE_BEGIN;
                
                while (i < n)
                {
                    ret = eval(a[i], env);
                    if (env.hasReturned) break;
                    i++;
                }
                
                return ret;
            }
            else if (f == "let")                                // (let ((sym init)*) expr)
            {
                var args:Array<Array<Dynamic>> = a[1];
                var expr:Dynamic = a[2];
                
                var keys:Array<Dynamic> = new Array();
                var values:Array<Dynamic> = new Array();
                
                var arg:Array<Dynamic>;
                var i:Int = 0;
                var n:Int = args.length;
                
                while (i < n)
                {
                    arg = args[i];
                    keys.push(arg[0]);
                    values.push(arg[1]);
                    i++;
                }
                
                return eval(expr, new Environment(this, env, keys, values, "@let"));
            }
            else if (f == "call")                               // (call f args)
            {
                var fn:Dynamic = a[1];
                var args:Array<Dynamic> = eval(a[2], env);
                
                if (Std.is(fn, Array))
                {
                    var arr:Array<Dynamic> = fn;
                    
                    if (arr[0] == "index")
                    {
                        return evalIndexCall(arr, env, args);
                    }
                }
                
                return call(null, fn, args, env);
            }
            else
            {
                // it's a custom function
                var args:Array<Dynamic> = arrayCopy(a, 1);
                
                if (Std.is(f, Array))
                {
                    var arr:Array<Dynamic> = f;
                    
                    if (arr[0] == "index")
                    {
                        return evalIndexCall(arr, env, args);
                    }
                }
                
                return call(null, f, args, env);
            }
        }
        else
        {
            return x;
        }
    }
    
    private function arrayCopy(a:Array<Dynamic>, ?start:Int = 0):Array<Dynamic>
    {
        var arr:Array<Dynamic> = new Array<Dynamic>();
        var i:Int = start;
        var n:Int = a.length;
        
        while (i < n)
        {
            arr.push(a[i]);
            i++;
        }
        
        return arr;
    }
    
    public function evalEach(expr:Array<Dynamic>, env:Environment):Void
    {
        var i:Int = 0;
        var n:Int = expr.length;
        
        while (i < n)
        {
            expr[i] = eval(expr[i], env);
            i++;
        }
    }
    
    private function evalIndex(a:Array<Dynamic>, env:Environment):Array<Dynamic>
    {
        //  0     1   2
        // (index obj a b c)    ===> obj[a][b][c]
        // (index obj 'a 'b 'c) ===> obj.a.b.c
        // this function loops until the innermost object/property pair
        
        // a.b.c.d.e ===> returns [eval(d), e]
        
        // eval(a), b
        // eval(b), c
        
        // type         check                               get fields
        // instance     Type.getClass(obj) != null          Type.getInstanceFields(Type.getClass(obj))
        // class        Std.is(obj, Class)                  Type.getClassFields(obj)
        // structure    Reflect.isObject(iter)              Reflect.fields(iter)
        
        var i:Int = 2;
        var n:Int = a.length - 1;
        
        var obj:Dynamic = eval(a[1], env);
        var prop:Dynamic = null;
        
        
        // navigate to the right property
        while (i < n)
        {
            // evaluate the current object's property
            prop = eval(a[i], env);
            
            if (Std.is(obj, Array) && Std.is(prop, Int))
            {
                var arr:Array<Dynamic> = obj;
                obj = arr[prop];
            }
            else if (Std.is(obj, Hash))
            {
                var hash:Hash<Dynamic> = obj;
                obj = hash.get(prop);
            }
            /*else if (Std.is(obj, Environment))
            {
                var e:Environment = obj;
                obj = e.symbols.get(prop);
            }*/
            else if (Reflect.isObject(obj))
            {
                obj = Reflect.field(obj, prop);
            }
            else
            {
                print("Error: index " + a[i] + " is an invalid type.");
                return null;
            }
            
            i++;
        }
        
        // this function returns an object-property pair
        var array:Array<Dynamic> = new Array<Dynamic>();
        array.push(obj);
        array.push(eval(a[i], env));        // evaluate the next property
        
        return array;
    }
    
    private function evalIndexGet(a:Array<Dynamic>, env:Environment):Dynamic
    {
        var pair:Array<Dynamic> = evalIndex(a, env);
        var obj:Dynamic = pair[0];
        var prop:Dynamic = pair[1];
        
        if (Std.is(obj, Array) && Std.is(prop, Int))
        {
            var arr:Array<Dynamic> = obj;
            return arr[prop];
        }
        else if (Std.is(obj, Hash))
        {
            var hash:Hash<Dynamic> = obj;
            return hash.get(prop);
        }
        /*else if (Std.is(obj, Environment))
        {
            var e:Environment = obj;
            return e.symbols.get(prop);
        }*/
        else if (Reflect.isObject(obj))
        {
            return Reflect.field(obj, prop);
        }
        else
        {
            print("Error: index " + a + " is an invalid type.");
            return null;
        }
    }
    
    private function evalIndexSet(a:Array<Dynamic>, env:Environment, val:Dynamic):Dynamic
    {
        var pair:Array<Dynamic> = evalIndex(a, env);
        var obj:Dynamic = pair[0];
        var prop:Dynamic = pair[1];
        
        if (Std.is(obj, Array) && Std.is(prop, Int))
        {
            var arr:Array<Dynamic> = obj;
            arr[prop] = val;
        }
        else if (Std.is(obj, Hash))
        {
            var hash:Hash<Dynamic> = obj;
            hash.set(prop, val);
        }
        /*else if (Std.is(obj, Environment))
        {
            var e:Environment = obj;
            e.symbols.set(prop, val);
        }*/
        else if (Reflect.isObject(obj))
        {
            Reflect.setField(obj, prop, val);
        }
        else
        {
            print("Error: index " + a + " is an invalid type.");
        }
        
        return val;
    }
    
    private function evalIndexDelete(a:Array<Dynamic>, env:Environment):Dynamic
    {
        var pair:Array<Dynamic> = evalIndex(a, env);
        var obj:Dynamic = pair[0];
        var prop:Dynamic = pair[1];
        
        //var i:Int = a.length - 1;
        //var obj:Dynamic = evalIndex(a, i, env);
        //var prop:Dynamic = eval(a[i], env);
        
        if (Std.is(obj, Array) && Std.is(prop, Int))
        {
            var arr:Array<Dynamic> = obj;
            return arr.splice(prop, 1) != null;
        }
        else if (Std.is(obj, Hash))
        {
            var hash:Hash<Dynamic> = obj;
            return hash.remove(prop);
        }
        /*else if (Std.is(obj, Environment))
        {
            var e:Environment = obj;
            return e.symbols.remove(prop);
        }*/
        else if (Reflect.isObject(obj))
        {
            return Reflect.deleteField(obj, prop);
        }
        else
        {
            print("Error: index " + a + " is an invalid type.");
        }
        
        return false;
    }
    
    private function evalIndexCall(a:Array<Dynamic>, env:Environment, args:Array<Dynamic>):Dynamic
    {
        var pair:Array<Dynamic> = evalIndex(a, env);
        var obj:Dynamic = pair[0];
        var prop:Dynamic = pair[1];
        var fn:Dynamic;
        
        if (Std.is(obj, Array) && Std.is(prop, Int))
        {
            var arr:Array<Dynamic> = obj;
            fn = arr[prop];
        }
        else if (Std.is(obj, Hash))
        {
            var hash:Hash<Dynamic> = obj;
            fn = hash.get(prop);
        }
        /*else if (Std.is(obj, Environment))
        {
            var e:Environment = obj;
            fn = e.symbols.get(prop);
        }*/
        else if (Reflect.isObject(obj))
        {
            fn = Reflect.field(obj, prop);
        }
        else
        {
            print("Error: index " + a + " is an invalid type.");
            return null;
        }
        
        return call(obj, fn, args, env);
    }
    
}