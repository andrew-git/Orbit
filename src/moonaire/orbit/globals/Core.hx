package moonaire.orbit.globals;

import moonaire.orbit.Environment;
import moonaire.orbit.Function;
import moonaire.orbit.Orbit;

#if nme
    import nme.system.System;
#elseif cpp
    import cpp.vm.Gc;
#end

/**
 * ...
 * @author Munir Hussin
 */

class Core 
{
    public static function init(orbit:Orbit, g:Environment)
    {
        // constants
        g.defineVariable("global", g.symbols);
        g.defineVariable("modules", orbit.modules);
        g.defineVariable("true", true);
        g.defineVariable("false", false);
        g.defineVariable("null", null);
        
        // (require module)
        // (require symbol module)
        g.defineSyntax("require", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var module:Dynamic = null;
            
            if (a.length > 1)
            {
                // load the module
                var name:String = a[0];
                module = orbit.eval(a[1], e);
                module = orbit.require(module);
                
                // declare a variable, assign to module
                var code:Array<Dynamic> = new Array<Dynamic>();
                code.push("var");
                code.push(name);
                code.push(module);
                return orbit.eval(code, e);
            }
            else
            {
                // load the module
                module = orbit.eval(a[0], e);
                return orbit.require(module);
            }
        });
        
        // (unrequire module)
        g.defineSyntax("unrequire", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var a0:Dynamic = orbit.eval(a[0], e);
            return orbit.unrequire(a0);
        });
        
        // (document file)
        // (document symbol file)
        g.defineSyntax("document", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var module:Dynamic = null;
            
            if (a.length > 1)
            {
                // load the module
                var name:String = a[0];
                module = orbit.eval(a[1], e);
                module = orbit.document(module);
                
                // declare a variable, assign to module
                var code:Array<Dynamic> = new Array<Dynamic>();
                code.push("var");
                code.push(name);
                code.push(module);
                
                return orbit.eval(code, e);
            }
            else
            {
                // load the module
                module = orbit.eval(a[0], e);
                return orbit.document(module);
            }
        });
        
        // (gc)
        g.defineSyntax("gc", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            #if nme
                System.gc();
            #elseif cpp
                Gc.run(true);
            #end
        });
        
        // (trace)
        g.defineSyntax("trace", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.print("Begin Trace");
            e.trace();
            orbit.print("End Trace");
        });
        
        // (print a b c)
        g.defineSyntax("print", function (a:Array<Dynamic>, e:Environment, o:Dynamic):Dynamic
        {
            var i:Int = 0;
            var n:Int = a.length;
            var str:String = "";
            
            while (i < n)
            {
                str += orbit.eval(a[i], e) + " ";
                i++;
            }
            
            orbit.print(str);
            return null;
        });
        
        // (println a b c)
        g.defineSyntax("println", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var i:Int = 1;
            var n:Int = a.length;
            var str:String = "";
            
            orbit.eval(a[0], e);
            
            while (i < n)
            {
                str += "\n" + orbit.eval(a[i], e);
                i++;
            }
            
            orbit.print(str);
            return null;
        });
        
        // (eval expr)
        g.defineSyntax("eval", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            var expr = orbit.eval(a[0], e);
            return orbit.eval(expr, e);
        });
        
        g.defineVariable("read", orbit.read);
        
        // (syntax (a b) body) or (syntax name (a b) body)
        g.defineSyntax("syntax", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            return orbit.lambda(a, e, false);
        });
        
        // (function (a b) body) or (function name (a b) body)
        g.defineSyntax("function", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            return orbit.lambda(a, e, true);
        });
        
        g.defineAlias("lambda", "function");
        
        
        // (compose f g h i)  ==> function (x) { return f(g(h(i(x)))); }  ==> (function () (f (g (h (i x))))
        g.defineSyntax("compose", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            
            var root:Array<Dynamic> = new Array<Dynamic>();
            var prev:Array<Dynamic> = root;
            var curr:Array<Dynamic> = null;
            
            root.push("function");
            //root.push(new Array<Dynamic>());
            root.push(["x"]);
            
            var i:Int = 1;
            var n:Int = a.length;
            
            // the first one is different (doesn't need to be quoted)
            curr = new Array<Dynamic>();
            ///curr.push("call");
            curr.push(a[0]);
            prev.push(curr);
            prev = curr;
            
            // (function () (call f '((call g args))))
            
            while (i < n)
            {
                curr = new Array<Dynamic>();
                ///curr.push("call");
                curr.push(a[i]);
                ///prev.push(["quote", [curr]]);
                prev.push(curr);
                prev = curr;
                
                i++;
            }
            
            // the innermost needs to be passed the arguments
            //curr.push("arguments");
            curr.push("x");
            //curr.push(["quote", [5]]);
            trace("compose " + root);
            return orbit.eval(root, e);
        });
        
        // (map fn list1 list2 list3)  eg: (map add '(1 2 3) '(4 5 6) '(7 8)) => add(1, 4), add(2, 5), add(3, 6)
        g.defineSyntax("map", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            
            var fn:Dynamic = a[0];
            
            var i:Int;
            var j:Int = 0;
            var n:Int = a.length;
            
            var ret:Array<Dynamic> = new Array<Dynamic>();
            var list:Array<Dynamic>;
            var args:Array<Dynamic>;
            
            while (true)
            {
                // reset for the next call
                args = new Array<Dynamic>();
                i = 1;
                
                // loop through all the lists to prepare the arguments
                while (i < n)
                {
                    list = a[i];
                    
                    if (j >= list.length)
                    {
                        // reached the shortest list
                        return ret;
                    }
                    
                    args.push( orbit.eval(list[j], e) );
                    i++;
                }
                
                ret.push( orbit.call(null, fn, args, e) );
                j++;
            }
            
            return ret;
        });
        
        // (filter fn list)       eg: (filter (function (x) (== 0 (% x 2))) '(1 2 3 4 5 6))
        g.defineSyntax("filter", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            
            var fn:Dynamic = a[0];
            var list:Array<Dynamic> = a[1];
            var ret:Array<Dynamic> = new Array<Dynamic>();
            var args:Array<Dynamic> = new Array<Dynamic>();
            
            args.push(null);
            
            var i:Int = 0;
            var n:Int = list.length;
            
            while (i < n)
            {
                args[0] = list[i];
                
                if (orbit.call(null, fn, args, e))
                {
                    ret.push(args[0]);
                }
                
                i++;
            }
            
            return ret;
        });
        
        
        // (fold fn init args)       eg: (fold + 5 '(1 2 3))
        g.defineSyntax("fold", function (a:Array<Dynamic>, e:Environment, o:Environment):Dynamic
        {
            orbit.evalEach(a, e);
            
            var fn:Dynamic = a[0];
            var init:Dynamic = a[1];
            var list:Array<Dynamic> = a[2];
            var args:Array<Dynamic> = new Array<Dynamic>();
            
            args.push(null);
            args.push(null);
            
            var i:Int = 0;
            var n:Int = list.length;
            
            while (i < n)
            {
                args[0] = init;
                args[1] = list[i];
                init = orbit.call(null, fn, args, e);
                i++;
            }
            
            
            return init;
        });
    }
    
}