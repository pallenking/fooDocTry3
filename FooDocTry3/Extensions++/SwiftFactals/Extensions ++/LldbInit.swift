//  LldbInit.swift -- Pretty Print common FW types, thru ~/.lldbinit C2018PAK

import SceneKit
// See INSTALL.md

/* To do:
	1. NSColor pps		== :NSColorSpaceColor
	2. SCNMaterial
	3. pt pCon2Spot
 */

 /// Access to current Part Tree
var rootPart  : RootPart		{	return rootpart() as! RootPart				}
//var rootPart  : RootPart		{
//	return DOC?.rootPart ?? {
//		print("DOC?.rootPart is nil")
//		return RootPart()
//	} ()
//}
func rootpart(_ name:String?=nil) -> Part  {
	if var rv : Part			= DOC?.rootPart {
		if name != nil {			// Search for sought Part	//maxLevel:1,
			rv					= rv.find(name:name!, inMe2:true) ?? rv
		}
		return rv
	}
	return .null				// Strange hack
}

 /// Access to current Vew Tree
var  rootVew  : Vew  			{	return rootvew()							}
func rootvew(_ name:String?=nil) -> Vew  {
	guard let fwScene 			= DOC?.fwScene else {
		print("rootvew() returns .null:\(ppUid(Vew.null)) !!!")
		return .null
	}
	var rv : Vew				= fwScene.rootVew
	if name != nil {			// Search for named Vew
		rv						= rv.find(name:name!, inMe2:true) ?? rv
	}
	return rv
}

 /// Access to current root  SCNNode  being debugged
var  rootScn  : SCNNode  	{	return rootscn()								}
func rootscn(_ name:String?=nil) -> SCNNode	{
	guard let fwScene 			= DOC.fwScene else {
		print("rootscn(): is nil! Ignore next line(s)")
		return .null
	}
	var scnRv					= fwScene.rootScn 	// Root

	 // Search for named SCN:
	if name != nil {
		scnRv					= scnRv.find(inMe2:true, all:true, firstWith: // Scn named
		{(scn:SCNNode) -> Bool in
			return scn.name == name
//			return scn.fullName.contains(substring:name!)
		}) 						  ?? scnRv				// if not found
	}
	return scnRv
}

 // Print SwiftFactal help from lldb
func fwHelp(_ key:String="?") {
	sendApp(key:key)
}
 // Send a key to controller:
func sendApp(key:String="?") {
	if let doc				= DOC,
	   let ginnedUpEvent	= NSEvent.keyEvent(
			with			: NSEvent.EventType(rawValue: 10)!,//keyDown,
			location		: NSZeroPoint,
			modifierFlags	: NSEvent.ModifierFlags(rawValue: 0),
			timestamp		: 0.0,
			windowNumber	: 0,
			context			: nil,
			characters		: key,
			charactersIgnoringModifiers: key,
			isARepeat		: false,
			keyCode			: 0)
	{
		let _			 	= doc.processKey(from:ginnedUpEvent, inVew:nil)
	}
	else {
		print("#### #### No current Controller; not using sendApp(key:\(key)) ########")
		switch key {
		case "C":
			printFwcConfig()	// Controller Configuration
		case "c":
			printFwcState()		// Current controller state
		case "?":
			printDebuggerHints()
		default:
			fatalError("sendApp finds nil Controller.current")
		}
	}
}
func printDebuggerHints() {
	print ("\n=== Controller commands:",
	//	"\t" + "<esc>           -- exit program",
		"\t'u'+cmd         -- go to lldb for retest",
		"\t"+"esc             -- beep and exit",  /*Character("\u{1b}")*/
		"\t'N'+alt         -- write out SCNNode tree as .dae",
		"\t'?'             -- display this help message",
		"\t'b'             -- BREAK to debugger in SimNsWc",
		"\t'd'             -- run debugging code",
		"\t'm'             -- print Model Parts",
		"\t'M'             -- print Model Parts and Ports",
		"\t'l'             -- print Model Parts, Links",
		"\t'L'             -- print Model Parts, Links, Ports",
		"\t'C'             -- print System Configuration (1-line of each hash)",
		"\t'c'             -- print System Controllers State (1-line state of each)",
		separator:"\n")
	print("\n===== Debugger Hints: =================",
		"\t" + "pc <expr>       -- print fwClassName of <expr>",
		"\t" + "pn <expr>       -- print name of <expr>",
		"\t" + "pf <expr>       -- print full name of <expr>",
		"\t" + "pt <expr>       -- print the tree with <expr> as root",
		"\t" + "pi <expr>       -- print id (name:fwClassName) of <expr>",
		"\t\t e.g. pts, ptm, ptv, pt foo",
		"\t" + "<expr> might be rootpart(\"<name>\"), or rootvew(\"<name>\") to find a part in tree",
		"\t" + "Common Commands: ptm, plv, ppn, pfs, ptPm, plLm",
		"\t\t" + "Char 1:   p- -: Pretty Print",
		"\t\t" + "Char 2:   -p -:.phrase; -l -:.line,     -t -:.tree,",
		"\t\t" + "Char 2:   -c -: classF; -n -:name,      -f -:fullName,  -i -:.id,",
		"\t\t" + "Char 2.5: --L-:ppLinks; --P-:ppParameters",
		"\t\t" + "Char 3:   -- s: self;   -- m:root Model -- v:root Vew  --n:root SCNNode",
		"\t" + "use rootpart(\"<name>\") and rootvew(\"<name>\") to find a part in tree",
		"\t" + "pFwcState:  -- ('C') print System Controllers State (1-line state of each)",
		"\t" + "pFwcConfig: -- ('c') print System Configuration     (1-line of each hash)",
		separator:"\n")
	print("\n=== Configuration:",
		"\t" + " reload with  lldbinit  = '  command source ~/src/SwiftFactals/.lldbinit  '",
/**/	"\t" + "    N.B: must have symbolic link ~/.lldbinit ->  ~/src/SwiftFactals/.lldbinit  ",
		separator:"\n")
}

	/// Understand/move the following:
/** CONFIGURATION SUBSYSTEM: 20190124 *//*
0. ======== Ahead of Time, load config in HaveNWant: ==========================

1. ======== LOADING: ===========================================================
		xr() ->	addUserPrefs		-> HaveNWant.config ...  --> *** ctl.config

2. ======== USES: ==============================================================
	2A. ================ Pretty Print
	pp(["opt":val])					                    --> String
			\				 /
		[[[ Pretty Print, parameterized ]]] --> String
				   \>      >'
		   aux.string_("ppXYZWena") 					--> *** FwConfig Access
-- print SCNNode tree
	2B. ================ Operational Configuration
	//		e.g:  doc.config.int_("breakAt")
	doc["breakAt"].asInt_   DEPRICATED
	Log.current.breakAt

	2C. ================ Printing Data
				<Part>.config(name)?.asString        	--> String
				   \>		>'
				specific part, and then its parents
				controller[key] as? Int					<-- **doc.config


3. ======== HELPERS ============================================================
	3A. ================ *** FwConfig Access: Named, Typed access to _ANY_  hash:
		1. supports special "super" key
		2. defaults to shared doc.config
		3.
			 <FwConfig>.int(name)   .int_(name)	("ppXYZWena")
				 .float(name) .float_(name)	("ppFloatA" )
			.string(name).string_(name)     ("ppFloatB" )
				  \>             >'
				self.lookup(key) as? Int ??
		 	     controller[key] as? Int   				<-- ***doc.config
	3B. ================ *** Casting FwAny to known Class
		<FwAny> .asString   ?? "" 		.asString_
				.asBool     ?? false	.asBool_
				.asInt      ?? 0		.asInt_
				.asFloat    ?? 0.0		.asFloat_
				.asCGFloat  ?? 0.0		.asCGFloat_
				.asColor    ?? .purple	.asColor_
				.asFwConfig ?? [:]		.asFwConfig_
				 as? [String]													*/

