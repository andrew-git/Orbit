package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.Orbit;

#if nme
    import nme.system.System;
#elseif cpp
    import cpp.Sys;
#end

/**
 * ...
 * @author Munir Hussin
 */

class Flow 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // (continue) or (continue arg)
        g.defineSyntax("continue", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var ret:Dynamic = (a.length > 0) ? orbit.eval(a[0], e) : null;
            
            // return from the current environment, up until a loop environment is found
            while (true)
            {
                e.hasReturned = true;
                
                // breaks out of current execution list, and does not propagate beyond a function
                if (e.type == Environment.TYPE_LOOP || e.type == Environment.TYPE_FUNCTION)
                {
                    e.hasReturned = false;
                    return ret;
                }
                else if (e.parent != null) e = e.parent;
                else return ret;
            }
            
            return ret;
        });
        
        // (break) or (break arg)
        g.defineSyntax("break", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var ret:Dynamic = (a.length > 0) ? orbit.eval(a[0], e) : null;
            
            // return from the current environment, up until a loop environment is found
            while (true)
            {
                e.hasReturned = true;
                
                // breaks out of the nearest loop, and does not propagate beyond a function
                if (e.type == Environment.TYPE_LOOP) return ret;
                else if (e.type == Environment.TYPE_FUNCTION)
                {
                    e.hasReturned = false;
                    return ret;
                }
                else if (e.parent != null) e = e.parent;
                else return ret;
            }
            
            return ret;
        });
        
        // (return) or (return arg)
        g.defineSyntax("return", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var ret:Dynamic = (a.length > 0) ? orbit.eval(a[0], e) : null;
            
            while (true)
            {
                e.hasReturned = true;
                
                // breaks out of the nearest function
                if (e.type == Environment.TYPE_FUNCTION) return ret;
                else if (e.parent != null) e = e.parent;
                else return ret;
            }
            
            return ret;
        });
        
        // (end) or (end arg)
        g.defineSyntax("end", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var ret:Dynamic = (a.length > 0) ? orbit.eval(a[0], e) : null;
            
            while (true)
            {
                e.hasReturned = true;
                
                // breaks out of the nearest begin, and does not propagate beyond a function
                if (e.type == Environment.TYPE_BEGIN) return ret;
                else if (e.type == Environment.TYPE_FUNCTION)
                {
                    e.hasReturned = false;
                    return ret;
                }
                else if (e.parent != null) e = e.parent;
                else return ret;
            }
            
            return ret;
        });
        
        // (exit) or (exit arg)
        g.defineSyntax("exit", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var ret:Dynamic = (a.length > 0) ? orbit.eval(a[0], e) : 0;
            
            while (true)
            {
                e.hasReturned = true;
                
                // breaks out of everything
                if (e.parent != null) e = e.parent;
                else
                {
                    #if nme
                        System.exit(cast(ret, Int));
                    #elseif cpp
                        Sys.exit(cast(ret, Int));
                    #end
                    
                    return null;
                }
            }
            
            return ret;
        });
        
        // (for (init cond next) expr)
        g.defineSyntax("for", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var args:Array<Dynamic> = a[0];
            var expr:Array<Dynamic> = a[1];
            
            var init:Dynamic = args[0];
            var cond:Dynamic = args[1];
            var next:Dynamic = args[2];
            var ret:Dynamic = null;
            
            // create a new loop environment
            var env:Environment = new Environment(orbit, e);
            env.name = "@for";
            env.type = Environment.TYPE_LOOP;
            
            // note that init is executed in current environment, not loop environment
            orbit.eval(init, e);
            
            while (orbit.eval(cond, env))
            {
                ret = orbit.eval(expr, env);
                if (env.hasReturned) break;
                orbit.eval(next, env);
            }
            
            return ret;
        });
        
        // (foreach (obj iter) expr)    or      (foreach (key value iter) expr)
        g.defineSyntax("foreach", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var args:Array<Dynamic> = a[0];
            var expr:Array<Dynamic> = a[1];
            var key:Dynamic;
            var value:Dynamic;
            var iter:Dynamic;
            var ret:Dynamic = null;
            
            if (args.length == 2)
            {
                key = null;
                value = args[0];
                iter = args[1];
            }
            else if (args.length == 3)
            {
                key = args[0];
                value = args[1];
                iter = args[2];
            }
            else
            {
                trace("Error: Invalid foreach syntax");
                return null;
            }
            
            
            // create a new loop environment
            var env:Environment = new Environment(orbit, e);
            env.name = "@foreach";
            env.type = Environment.TYPE_LOOP;
            
            
            // get the iterator
            iter = orbit.eval(iter, e);
            
            // how it loops depends on the type
            if (Std.is(iter, Array))
            {
                var array:Array<Dynamic> = iter;
                
                if (args.length == 2)
                {
                    for (v in array)
                    {
                        env.set(value, v);                  // update the variable so it can be accessed in script
                        ret = orbit.eval(expr, env);        // evaluate the expression
                        if (env.hasReturned) break;
                    }
                }
                else
                {
                    var i:Int = 0;
                    var n:Int = array.length;
                    
                    while (i < n)
                    {
                        env.set(key, i);                    // update the variable so it can be accessed in script
                        env.set(value, array[i]);           // update the variable so it can be accessed in script
                        ret = orbit.eval(expr, env);        // evaluate the expression
                        if (env.hasReturned) break;
                        i++;
                    }
                }
            }
            else if (Std.is(iter, Hash))
            {
                var hash:Hash<Dynamic> = iter;
                
                if (args.length == 2)
                {
                    for (v in hash)
                    {
                        env.set(value, v);                  // update the variable so it can be accessed in script
                        ret = orbit.eval(expr, env);        // evaluate the expression
                        if (env.hasReturned) break;
                    }
                }
                else
                {
                    for (k in hash.keys())
                    {
                        env.set(key, k);                    // update the variable so it can be accessed in script
                        env.set(value, hash.get(k));        // update the variable so it can be accessed in script
                        ret = orbit.eval(expr, env);        // evaluate the expression
                        if (env.hasReturned) break;
                    }
                }
            }
            else if (Reflect.field(iter, "iterator") != null)       // it's an iterable
            {
                if (args.length == 2)
                {
                    var it:Iterable<Dynamic> = iter;
                    
                    for (v in it)
                    {
                        env.set(value, v);                  // update the variable so it can be accessed in script
                        ret = orbit.eval(expr, env);        // evaluate the expression
                        if (env.hasReturned) break;
                    }
                }
                else
                {
                    // we can't do a key-value iteration in this case
                    trace("Error: key-value iteration not possible for this data type.");
                    return null;
                }
            }
            else if (Reflect.isObject(iter))
            {
                var keys:Array<String>;
                var cl:Class<Dynamic> = Type.getClass(iter);
                
                if (cl != null)                                 // is it an instance of a class?
                {
                    keys = Type.getInstanceFields(cl);
                }
                else if (Std.is(iter, Class))                   // is it a class?
                {
                    keys = Type.getClassFields(iter);
                }
                else                                            // it's an anonymous object
                {
                    keys = Reflect.fields(iter);
                }
                
                var i:Int = 0;
                var n:Int = keys.length;
                var k:String;
                
                while (i < n)
                {
                    k = keys[i];
                    env.set(key, k);
                    env.set(value, Reflect.field(iter, k));
                    ret = orbit.eval(expr, env);
                    if (env.hasReturned) break;
                    i++;
                }
            }
            
            return ret;
        });
        
        // (while cond expr)
        g.defineSyntax("while", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var cond:Dynamic = a[0];
            var expr:Dynamic = a[1];
            var ret:Dynamic = null;
            
            // create a new loop environment
            var env:Environment = new Environment(orbit, e);
            env.name = "@while";
            env.type = Environment.TYPE_LOOP;
            
            while (orbit.eval(cond, e))
            {
                ret = orbit.eval(a[1], e);
                if (env.hasReturned) break;
            }
            
            return ret;
        });
        
        // (do expr cond)
        g.defineSyntax("do", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var expr:Dynamic = a[0];
            var cond:Dynamic = a[1];
            var ret:Dynamic = null;
            
            // create a new loop environment
            var env:Environment = new Environment(orbit, e);
            env.name = "@do";
            env.type = Environment.TYPE_LOOP;
            
            do
            {
                ret = orbit.eval(a[1], e);
                if (env.hasReturned) break;
            }
            while (orbit.eval(cond, e));
            
            return ret;
        });
        
        // (cond  (test expr) (test expr) )
        // if expr is missing, returns test
        g.defineSyntax("cond", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var i:Int = 0;
            var n:Int = a.length;
            var arg:Array<Dynamic>;
            var test:Dynamic;
            
            while (i < n)
            {
                arg = a[i];
                test = orbit.eval(arg[0], e);
                
                if (test)
                {
                    if (arg.length == 0)
                        return test;
                    else
                        return orbit.eval(arg[1], e);
                }
                
                i++;
            }
            
            return null;
        });
        
        // (select x
        //     (case (test1 test2 test3) expr)
        //     (case (test1 test2 test3) expr)
        //     (case (test1 test2 test3) expr)
        //     (default expr))
        // select will execute the expression of all matches, and returns the value of the last expression.
        // compare switch
        g.defineSyntax("select", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var x = orbit.eval(a[0], e);
            
            var i:Int = 1;
            var n:Int = a.length;
            
            var arg:Array<Dynamic>;
            var test:Dynamic;
            var expr:Dynamic;
            var ret:Dynamic = null;
            
            // create a new loop environment
            var env:Environment = new Environment(orbit, e);
            env.name = "@select";
            env.type = Environment.TYPE_LOOP;
            
            
            // for each case/default
            while (i < n)
            {
                arg = a[i];
                
                if (arg[0] == "case")
                {
                    expr = arg[2];
                    arg = arg[1];
                    
                    var j:Int = 0;
                    var m:Int = arg.length;
                    
                    // for each test
                    while (j < m)
                    {
                        test = orbit.eval(arg[j], e);
                        
                        // select case matched
                        if (test == x)
                        {
                            ret = orbit.eval(expr, env);
                            break;
                        }
                        
                        j++;
                    }
                }
                else if (arg[0] == "default")
                {
                    expr = arg[1];
                    ret = orbit.eval(expr, env);
                }
                else
                {
                    trace("Error: Unexpected " + arg);
                    return null;
                }
                
                // if we receive a break signal, proceed to evaluate the next case
                if (env.hasReturned) break;
                
                i++;
            }
            
            return ret;
        });
        
        
        // (switch x
        //     (case (test1 test2 test3) expr)
        //     (case (test1 test2 test3) expr)
        //     (case (test1 test2 test3) expr)
        //     (default expr))
        // switch will execute the expression of the FIRST match, and returns.
        // compare select
        g.defineSyntax("switch", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var x = orbit.eval(a[0], e);
            
            var i:Int = 1;
            var n:Int = a.length;
            
            var arg:Array<Dynamic>;
            var test:Dynamic;
            var expr:Dynamic;
            var ret:Dynamic = null;
            
            // create a new loop environment
            var env:Environment = new Environment(orbit, e);
            env.name = "@switch";
            env.type = Environment.TYPE_LOOP;
            
            
            // for each case/default
            while (i < n)
            {
                arg = a[i];
                
                if (arg[0] == "case")
                {
                    expr = arg[2];
                    arg = arg[1];
                    
                    var j:Int = 0;
                    var m:Int = arg.length;
                    
                    // for each test
                    while (j < m)
                    {
                        test = orbit.eval(arg[j], e);
                        
                        // switch case matched
                        if (test == x)
                        {
                            return orbit.eval(expr, env);
                        }
                        
                        j++;
                    }
                }
                else if (arg[0] == "default")
                {
                    expr = arg[1];
                    return orbit.eval(expr, env);
                }
                else
                {
                    trace("Error: Unexpected " + arg);
                    return null;
                }
                
                // if we receive a break signal, proceed to evaluate the next case
                if (env.hasReturned) break;
                
                i++;
            }
            
            return null;
        });
        
    }
    
}