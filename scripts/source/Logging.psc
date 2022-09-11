ScriptName Logging
{
A collection of global functions for logging and assertions.
}

import Devourment_JCDomain

;=================================================
; Assertion functions.
;


bool Function assertFail(String prefix, String func, String msg) global
{
Assertion-logger for illegal states.
}
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertEqual(String prefix, String func, int n1, int n2) global
{
Assertion-logger for checking if two integers are equal.
* prefix should be the script name.
* func should be the name of the calling function.
* n1 and n2 should be the numbers being tested.
}
	if n1 == n2
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + n1 + " != " + n2 + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertUnequal(String prefix, String func, int n1, int n2) global
{
Assertion-logger for checking if two integers are unequal.
* prefix should be the script name.
* func should be the name of the calling function.
* n1 and n2 should be the numbers being tested.
}
	if n1 != n2
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + n1 + " == " + n2 + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertNotSame(String prefix, String func, Form f1, Form f2) global
{
Assertion-logger for checking if two forms are not the same.
* prefix should be the script name.
* func should be the name of the calling function.
* f1 and f2 should be the forms being tested.
}
	if f1 != f2
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + Namer(f1) + " is the same form as " + Namer(f2) + ")"
	Debug.TraceStack(msg)
	return false
endFunction


bool Function assertSame(String prefix, String func, Form f1, Form f2) global
{
Assertion-logger for checking if two forms are the same form.
* prefix should be the script name.
* func should be the name of the calling function.
* f1 and f2 should be the forms being tested.
}
	if f1 == f2
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + Namer(f1) + " is not the same form as " + Namer(f2) + ")"
	Debug.TraceStack(msg)
	return false
endFunction


bool Function assertStringsEqual(String prefix, String func, String s1, String s2) global
{
Assertion-logger for checking if two strings are equal.
* prefix should be the script name.
* func should be the name of the calling function.
* s1 and s2 should be the strings being tested.
}
	if s1 == s2
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: '" + s1 + "' != '" + s2 + "')"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertNotNone(String prefix, String func, String name, Form val) global
{
Assertion-logger for checking if a form is NONE.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* val should be the result of the variable to be tested.
}
	if val != none 
		return true 
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + " == None)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertNone(String prefix, String func, String name, Form val) global
{
Assertion-logger for checking if a form is NONE.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* val should be the result of the variable to be tested.
}
	if val == none 
		return true 
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + " != None)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertAliasNotNone(String prefix, String func, String name, Alias val) global
{
Assertion-logger for checking if an alias is NONE.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* val should be the result of the variable to be tested.
}
	if val != none 
		return true 
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + " == None)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertAs(String prefix, String func, Form val, bool check) global
{
Assertion-logger for a casting operation.
* prefix should be the script name.
* func should be the name of the calling function.
* val should be the form object.
* check should be the result of the casting check.
}
	if check
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + Namer(val) + " is the wrong type)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertInt(String prefix, String func, String name, int val, int lower, int upper) global
{
Assertion-logger for an integer range check.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* val should be the variable.
* lower and upper should be the inclusive bounds of the variable.
}
	if val >= lower && val <= upper
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + "=" + val + " is not in the range [" + lower + ", " + upper + "]"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertFlt(String prefix, String func, String name, float val, float lower, float upper) global
{
Assertion-logger for a float range check.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* val should be the variable.
* lower and upper should be the inclusive bounds of the variable.
}
	if val >= lower && val <= upper
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + "=" + val + " is not in the range [" + lower + ", " + upper + "])"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertIndex(String prefix, String func, String name, int index, int len) global
{
Assertion-logger for an array index check.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* index should be the array index.
* len should be the array length.
}
	if index >= 0 && index < len
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + index + " is an invalid index for " + name + " ; length = " + len + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertPositive(String prefix, String func, String name, float val) global
{
Assertion-logger for a float >0 check.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the variable.
* val should be the variable.
}
	if val > 0.0
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + "=" + val + " must be positive)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertAliasSet(String prefix, String func, ReferenceAlias als) global
{
Assertion-logger for an alias being set.
* prefix should be the script name.
* func should be the name of the calling function.
* als Should be the alias of interest.
}
	if als && als.getRef() != none
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + AliasNamer(als) + " not set)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertAliasIs(String prefix, String func, ReferenceAlias als, ObjectReference f) global
{
Assertion-logger for an Alias's reference.
* prefix should be the script name.
* func should be the name of the calling function.
* als Should be the alias of interest.
* f should be the expected value of the alias.
}
	if als.getRef() == f
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + AliasNamer(als) + " not set to " + Namer(f) + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertTrue(String prefix, String func, String description, bool condition) global
{
General purpose assertion-logger.
* prefix should be the script name.
* func should be the name of the calling function.
* description should be the condition message.
* condition
}
	if condition
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + description + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertFalse(String prefix, String func, String description, bool condition) global
{
General purpose assertion-logger.
* prefix should be the script name.
* func should be the name of the calling function.
* description should be the condition message.
* condition
}
	if !condition
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + description + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertExists(String prefix, String func, String name, int obj) global
{
Assertion-logger for a JLua isExists test.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the JLua object variable.
* obj should be the JLua object whose existence is being tested.
}
	if JValue_isExists(obj)
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + " is non-existent)"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


bool Function assertHas(String prefix, String func, String name, String k, int obj) global
{
Assertion-logger for a JContainer to have a key.
* prefix should be the script name.
* func should be the name of the calling function.
* name should be the name of the JMap variable.
* k should be the string key.
* obj should be a JMap.
}
	if JMap_hasKey(obj, k)
		return true
	endIf
	
	String msg = prefix + "." + func + "(Error: " + name + " must have key " + k + ")"
	Debug.TraceStack(msg, aiSeverity = 2)
	return false
endFunction


;=================================================
; Logging functions.
;


Function LogAndBox(String prefix, String func, String description, int aiSeverity) global
{
General purpose logging command with a class, function, and message.
* prefix should be the script name.
* func should be the name of the calling function.
This logging function will continue to work even when logging is disabled.
}
	String msg = prefix + "." + func + ": " + description
	Debug.MessageBox(msg)

	if aiSeverity > 0
		Debug.TraceStack(msg, aiSeverity)
	else
		Debug.Trace(msg, aiSeverity)
	endIf
EndFunction


Function Log(String prefix, String func, String description, int aiSeverity) global
{
General purpose logging command with a class, function, and message.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + ": " + description

	if aiSeverity > 0
		Debug.TraceStack(msg, aiSeverity)
	else
		Debug.Trace(msg, aiSeverity)
	endIf
EndFunction


Function Log0(String prefix, String func) global
{
Logger for a function with zero arguments.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "()"
	Debug.Trace(msg)
EndFunction


Function Log1(String prefix, String func, String p1) global
{
Logger for a function with one argument (or other type of information).
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ")"
	Debug.Trace(msg)
EndFunction


Function Log2(String prefix, String func, String p1, String p2) global
{
Logger for a function with two arguments (or other types of information).
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ")"
	Debug.Trace(msg)
EndFunction


Function Log3(String prefix, String func, String p1, String p2, String p3) global
{
Logger for a function with three arguments (or other types of information).
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ", " + p3 + ")"
	Debug.Trace(msg)
EndFunction


Function Log4(String prefix, String func, String p1, String p2, String p3, String p4) global
{
Logger for a function with four arguments (or other types of information).
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ", " + p3 + ", " + p4 + ")"
	Debug.Trace(msg)
EndFunction


Function Log5(String prefix, String func, String p1, String p2, String p3, String p4, String p5) global
{
Logger for a function with five arguments (or other types of information).
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ", " + p3 + ", " + p4 + ", " + p5 + ")"
	Debug.Trace(msg)
EndFunction


Function Log6(String prefix, String func, String p1, String p2, String p3, String p4, String p5, String p6) global
{
Logger for a function with six arguments (or other types of information).
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ", " + p3 + ", " + p4 + ", " + p5 + ", " + p6 + ")"
	Debug.Trace(msg)
EndFunction


Function Log7(String prefix, String func, String p1, String p2, String p3, String p4, String p5, String p6, String p7) global
	{
	Logger for a function with six arguments (or other types of information).
	* prefix should be the script name.
	* func should be the name of the calling function.
	}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ", " + p3 + ", " + p4 + ", " + p5 + ", " + p6 + ", " + p7 + ")"
	Debug.Trace(msg)
EndFunction
	
	
Function Log8(String prefix, String func, String p1, String p2, String p3, String p4, String p5, String p6, String p7, String p8) global
	{
	Logger for a function with six arguments (or other types of information).
	* prefix should be the script name.
	* func should be the name of the calling function.
	}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + p1 + ", " + p2 + ", " + p3 + ", " + p4 + ", " + p5 + ", " + p6 + ", " + p7 + ", " + p8 + ")"
	Debug.Trace(msg)
EndFunction
	
	
Function LogForms(String prefix, String func, String name, Form[] arr) global
{
Logger for an array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + FormArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction


Function LogKeywords(String prefix, String func, String name, Keyword[] arr) global
{
Logger for an array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + KeywordArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction


Function LogRefs(String prefix, String func, String name, ObjectReference[] arr) global
{
Logger for an array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + RefArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction


Function LogActors(String prefix, String func, String name, Actor[] arr) global
{
Logger for an array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + ActorArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction


Function LogStrings(String prefix, String func, String name, String[] arr) global
{
Logger for an alias array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + StringArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction


Function LogFloats(String prefix, String func, String name, float[] arr) global
{
Logger for an alias array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + FloatArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction


Function LogBools(String prefix, String func, String name, bool[] arr) global
{
Logger for an alias array.
* prefix should be the script name.
* func should be the name of the calling function.
}
	if !loggingEnabled()
		return
	endIf
	
	String msg = prefix + "." + func + "(" + name + " = " + BoolArrayToString(arr) + ")"
	Debug.Trace(msg)
EndFunction
	
	
Function LogJ(String prefix, String func, int obj = 0, Form f1 = none, Form f2 = none, Form f3 = none) global
{
Logger for a function with two arguments.
* prefix should be the script name.
* func should be the name of the calling function.
* f is a form of interest.
* obj is a JContainers structure.
}
	if !loggingEnabled()
		return
	endIf
	
	if f3
		Logging.Log4(prefix, func, Namer(f1), Namer(f2), Namer(f3), LuaS("", obj))
	elseif f2
		Logging.Log3(prefix, func, Namer(f1), Namer(f2), LuaS("", obj))
	elseif f1
		Logging.Log2(prefix, func, Namer(f1), LuaS("", obj))
	else
		Logging.Log1(prefix, func, LuaS("", obj))
	endIf
EndFunction


String Function LuaS(String name, int luaObj) global
{ Pretty-prints a JLua object as a string. }
	if name == ""
		return "(" + luaObj + ") =" + JLua_evalLuaStr("return logging.tableToString(args)", luaObj, "NIL", false)
	else
		return name + "(" + luaObj + ") =" + JLua_evalLuaStr("return logging.tableToString(args)", luaObj, "NIL", false)
	endIf
EndFunction


String Function FormArrayToString(Form[] arr) global
{ Pretty-prints a Form array as a string.
}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + Namer(arr[0]) + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			merge = merge + Namer(arr[i]) + ", "
			i += 1
		endwhile

		merge = merge + Namer(arr[i]) + "]"
	endif

	return merge
EndFunction


String Function KeywordArrayToString(Keyword[] arr) global
{ Pretty-prints a Keyword array as a string.
}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + Namer(arr[0]) + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			merge = merge + Namer(arr[i]) + ", "
			i += 1
		endwhile

		merge = merge + Namer(arr[i]) + "]"
	endif

	return merge
EndFunction
	
	
	String Function PerkArrayToString(Perk[] arr) global
{ Pretty-prints a Perk array as a string. }
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + Namer(arr[0]) + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			merge = merge + Namer(arr[i]) + ", "
			i += 1
		endwhile

		merge = merge + Namer(arr[i]) + "]"
	endif

	return merge
EndFunction
	
	
String Function SpellArrayToString(Spell[] arr) global
{ Pretty-prints a Spell array as a string. }
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + Namer(arr[0]) + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			merge = merge + Namer(arr[i]) + ", "
			i += 1
		endwhile

		merge = merge + Namer(arr[i]) + "]"
	endif

	return merge
EndFunction
	
	
String Function RefArrayToString(ObjectReference[] arr) global
{ Pretty-prints an ObjectReference array as a string.}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + Namer(arr[0]) + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			merge = merge + Namer(arr[i]) + ", "
			i += 1
		endwhile

		merge = merge + Namer(arr[i]) + "]"
	endif

	return merge
EndFunction


String Function ActorArrayToString(Actor[] arr) global
{ Pretty-prints an Actor array as a string.
}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + Namer(arr[0]) + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			merge = merge + Namer(arr[i]) + ", "
			i += 1
		endwhile

		merge = merge + Namer(arr[i]) + "]"
	endif

	return merge
EndFunction


String Function StringArrayToString(String[] arr, int index = -1) global
{ Pretty-prints a String array as a string.
}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + arr[0] + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			if index == i
				merge = merge + ">" + arr[i] + "<, "
			else
				merge = merge + arr[i] + ", "
			endIf
			i += 1
		endwhile

		if index == i
			merge = merge + ">" + arr[i] + "<]"
		else
			merge = merge + arr[i] + "]"
		endIf
	endif

	return merge
EndFunction


String Function FloatArrayToString(float[] arr, int index = -1) global
{ Pretty-prints a float array as a string.
}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + arr[0] + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			if index == i
				merge = merge + ">" + arr[i] + "<, "
			else
				merge = merge + arr[i] + ", "
			endIf
			i += 1
		endwhile

		if index == i
			merge = merge + ">" + arr[i] + "<]"
		else
			merge = merge + arr[i] + "]"
		endIf
	endif

	return merge
EndFunction


String Function IntArrayToString(int[] arr, int index = -1) global
	{ Pretty-prints a float array as a string.}
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + arr[0] + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			if index == i
				merge = merge + ">" + arr[i] + "<, "
			else
				merge = merge + arr[i] + ", "
			endIf
			i += 1
		endwhile

		if index == i
			merge = merge + ">" + arr[i] + "<]"
		else
			merge = merge + arr[i] + "]"
		endIf
	endif

	return merge
EndFunction
	
	
String Function BoolArrayToString(bool[] arr, int index = -1) global
	{ Pretty-prints a float array as a string. }
	
	String merge

	if arr.length == 0
		merge = "[]"
	elseif arr.length == 1
		merge = "[" + arr[0] + "]"
	else
		merge = "["
		int i = 0
		while i < arr.length - 1
			if index == i
				merge = merge + ">" + arr[i] + "<, "
			else
				merge = merge + arr[i] + ", "
			endIf
			i += 1
		endwhile

		if index == i
			merge = merge + ">" + arr[i] + "<]"
		else
			merge = merge + arr[i] + "]"
		endIf
	endif

	return merge
EndFunction


;=================================================
; Debugging utility functions.
;


String Function AliasNamer(Alias obj, bool display = false) global
{
Attempts to convert an alias into a useful string for debugging.
Since this is usually for debugging, the default is for it to
include the refID as well, unless display is set to true.
}
	if obj == None
		return None as string

	elseif obj as ReferenceAlias
		String questName = obj.getOwningQuest().getName()
		String name = obj.getName()
		Actor ref = (obj as ReferenceAlias).getActorRef()
		return questName + "." + name + "(" + Namer(ref) + ")" 
	else
		return obj as String
	endif
EndFunction


String Function NamerDebug(Form obj) global
	String name = Namer(obj)

	ObjectReference ref = obj as ObjectReference
	if ref
		name += "\n" + ref.GetDisplayName() + " (display)"
	endIf

	Actor act = obj as Actor
	if act
		name += "\n" + act.GetLeveledActorBase().GetName() + " (leveled)"
		name += "\n" + act.GetActorBase().GetName() + " (unleveled)"
	endIf
EndFunction


String Function Namer(Form obj, bool display = false) global
{
Attempts to convert a form into a useful string for debugging.
Since this is usually for debugging, the default is for it to
include the refID as well, unless display is set to true.
}
	if obj == None
		return None as string

	elseif obj as Actor
		String name = (obj as Actor).getDisplayName()
		if name == ""
			ActorBase base = (obj as Actor).getLeveledActorBase()
			name = base.getName()
			if name == ""
				name = base.getRace().getName()
			endIf
		endIf

		if display
			return name
		else
			return name + " " + PO3_SKSEFunctions.IntToString(obj.getFormID(), true)
		endif

	elseif obj as DevourmentBolus
		if display
			return obj.getName()
		else
			return obj.getName() + " " + PO3_SKSEFunctions.IntToString(obj.getFormID(), true)
		endif
	
	elseif obj as ObjectReference
		ObjectReference ref = obj as ObjectReference
		String name = ref.GetDisplayName()
		if name == ""
			name = ref.getName()
			if name == ""
				name = ref.GetBaseObject().getName()
			endIf
		endif
		
		if display
			return name
		else
			return name + " " + PO3_SKSEFunctions.IntToString(obj.getFormID(), true)
		endif

	elseif obj as Keyword
		if display
			return (obj as Keyword).getString()
		else
			return (obj as Keyword).getString() + " " + PO3_SKSEFunctions.IntToString(obj.getFormID(), true)
		endif

	else
		if display
			return obj.getName()
		else
			return obj.getName() + " " + PO3_SKSEFunctions.IntToString(obj.getFormID(), true)
		endif
	endif
EndFunction


String Function Hex32(int val) global
{
Formats an integer as an 8 digit hexadecimal string.
Uses the JContainers Lua interface.
}
	return JLua_evalLuaStr("return string.format(\"%08x\", " + val + ")", 0)
EndFunction


int Function Int32(String hex) global
{
Formats an integer as an 8 digit hexadecimal string.
Uses the JContainers Lua interface.
}
	return JLua_evalLuaInt("return tonumber('0x" + hex + "') or 0", 0)
EndFunction


bool Function loggingEnabled() global
	return true
endFunction
