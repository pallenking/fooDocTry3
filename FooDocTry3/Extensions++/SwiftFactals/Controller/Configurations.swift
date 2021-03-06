//  Configurations.swift -- Configure Factal Workbench ©2019PAK

import SceneKit

// Default constants used to configure the 6 sub-system of Factal Workbench:
//		a) Apps, b) App Logs, c) Pretty Print,  d) Doc Log, e) Simulator, f) 3D Scene
// When in XCTest mode, keys with "*" prefix replace their non-star'ed name.

  // MARK: - A: App Params
 /// Parameters globally defined for Application()
private let params4app_ : FwConfig = [
	"soundVolume"	 			: 0.1,		// 0:quiet, 1:normal, 10:loud
	"regressScene"	 			: 189,//162,145,137,132,159,132,82,212,21,19,18,12,	// next (first) regression scene

//			// Omit emptyEntry	: nil,		// nil entry
	"emptyEntry"				: "xr()",	// load test named with xr()
//	"emptyEntry"				: "entry90",//24/12/18/ Scene<n> (or name?) from Library
//	"emptyEntry"				: "<name>",	// Test matching "<name>"

	"*emptyEntry"				: "entry12"	// XCTest
]

  // MARK: - B: Parameters App logging
 // Controls logging of the Application
let docSerBldN					= 8//0/5/8/
private let params4appLog_		= params4logs_ + params4pp_
	+ log(doc:docSerBldN, bld:docSerBldN, ser:docSerBldN)
//	+ log(rve:9, rsi:9, rnd:9, ani:9)
//	+ log(rsi:5)
	+ log(prefix:"*", all:0)  		//! "*" is for XCTest variants

 // MARK: - C: Pretty Print
private let params4pp_ : FwConfig = [
				// What:
	"ppRootOfTree"		: true, 	// trees includes Root (and Trunk)
	"ppLinks"			: false, 	// pp includes Links  //true//
	"ppPorts"			: true, 	// pp includes Ports //false//
	"ppScnMaterial"		: false, 	// pp of SCNNode prints materials (e.g. colors) on separate line
				// Order:
	"ppDagOrder"		: false, 	//true
				// Options:
	"ppParam"			: false,	// pp config info with parts
	"ppViewOptions"		: "UFVSPLETBIW",// Vew Property Letters:	"UFVTBIW""UFVSPLETBIW"
		// "U" for Uid			"L" for Leaf			"W" for World
		// "F" for Flipped		"E" for Expose
		// "V" for Vew(self)	"T" for Transform
		// "S" for Scn			"B" for physics Body
		// "P" for Part			"I" for pIvot
	"ppScnBBox"			: false, 	// pp SCNNode's bounding box	//false//true
	"ppFwBBox"			: true, 	// pp Factal Workbench's bounding box
				// SCN3Vector shortening:
	"ppXYZWena"  		: "XYZW",	// disable some dimensions //"Y"//
				// Column Usage:
	"ppViewTight"		: false, 	// better for ascii text //false//true
	"ppBBoxCols"		: 28,		// columns printout for bounding boxs//32//24
	"ppIndentCols"		: 14,//12/12/8// columns allowed for printout for indentation
	"ppNNameCols"		: 8,		// columns printout for names
	"ppNClassCols"		: 8,		// columns printout for names
	"ppNUid4Tree"		: 3,  //0/3/4/ hex digits of UID identifier for parts 0...4
	"ppNUid4Ctl" 		: 3,  //0//3//4// hex digits of UID identifier for controllers //0
	"ppNCols4Posns"		: 20,		// columns printout for position  //20/18/15/14/./
	"ppNCols4ScnPosn"	: 35,		// columns printout for position  //25/20/18/14/./
				// Floating Point Accuracy:
	 		   // fmt("%*.*f", A, B, x) (e.g. %5.2f)
	//"ppFloatA": 2, "ppFloatB":0,	// good, small
	  "ppFloatA": 4, "ppFloatB":1,	// good, .1, tight printout
//	  "ppFloatA": 5, "ppFloatB":2,	// good, .01 for bug hunting
	//"ppFloatA": 7, "ppFloatB":4,	// BIG,  .0001 ACCURACY
	//"ppFloatA": 4, "ppFloatB":2,
	//"ppFloatA": 5, "ppFloatB":2,
	//"ppFloatA": 3, "ppFloatB":1,
]
 // MARK: -
 // MARK: - D: Parameters Doc Log
private let params4docLog_		= params4logs_ + params4pp_
	+ log(all:7)					//! (bld:1)/(bld:2)/(all:8)/(all:5)
	+ log(prefix:"*", all:0)		//! 1	// key prefix "*" is for XCTest

	private let breakLogIdIndex		= 3//240/3/0:off
								// + +  + +
	private let breakLogEvNum		= -94
								// + +  + +
	private let params4logs_	: FwConfig = [
		"debugPreLog"		: true,		// Debug setting of logs before there is a Log ()
		"debugOutterLock"	: false,	//true//false// Helpful logging, quite noisy
			 // BreakAt is composite: logId * entryNosPlog + logEvent:
		"breakAt"			: breakLogEvNum<0 ? 0 : breakLogEvNum + breakLogIdIndex * Log.entryNosPlog,
			 // * is for XCTests:
		"*breakAt"			: 0,		// No breaks for XCTest
	]

  // MARK: - E: Sim Params
 /// Parameters for simulation
private let params4sim_ : FwConfig = [
	"simEnabled"				: false,
	"simTaskPeriod" 			: 0.01,//5 1 .05// Simulation task retry delay nil->no Task
	"simTimeStep"				: 0.01,			// Time between UP and DOWN scan (or vice versa)
	"simLogLocks"				: false,//true//false// Log simulation lock activity
]

  // MARK: - F: Scene Params
 /// FwScene Viewing parameters
private let params4scene_ : FwConfig = [
//	"initialDisplayMode"		: "invisible"	// mostly expunged
//	"physics"					: ??
/**/"linkVelocityLog2"			: Float(-5.0),	// link velocity = 2^n units/sec //slow:-6.0

/**/"placeMe"					:"linky",		// place me (self)	//"stackY"
/**/"placeMy"					:"linky",		// place my parts	//"stackY"
///**/"placeMe"					:"stacky",		// place me (self)	//"stackY"
///**/"placeMy"					:"stacky",		// place my parts	//"stackY"
 //	"skinAlpha"					: 0.3,			// nil -> 1
	"bitHeight"					: Float(1.0),	// radius of Port
/**/"bitRadius"					: Float(1.0),	// radius of Port
	"atomRadius"				: Float(1.0),	// radius of Atom
	"factalHeight"				: Float(3.0),	// factal scn height
	"factalWidth"				: Float(4.0),	// factal scn height xx factal scn width/depth/bigRadius
	"factalTorusSmallRad"		: Float(0.5),	// factalTorusSmallRad
//	"bundleHeight"				: Float(4.0),	// length of tunnel taper			*/
//	"bundleRadius"				: Float(1.0),	// radius of post
	
	  // ///  Gap_: USER DEFINITIONS ////////////////////////////////////////////
	 // indent for each layer of FwBundle terminal block:
	"gapTerminalBlock"			: CGFloat([0, 0.04, 0.2]	[2]),	// !=0 --> ^P broken
	 // gap around atom to disambiguate bounding boxes:
	"gapAroundAtom"				: CGFloat([0, 0.01, 0.2]	[0]),	// !=0 --> ^P broken
	 // linear between successive Atoms:
	"gapStackingInbetween"		: CGFloat([0, 0.1,  0.2]	[0]),	// OK
	 // between boss & worker if no link:
	"gapLinkDirect"				: CGFloat(0.1),
	 // min gap between boss and worker, if link:
	"gapLinkFluff"				: CGFloat(1),
	
//	"linkRadius"				: Float(0.25),	// radius of link (<0.2? 1pix line: <0? ainvis
//	"linkEventRadius"			: Float(-1),	// radius of link (<0.2? 1pix line: <0? ainvis
//	"linkDisplayInvisible"		: false,		// Ignore link invisibility
//	"displayAsNonatomic"		: false,		// Ignore initiallyAsAtom marking
	 //////// Ports
//	"signalSize"				: Float(1.0),	// size of bands that display

	 // Animate actions:
	"animatePhysics"			: true,			// Animate SCNNode physics
	"animateChain"				: true, 		// Animate Timing Chain state
//	"animateBirth"				: true,			// when OFF, new elt is in final place immediately
	"animateFlash"				: false, 		//false//
	"animatePan"				: true,			//false//
	"animatePole"				: true,			//false//
	"animateOpen"				: true,			//false//

	"lookAt"					: "",
	"vanishingPoint"			: Double.infinity,
	//"render3DMode"			: render3Dcartoon,
	"picPan"					: false,		// picking object pans it to center
	
	"pole"						: true,			//false//true//
	"poleTics"					: true,			//false//true//

	"camera"					: "",			// so ansConfig overrites
	 // Breaks for debugging:
	"breakAtViewOf"				: "",
	"breakAtBoundOf"			: "",
	"debugOverlapOf"			: "",
	"breakAtRenderOf"			: "",

	 // 11. 3D Display ******** 3D Display
	"displayPortNames"			: true,
	"displayLinkNames"			: true,
	"displayAtomNames"			: true,
	"displayLeafNames"			: false,
	"displayLeafFont"			: false,		// default 0 is no leaf names
	"displayNetNames"			: true,
	"displayLabels"				: true,
	"fontNumber"				: 6,			// default font index; 0 small, 6 big
//	"rotRate"					: Float(0.0003/(2*Float.pi)),
	 // bounding Boxes: default is unneeded

	"wBox"						: "colors",		// "none", "gray", "white", "black", "colors"
]

let wBoxColorOf:[String:NSColor] = [
	"Part"			:NSColor.red,
	 "Port"			:NSColor.red,
	  "MultiPort"	:NSColor.red,
	  "Share"		:NSColor.red,
	 "Atom"			:NSColor.orange,
	  "Net"			:NSColor.purple,
	   "FwBundle"	:NSColor("darkgreen")!,
	    "Tunnel"	:NSColor.green,
	    "Leaf"		:NSColor.red,
	   "Generator"	:NSColor.red,
	  "DiscreteTime":NSColor.red,
	  "TimingChain"	:NSColor.red,
	  "WorldModel"	:NSColor.red,
]

  // MARK: - External linkage
 /// Initial Parameters for configuration:
/// 20211001: only one prefix XCTest:"*" is implemented
/// depend on whether XCTest is running
var params4app		: FwConfig		{	return applyPrefixTo(params4app_	) 	}
var params4appLog	: FwConfig		{	return applyPrefixTo(params4appLog_	) 	}
var params4pp		: FwConfig		{ 	return applyPrefixTo(params4pp_		)	}

var params4docLog	: FwConfig		{	return applyPrefixTo(params4docLog_	) 	}
var params4sim		: FwConfig		{	return applyPrefixTo(params4sim_	) 	}
var params4scene	: FwConfig		{	return applyPrefixTo(params4scene_	) 	}

func applyPrefixTo(_ config:FwConfig) -> FwConfig {

	 // Prefix "*" is for XCTests:
	let prefix					= isRunningXcTests ? "*" : ""

	var rv : FwConfig			= [:]	// rebuild Return Value in this
	for (key, val) in config {
		assert(!(val is Dictionary<String, Any> || val is Array<Any>), "not programmed for recursive yet")

		if let filteredKey		= filterKey(prefix:prefix, key:key),
		  rv[filteredKey] == nil ||		// Never seen the filtered key before or
		  filteredKey != key 			// High-priority (transformed) key
		{
			rv[filteredKey]		= val		// use key
		}
	}
	return rv
}

	  /// Use prefix codes to conditionally include keys
	 /// - Parameters:
	///   - key: if of form <prefix><body> return <body> else return key
   ///   - prefix: operating mode, stripped from keys if present
  /// - Returns: reformed key
 /// e.g: "*abc"
func filterKey(prefix:String, key:String) -> String? {
	for pre in definedParamPrefices {
		if key.hasPrefix(pre) {		// Is Prefix'ed name
			return pre != prefix ? nil :			// prefix mismatch --> drop key
				String(key.dropFirst(pre.count))	// match remove prefix of key
		}
	}
//	if definedParamPrefices.contains(prefix),// legal prefix
//	  key.hasPrefix(prefix) {					// part of key ?
//		return String(key.dropFirst(prefix.count))	// yes, remove prefix of key
//	}
	return key
}

// MARK: - Conditional Configuration Keys
	 // 20210930: Only prefix "*" is supported
	// Configuration Keys starting with "*" will only be in effect
   //   during regression tests (when the "*" is removed)
  //	 All keys starting with (unremoved) "*"'s are ignored
 //       NO Other keys should start with any of these prefices, or there will be unexpected side effects!
var definedParamPrefices : [String] = [
	"*"							// For XCTest
]		
