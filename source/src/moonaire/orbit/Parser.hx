package moonaire.orbit;

#if nme
    import nme.Assets;
#elseif cpp
    import cpp.io.File;
#end

using StringTools;

/**
 * Holy shit this file is a huge mess.
 * 
 * TODO: Cleanup and optimize
 * 
 * What this class is responsible for is to read the string,
 * and output the appropriate data structures (code tree).
 * 
 * This code tree can then be executed, and will return some value.
 * 
 * @author Munir Hussin
 */

class Parser 
{
    private static inline var CHAR_EOF:Int = 0;
    private static inline var CHAR_SPACE:Int = " ".fastCodeAt(0);
    private static inline var CHAR_TAB:Int = "\t".fastCodeAt(0);
    private static inline var CHAR_LF:Int = "\n".fastCodeAt(0);
    private static inline var CHAR_CR:Int = "\r".fastCodeAt(0);
    
    private static inline var CHAR_FOWARD_SLASH:Int = "/".fastCodeAt(0);
    private static inline var CHAR_BACK_SLASH:Int = "\\".fastCodeAt(0);
    private static inline var CHAR_DOUBLE_QUOTE:Int = '"'.fastCodeAt(0);
    private static inline var CHAR_QUOTE:Int = "'".fastCodeAt(0);
    private static inline var CHAR_BACKQUOTE:Int = "`".fastCodeAt(0);
    
    private static inline var CHAR_ASTERISK:Int = "*".fastCodeAt(0);
    private static inline var CHAR_PERIOD:Int = ".".fastCodeAt(0);
    private static inline var CHAR_COLON:Int = ":".fastCodeAt(0);
    private static inline var CHAR_SEMICOLON:Int = ";".fastCodeAt(0);
    private static inline var CHAR_COMMA:Int = ",".fastCodeAt(0);
    private static inline var CHAR_AT:Int = "@".fastCodeAt(0);
    
    // parenthesis
    private static inline var CHAR_OPEN_BRACKET:Int = "(".fastCodeAt(0);
    private static inline var CHAR_CLOSE_BRACKET:Int = ")".fastCodeAt(0);
    private static inline var CHAR_OPEN_SQUARE:Int = "[".fastCodeAt(0);
    private static inline var CHAR_CLOSE_SQUARE:Int = "]".fastCodeAt(0);
    private static inline var CHAR_OPEN_CURLY:Int = "{".fastCodeAt(0);
    private static inline var CHAR_CLOSE_CURLY:Int = "}".fastCodeAt(0);
    private static inline var CHAR_OPEN_ANGLE:Int = "<".fastCodeAt(0);
    private static inline var CHAR_CLOSE_ANGLE:Int = ">".fastCodeAt(0);
    
    // alphanumerics
    private static inline var CHAR_UCASE_A:Int = "A".fastCodeAt(0);
    private static inline var CHAR_UCASE_Z:Int = "Z".fastCodeAt(0);
    private static inline var CHAR_LCASE_A:Int = "a".fastCodeAt(0);
    private static inline var CHAR_LCASE_Z:Int = "z".fastCodeAt(0);
    private static inline var CHAR_NUM_0:Int = "0".fastCodeAt(0);
    private static inline var CHAR_NUM_9:Int = "9".fastCodeAt(0);
    private static inline var CHAR_UNDERSCORE:Int = "_".fastCodeAt(0);
    private static inline var CHAR_DOLLAR:Int = "$".fastCodeAt(0);
    private static inline var CHAR_DASH:Int = "-".fastCodeAt(0);
    private static inline var CHAR_PLUS:Int = "+".fastCodeAt(0);
    
    // comments
    private static inline var STR_INLINE_COMMENT:String = "//";
    private static inline var STR_OPEN_COMMENT:String = "/*";
    private static inline var STR_CLOSE_COMMENT:String = "*/";
    
    // string escape sequences
    private static inline var STR_ESCAPE_SLASH:String = "\\\\";
    private static inline var STR_ESCAPE_LF:String = "\\n";
    private static inline var STR_ESCAPE_CR:String = "\\r";
    private static inline var STR_ESCAPE_TAB:String = "\\t";
    private static inline var STR_ESCAPE_DQ:String = '\\"';
    
    
    public static var orbit:Orbit;
    
    private var data:String;
    private var pos:Int;
    private var n:Int;
    private var c0:Int;
    private var c1:Int;
    private var name:String;
    private var line:Int;
    private var indent:Int;
    
    
    public function new(data:String, name:String)
    {
        this.data = data;
        pos = 0;
        c0 = 0;
        c1 = 0;
        n = data.length;
        
        this.name = name;
        line = 1;
        
        indent = 0;
    }
    
    public static function init(orbit:Orbit):Void
    {
        Parser.orbit = orbit;
    }
    
    private inline function print(s:Dynamic):Void
    {
        orbit.print(name + "> Line " + line + ": " + s);
    }
    
    // for debug
    private inline function printIndent(s:Dynamic):Void
    {
        //var pad:String = StringTools.lpad("", " ", indent * 4);
        //orbit.print(pad + s);
    }
    
    // load code from a file
    public static function load(file:String):Parser
    {
        #if nme
            var data:String = Assets.getText(file);
        #elseif cpp
            var data:String = File.getContent(file);
        #end
        
        return data == null ? null : new Parser(data, file);
    }
    
    // read code from a string
    public static function read(code:String):Parser
    {
        return new Parser(code, "String Data");
    }
    
    
    private function isParenthesis(c:Int):Bool
    {
        return c == CHAR_OPEN_BRACKET || c == CHAR_CLOSE_BRACKET ||
            c == CHAR_OPEN_CURLY || c == CHAR_CLOSE_CURLY ||
            c == CHAR_OPEN_SQUARE || c == CHAR_CLOSE_SQUARE;
    }
    
    private function isWhiteSpace(c:Int):Bool
    {
        return c == CHAR_SPACE || c == CHAR_TAB || c == CHAR_CR || c == CHAR_LF;
    }
    
    private function isSpecialChar(c:Int):Bool
    {
        return c == CHAR_PERIOD || c == CHAR_COLON || c == CHAR_SEMICOLON || c == CHAR_COMMA || c == CHAR_AT || c == CHAR_QUOTE || c == CHAR_BACKQUOTE || c == CHAR_DOUBLE_QUOTE;
    }
    
    private function isAlpha(c:Int):Bool
    {
        return (c >= CHAR_UCASE_A && c <= CHAR_UCASE_Z) || (c >= CHAR_LCASE_A && c <= CHAR_LCASE_Z);
    }
    
    private function isNumber(c:Int):Bool
    {
        return c >= CHAR_NUM_0 && c <= CHAR_NUM_9;
    }
    
    private function isAlphaNumeric(c:Int):Bool
    {
        return isAlpha(c) || isNumber(c);
    }
    
    private function isValidVariableStart(c:Int):Bool
    {
        return isAlpha(c) || c == CHAR_UNDERSCORE || c == CHAR_DOLLAR;
    }
    
    private function isTerminator(c:Int):Bool
    {
        return isParenthesis(c) || isWhiteSpace(c) || c == CHAR_COLON || c == CHAR_DOUBLE_QUOTE;
    }
    
    private function isSymbolTerminator(c:Int):Bool
    {
        return isParenthesis(c) || isWhiteSpace(c) || c == CHAR_COLON || c == CHAR_DOUBLE_QUOTE || c == CHAR_PERIOD;
    }
    
    
    // skips spaces, tabs, line feeds, carriage returns
    private function skipWhiteSpace():Void
    {
        while (pos < n)
        {
            c0 = data.fastCodeAt(pos);
            
            if (c0 == CHAR_LF) line++;
            
            if (!isWhiteSpace(c0))
            {
                return;
            }
            
            pos++;
        }
        // eof
    }
    
    
    private function match(s:String):Bool
    {
        // assumptions: c0 is already set
        
        var len:Int = s.length;
        
        if (pos + len > n)
        {
            return false;
        }
        else if (len == 1)
        {
            return s.fastCodeAt(0) == c0;
        }
        else
        {
            var sub:String = data.substr(pos, len);
            return sub == s;
        }
    }
    
    
    public function parse():Dynamic
    {
        var next:Dynamic = null;
        var code:Array<Dynamic> = new Array<Dynamic>();
        code.push("begin");
        
        while (true)
        {
            next = parseNext();
            if (next == null) return code;
            else code.push(next);
        }
        
        return code;
    }
    
    
    public function parseNext(?shouldSkipWhiteSpace:Bool = true):Dynamic
    {
        printIndent("parseNext");
        
        // find the start of the next token
        if (shouldSkipWhiteSpace) skipWhiteSpace();
        
        // end of file?
        if (pos >= n)
        {
            if (indent > 0)
            {
                print("Error: Unexpected end of file");
            }
            
            return null;
        }
        
        if (indent < 0)
        {
            print("Error: Mismatched braces");
            return null;
        }
        
        // get the current char
        c0 = data.fastCodeAt(pos);
        
        
        var next:Dynamic;
        
        
        if (match(STR_INLINE_COMMENT))                      // skip comments
        {
            next = parseInlineComment();
        }
        else if (match(STR_OPEN_COMMENT))
        {
            next = parseBlockComment();
        }
        else if (match("#print"))
        {
            pos += "#print".length;
            print("#print");
            next = parseNext();
        }
        else if (c0 == CHAR_QUOTE)                          // 'a ==> (quote a)
        {
            pos++;
            
            var a:Array<Dynamic> = new Array<Dynamic>();
            a.push("quote");
            a.push(parseNext());
            
            next = a;
        }
        else if (c0 == CHAR_BACKQUOTE)
        {
            return null;
        }
        else if (c0 == CHAR_DASH || c0 == CHAR_PLUS)        // possibly a number?
        {
            if (pos + 1 < n)    // next char available
            {
                var c1:Int = data.fastCodeAt(pos + 1);
                
                if (c1 >= CHAR_NUM_0 && c1 <= CHAR_NUM_9)   // -123
                {
                    next = parseNumber();
                }
                else if (isWhiteSpace(c1))                  // -
                {
                    next = parseSymbol();
                }
                else if (isValidVariableStart(c1))          // -abc
                {
                    pos++;
                    
                    // automatically turn -x into (- x)
                    var arr:Array<Dynamic> = new Array<Dynamic>();
                    arr.push(String.fromCharCode(c0));
                    arr.push(parseSymbol());
                    next = arr;
                }
                else                                        // -- -=
                {
                    next = parseSymbol();
                }
            }
            else
            {
                next = parseSymbol();
            }
        }
        else if (c0 >= CHAR_NUM_0 && c0 <= CHAR_NUM_9)      // is it a number?
        {
            next = parseNumber();
        }
        else if (c0 == CHAR_OPEN_BRACKET)
        {
            var array:Array<Dynamic> = new Array<Dynamic>();
            next = parseArray(array, CHAR_CLOSE_BRACKET);
        }
        else if (c0 == CHAR_OPEN_CURLY)
        {
            var array:Array<Dynamic> = new Array<Dynamic>();
            array.push("table");
            next = parseArray(array, CHAR_CLOSE_CURLY);
        }
        else if (c0 == CHAR_OPEN_SQUARE)
        {
            var array:Array<Dynamic> = new Array<Dynamic>();
            array.push("array");
            next = parseArray(array, CHAR_CLOSE_SQUARE);
        }
        else if (c0 == CHAR_DOUBLE_QUOTE)
        {
            next = parseString();
        }
        else if (c0 == CHAR_CLOSE_BRACKET || c0 == CHAR_CLOSE_CURLY || c0 == CHAR_CLOSE_SQUARE)
        {
            return null;
        }
        else if (isWhiteSpace(c0))
        {
            // might happen if skip white space is set to false
            return null;
        }
        else
        {
            next = parseSymbol();
        }
        
        // before we return, we check if the next non-whitespace char is a colon
        if (shouldSkipWhiteSpace)
        {
            skipWhiteSpace();
            c0 = data.fastCodeAt(pos);
            
            if (c0 == CHAR_COLON)
            {
                pos++;
                
                // we're expecting a pair
                var pair:Array<Dynamic> = new Array<Dynamic>();
                pair.push(next);
                pair.push(parseNext());
                next = pair;
            }
        }
        
        return next;
    }
    
    
    private function parseArray(array:Array<Dynamic>, closeChar:Int):Dynamic
    {
        printIndent("parseArray");
        indent++;
        
        // we have an array, so create one
        var next:Dynamic;
        
        pos++;
        
        while (true)
        {
            // get next token
            next = parseNext();
            
            // no more tokens
            if (next == null)
            {
                // if there's no more tokens, check that the current char is a close bracket
                if (c0 == closeChar)
                {
                    indent--;
                    pos++;
                    return array;
                }
                else
                {
                    // error: unexpected closing char
                    print("Error: Mismatched braces " + String.fromCharCode(c0));
                    return null;
                }
            }
            else
            {
                // add the token
                array.push(next);
            }
        }
        
        // code shouldn't be able to reach here
        return null;
    }
    
    
    
    private function parseSymbol(?shouldParseProperty:Bool = true):Dynamic
    {
        printIndent("parseSymbol");
        var symbol:Dynamic;
        var start:Int = pos;
        pos++;
        
        while (pos < n)
        {
            c0 = data.fastCodeAt(pos);
            
            if (isSymbolTerminator(c0) || match(STR_INLINE_COMMENT) || match(STR_OPEN_COMMENT))
            {
                // we have the symbol
                symbol = data.substr(start, pos - start);
                
                // check if it's a plain variable or are we accessing inner properties
                if (shouldParseProperty && (c0 == CHAR_OPEN_SQUARE || c0 == CHAR_PERIOD))
                {
                    // bug with type inference in haxe? this doesn't work.
                    // it turns all elements in the array into strings
                    // var prop:Array<Dynamic> = ["index", symbol];
                    var prop:Array<Dynamic> = new Array<Dynamic>();
                    var next:Dynamic = null;
                    
                    prop.push("index");
                    prop.push(symbol);
                    
                    while (true)
                    {
                        if (c0 == CHAR_OPEN_SQUARE)
                        {
                            pos++;
                            indent++;
                            while ((next = parseNext()) != null) prop.push(next);
                            
                            if (c0 == CHAR_CLOSE_SQUARE)
                            {
                                pos++;
                                indent--;
                                c0 = data.fastCodeAt(pos);
                            }
                            else
                            {
                                print("Error: Mismatched braces " + String.fromCharCode(c0));
                                return null; // error unexpected closing char
                            }
                        }
                        else if (c0 == CHAR_PERIOD)
                        {
                            pos++;
                            next = parseSymbol(false);
                            
                            // bug with type inference in haxe? this doesn't work.
                            // it turns all elements in the array into strings
                            // var p:Array<Dynamic> = ["quote", next];
                            var p:Array<Dynamic> = new Array<Dynamic>();
                            p.push("quote");
                            p.push(next);
                            prop.push(p);
                            
                            var q:Dynamic = prop[prop.length - 1];
                            
                            // update c0 for next loop
                            c0 = data.fastCodeAt(pos);
                        }
                        else
                        {
                            return prop;
                        }
                    }
                    
                    return prop;
                }
                else
                {
                    return symbol;
                }
            }
            
            pos++;
        }
        
        return data.substr(start, pos - start);
    }
    
    private function parseNumber():Dynamic
    {
        printIndent("parseNumber");
        var symbol:String = data.substr(pos, 1);
        var start:Int = pos;
        pos++;
        
        while (pos < n)
        {
            c0 = data.fastCodeAt(pos);
            
            if (isTerminator(c0) || match(STR_INLINE_COMMENT) || match(STR_OPEN_COMMENT))
            {
                // we have the symbol
                symbol = data.substr(start, pos - start);
                
                if (symbol.indexOf(".") >= 0 || symbol.charAt(-1) == "f")
                {
                    return Std.parseFloat(symbol);
                }
                else
                {
                    var f:Float = Std.parseFloat(symbol);
                    var i:Int = Std.parseInt(symbol);
                    if (f != i) return f;
                    else return i;
                }
            }
            
            pos++;
        }
        
        print("Error: Bad number " + symbol);
        return null;
    }
    
    
    private function parseString():Dynamic
    {
        printIndent("parseString");
        // 1 - look for "
        var string:String = "";
        var start:Int = pos;
        
        indent++;
        
        while (pos < n)
        {
            pos++;
            c0 = data.fastCodeAt(pos);
            
            if (c0 == CHAR_LF)
            {
                line++;
            }
            else if (c0 == CHAR_DOUBLE_QUOTE)
            {
                // end of string
                indent--;
                string += data.substr(start, ++pos - start);
                return string;
            }
            else if (match(STR_ESCAPE_SLASH))   // handle escape sequences
            {
                string += data.substr(start, pos - start) + "\\";
                start = ++pos + 1;
            }
            else if (match(STR_ESCAPE_DQ))
            {
                string += data.substr(start, pos - start) + '"';
                start = ++pos + 1;
            }
            else if (match(STR_ESCAPE_LF))
            {
                string += data.substr(start, pos - start) + "\n";
                start = ++pos + 1;
            }
            else if (match(STR_ESCAPE_CR))
            {
                string += data.substr(start, pos - start) + "\r";
                start = ++pos + 1;
            }
            else if (match(STR_ESCAPE_TAB))
            {
                string += data.substr(start, pos - start) + "\t";
                start = ++pos + 1;
            }
        }
        
        // eof
        print("Error: Unexpected end of string");
        return null;
    }
    
    private function parseInlineComment():Dynamic
    {
        printIndent("parseInlineComment");
        // 1 - look for cr or lf
        // 2 - return the next non-comment token (recursion)
        var start:Int = pos;
        pos++;
        
        while (pos < n)
        {
            pos++;
            c0 = data.fastCodeAt(pos);
            
            // found end of line
            if (c0 == CHAR_LF ||c0 == CHAR_CR)
            {
                return parseNext();
            }
        }
        
        // eof
        return null;
    }
    
    private function parseBlockComment():Dynamic
    {
        printIndent("parseBlockComment");
        // 1 - look for */ pattern
        // 2 - return the next non-comment token (recursion)
        var start:Int = pos;
        pos++;
        
        while (pos < n)
        {
            pos++;
            c0 = data.fastCodeAt(pos);
            
            // found end of line
            if (c0 == CHAR_LF)
            {
                line++;
            }
            else if (match(STR_CLOSE_COMMENT))
            {
                pos += 2;
                return parseNext();
            }
        }
        
        // eof
        return null;
    }
    
}