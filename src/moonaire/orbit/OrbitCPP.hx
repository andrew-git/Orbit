package moonaire.orbit;

import cpp.Sys;
import moonaire.orbit.structs.DList;
import moonaire.orbit.structs.DListIterator;
import moonaire.orbit.structs.DListIterator;

/**
 * ...
 * @author Munir Hussin
 */

class OrbitCPP
{
	
	public static function main() 
	{
		var orbit:Orbit = new Orbit();
        orbit.classpaths.push("orb/");
        orbit.require("Main");
        Sys.command("pause");
	}
	
}