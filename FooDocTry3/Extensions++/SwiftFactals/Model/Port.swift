//  Port.swift -- Two Ports connect Atoms bidirectionally C2018PAK

import SwiftUI
import SceneKit
/* *********************** _IN_ATOM_ Usage:
										   *-origin	(at top of Port
	^ opensUp = true			 		__/ \__
	| FLIPPED			 		Port:  / L		\
	  (flipped = true)			   ===== top of Atom ====
								 ((		   				 ))
								 ((		   Atom			 ))
								 ((		   				 ))
								   == bottom of Atom ====
	| opensUp = false			Port:  \__   L_/
	v UNFLIPPED	 						  \ /
	  (flipped = false)					   *-origin (at bottom of Port)

 ***********************  _DATA_PASSING_ (up and down)
 							  (( Atom's Computation  ))
			 	INPUT		  ((	INPUT    OUTPUT  ))		OUTPUT
	Atom	 	^	v		  ((	\^^^/    \vvv/   ))		   |
				|	|		    \	 \^/      \v/   /		   v
				|	|		     |	  ^	      PREV,|	  take(value:)
	 Port		|	|		     |____|_______VALUE|L	  getValues()
		 		|	|			 '   /|\ \   /  |  '		 ^-->-v
		 		|	|			      |   \ /   |			 |	  |
				| connectedTo		  |	   *	|	  connectedTo |
				|   |				  |   / \   |			 |	  |
				^___v			 .____|__/   \_\|/_.		 |	  |
	 Port	 getValue() 		L|VALUE,		|  |		 |	  |
			 take(value:)   	 |PREV			A  |		 |	  |
	 			  ^				/	 /^\	   /v\  \  		 ^	  v
	Atom		OUTPUT		  ((	/^^^\	  /vvv\	 ))		 INPUT

  ********************* _VISUAL_ Form:
	flipped	= false					 |    Port   |
	opensUp	= false					 '----   ----'
										  \ /
										   *--- origin (marked as truncated cone)
 */


 /// Defines port protocol for both 1-bit Ports and named MultiPort's
protocol PortTalk {
	  /// - Receives values set by the far Port
	 /// - Parameter value: ---- to set in
	/// - Parameter key: ---- nil if regular Port, sub-name if Multi-Port
	func take(value : Float, key:String?)			// sets value, usually in self

	 /// Read value from other, advancing previous value after get
	/// - Parameter key: --- if MultiPort, Port's name else nil
	func valueChanged(key:String?) -> Bool

	  /// Get new value, save current as prev .:. it's set to unchanged
	 /// * N.B: "getter" with side effect! 
	/// - Parameter key: --- if MultiPort, Port's name else nil
	func getValue(key:String?) -> Float				// get current value

	  /// Get new value and previous one, save current as prev .:. it's set to unchanged
	 /// * N.B: "getter" with side effect! 
	/// - Parameter key: --- if MultiPort, Port's name else nil
	func getValues(key:String?) -> (Float, Float)	// get (current value, previous value)
}

class Port : Part, PortTalk {

	 // MARK: - 2. Object Variables:
	  // MARK: - 2.1 ACTIVATION LEVELS
	 // ////////////////////////////////////////////////////////////////////////
	/*	210118PAK:
	Asynchronoush changes to model do not update value in inspector.
	No redraw. Redraw from another button does update it.
	*/

	@Published var value 		: Float	= 0.0
	{	didSet {	if value != oldValue {
						markTree(dirty:.paint)
																		}	}	}
	@Published var valuePrev	: Float	= 0.0		// @objc dynamic
	{	didSet {	if valuePrev != oldValue {
						markTree(dirty:.paint)
																		}	}	}
	func take(value newValue:Float, key:String?=nil) {
		assert(key==nil,		"Key mode only supported on MPort, not on Port"	)
		assert(!newValue.isNaN,		"Setting Port value with NAN"				)
		assert(!newValue.isInfinite, "Setting Port value with INF"				)

		 // set our value.  (Usually done from self)
		if value != newValue {
			atDat(3, logd("<=_/  %.2f (was %.2f)", newValue, self.value))
			 //*******//
			value 				= newValue
			 //*******//
			markTree(dirty:.paint)					// repaint myself
			connectedTo?.markTree(dirty:.paint)		// repaint my other too
			root!.simulator.kickstart = 4			// start simulator after Port value changes
		}
	}
	func valueChanged(key:String?=nil) -> Bool {
		assert(key==nil, "key mode not supported")
		return valuePrev != value
	}
	   /// get new value, save current as prev .:. it's set to unchanged
	  /// - N.B: getter with side effect!
	func getValue(key:String?=nil) -> Float {
		assert(key==nil, "key mode not supported")
		if valueChanged() {
			atDat(3, logd(">=~.  %.2f (was %.2f)", value, valuePrev))
		}
		 // mark value taken
		if valuePrev != value {			// Only do this on a change, so debug easier
			valuePrev 			= value		// returning the inValue promotes it to the previous
		}
		return value
	}
	   /// get new value, save current as prev .:. it's set to unchanged
	  /// - N.B: getter with side effect!
	func getValues(key:String?=nil) -> (Float, Float) {
		assert(key==nil, "key mode not supported")
		if valueChanged() {
			atDat(3, logd(">=~.  %.2f (was %.2f)", value, valuePrev))
		}
		 // mark value taken
		let prevValuePrev 		= valuePrev
		valuePrev 				= value// returning the inValue promotes it to the previous
		return (value, prevValuePrev)
	}
	 // Design Note: uses [()->String]: efficient, allows count or
	override func unsettledPorts() -> [()->String] {
		let portChanged			= self.connectedTo != nil &&	// Connected Port
								  self.value != self.valuePrev	// Value changed
		return !portChanged ? [] :
				[{ fmt("\(self.fullName)%.2f->%.2f, ", self.value, self.valuePrev) }]
	}

	 // maintain consistent with Atom's ports[]
	override var name		: String {
		get {
			let name			= super.name			// get Part's name
			return name
		}
		set(newName) {
			if var p			= atom?.ports {		// Set Atom's ports
				let oldName		= super.name
				let (oldName2, _) = p.first(where: { $1 == self }) ?? ("", self)
				assert(oldName == oldName2, "inconsistency")
				p.removeValue(forKey:oldName)		// remove from old hash
				p[newName]		= self					// add    to   new hash
			}
			super.name			= newName			 // Set name
		}
	}
	override var fullName	: String {
		return (parent?.fullName ?? "") + "." + name
	}

	 // MARK: - 2.2 Connections:
	weak var connectedTo : Port? = nil			// visible inside SF
//	{	didSet { con2ib = connectedTo ?? con2ib				}					}
	var con2asStr : String?		= nil

	var con2ib : Port {//= self//Port()
		get 	{ return  connectedTo ?? self									}
		set(v)	{ connectedTo 	= v												}
	}
	func connect(to:Port) {
		assert(self.connectedTo==nil, "Port '\(pp(.fullName))' "
			+ "already connected to \(connectedTo?.pp(.fullName) ?? "?")")
		assert(  to.connectedTo==nil, "'\(pp(.fullName))' -connecting to-) '\(to.pp(.fullName))' "
			+ "FAILS; the latter is already connected to '\(to.connectedTo?.pp(.fullName) ?? "?")'")
		self.connectedTo		= to
		to.connectedTo			= self
	}

	 // MARK: - 2.3 Connection Properties:
	var noCheck					= false			// don't check up/down
	var dominant				= false 		// dominant in positioning

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {
		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
		 /// Flipped
		if let portProp 		= config["portProp"] as? String {
			flipped				^^=  portProp.contains(substring:"f")
		}				// f:1 ^^ portProp:"xx f yy"
		 /// Illegal on Port
		assert(config["jog"]==nil,   "Jog not allowed on Ports")
		assert(config["spin"]==nil, "Spin not allowed on Ports")
	}

	 // MARK: - 3.5 Codable
	enum PortsKeys: String, CodingKey {
		case valuePrev
		case value
		case connectedTo
		case con2asStr
		case noCheck
		case dominant
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:PortsKeys.self)

		try container.encode(valuePrev,	 forKey:.valuePrev)
		try container.encode(value,		 forKey:.value)
		assert(connectedTo==nil, "Must searialize virtualized Ports")
		try container.encode(connectedTo,forKey:.connectedTo)
		try container.encode(con2asStr,	 forKey:.con2asStr)
		try container.encode(noCheck,	 forKey:.noCheck)
		try container.encode(dominant,	 forKey:.dominant)

		atSer(3, logd("Encoded  as? Port        '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:PortsKeys.self)

		value 					= try container.decode(  Float.self, forKey:.value)
		valuePrev				= try container.decode(  Float.self, forKey:.valuePrev)
		connectedTo				= try container.decode(Port?.self,forKey:.connectedTo)
		assert(connectedTo==nil, "Must searialize virtualized Ports")
		con2asStr				= try container.decode(String?.self, forKey:.con2asStr)
		noCheck 				= try container.decode(   Bool.self, forKey:.noCheck)
		dominant				= try container.decode(   Bool.self, forKey:.dominant)

		let msg					= "value:\(value.pp(.line))," 				+
							 	  "valuePrev:\(valuePrev.pp(.line)), " 		+
								  "conTo:\(connectedTo?.fullName ?? "nil")"
		atSer(3, logd("Decoded  as? Port       \(msg)"))
	}
	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : Port		= super.copy(with:zone) as! Port
		theCopy.value			= self.value
		theCopy.valuePrev		= self.valuePrev
		theCopy.connectedTo		= self.connectedTo
		theCopy.con2asStr		= self.con2asStr
		theCopy.noCheck			= self.noCheck
		theCopy.dominant		= self.dominant
		atSer(3, logd("copy(with as? Actor       '\(fullName)'"))
		return theCopy
	}
	 // MARK: - 3.7 Equitable
	func varsOfPortEq(_ rhs:Part) -> Bool {
		guard let rhsAsPort		= rhs as? Port else {		return false		}
		return	 value     == rhsAsPort.value
			&& 	 valuePrev == rhsAsPort.valuePrev
			&& connectedTo == rhsAsPort.connectedTo
			&&   con2asStr == rhsAsPort.con2asStr
			&&     noCheck == rhsAsPort.noCheck
			&& 	  dominant == rhsAsPort.dominant
	}
	override func equalsPart(_ part:Part) -> Bool {
		//let rv				= (self as Part).equalsPart(part) && varsOfPortEq(part)
		 // DOES NOT WORK: calls itself
		return	super.equalsPart(part) && varsOfPortEq(part)
	}
	
	 // MARK: - 4.4 Navigation
	var atom 		: Atom? {	return parent as? Atom 							}
	var otherPort 	: Port? {	 // Assumes Atom has 2 Ports, named P and Q
		if let myLink			= parent as? Link,
			myLink.ports[name] == self,
			let otherName : String? = name == "P" ? "S" : name == "S" ? "P" : nil {
				return myLink.ports[otherName!]!
		}
		return nil
	}
	 /// Return the first Port connected to non-link, starting at this one.
	var portPastLinks : Port? {		
		var scan : Port?		= self;				  // ATOM]o - o[P1 link P2]o - o[
		while let p1			= scan?.connectedTo,// self-^		     self-^ rv-^
		  let _					= p1.parent as? Link {
			scan 				= p1.otherPort
		}
		return scan?.connectedTo
	} 

	   /// Return the first Port connected to non-link, starting at this one.
	  /// - Parameter rv: A string describing the links traversed: e.g: "->b->c"
	 /// - Returns: The Port found
	func portPastLinksPp(ppStr rv:inout String) -> Port {
		 // Trace out Links, till some non-Link (including nil) is found
		var scan :Port			= self		      //scan]o -- o[P1 link P2]o -- o[
		while let p1			= scan.connectedTo, // -------'     /     /|\
		  let link				= p1.parent as? Link {  // --------'       |
			scan				= p1.otherPort ?? {       // scan----------'
				fatalError("Malformed Link: could not find otherPort")			}()
			let linkPName 		= p1.name
			let linkName 		= link.name
			rv		 			+= " ->\(linkName).\(linkPName)"
		}
		return scan
	}
	   // MARK: - 4.8 Matches Path
	override func partMatching(path:Path) -> Part? {

		 // Port name matches
		guard path.portName == nil ||			// portName specified in Path?
		   path.portName! == name else {		  // matches?
			return nil								// no, mismatch
		}
		 // Is Port known to Atom, with portName?
		if let atom				= parent as? Atom {
			 // Path has portName
			if let pathPortName	= path.portName {
				 // Is registered in atom's ports?
				if atom.ports[pathPortName] != nil {
				}									// registered in ports
				 // Port is defined in bindings
				else if let bindingName = atom.bindings?[pathPortName] {// is in bindings:
					let bindingPath	= Path(withName:bindingName)	// Path for binding
					if find(path:bindingPath) == nil {				// exists in self
						return nil
					}
				}else{	// Port is unknown
					return nil
				}
			}
			let atomPath		= path 			// make a path for Atom
			atomPath.portName 	= nil			// ignore
			if atom.partMatching(path:atomPath) != nil {
				return self
			}
		}
		return nil								// failed test
	}
	  
	//	- -	- -	BBox+-------------------------------+ - - - - CenterYTop
	//				|								|
	//				|   <origin> .					|
	//			   	|			  \					|
	//				|		      <center>			|
	//				| KEEPOUT	     | radius		|
	//	- - - - - -	+-------.        | 		  .-----+ - - - - CenterYBottom
	//				 GO-ZONE \ 		 |		 /__
	//						  --__   |   __--|\
	//							  ---^---		\
	//											  \		  (PRESUMES flipped	= false,
	//						   O P E N I N G    Link\ 				opensUp	= false)
	//
	 /// Connection Spot
	 /// - All in my Atom's (parent's) coordinate systems:
	struct ConSpot {			// 	
		var center  : SCNVector3	// link aims toward center
		var radius  : CGFloat		// link end stays this distance from center
		var exclude : BBox?			// link end must not stop inside this bBox
		init(center:SCNVector3 = .zero, radius:CGFloat=0, exclude:BBox?=nil) {
			self.center			= center
			self.radius			= radius
			self.exclude		= exclude
		}
		mutating func convertToParent(vew:inout Vew) {
			 // Move v (and rv) to v's parent
			let t				= vew.scn.transform	// my position in parent
			center				= t * center
			radius				= abs((t * .uY * radius).y)
			exclude				= exclude==nil ? vew.bBox * t :
								  exclude! * t   | vew.bBox * t
	//		 // HIghest part self is a part of..
	//		let hiPart  		= ancestorThats(childOf:commonVew.part)!
	//		let hiVew 			= commonVew.find(part:hiPart)!					//, maxLevel:1??
	//		let hiBBoxInCom		= hiVew.bBox * hiVew.scn.transform
			vew					= vew.parent!
			atRsi(8, vew.log("--A-- rv:\(pp()) after t:\(t.pp(.short))"))
		}
	 	// MARK: - 15. PrettyPrint
		func pp() -> String {
			return fmt("c:\(center.pp(.short)), r:%.3f, " + "e:\(exclude?.pp(.short) ?? "nil")", radius)
		}
		var description	  	 	: String	{	return "\"\(pp())\""			}
		var debugDescription 	: String	{	return  "'\(pp())'"				}
//		var summary		 	 	: String	{	return  "<\(pp())>"				}
	
		static let zero 		= ConSpot()
		static let nan	 		= ConSpot(center:.nan)
		static let atomic 		= ConSpot(radius:Part.atomicRadius)
	}

	  /// The connection spot of a Port, in it's coordinates (not it's parent Atom's nay more 20200810)
	 /// (Highly overriden)
	func basicConSpot() -> ConSpot {
		return ConSpot(center:SCNVector3(0, -radius, 0), radius:0)
	}
	 /// Convert self.portConSpot to inVew
	func portConSpot(inVew:Vew) -> ConSpot {									//- (Hotspot) hotspotOfPortInView:(View *)refView; {
		var rv	: ConSpot		= basicConSpot()		// in parent's coords
		guard var aPart			= parent else {	fatalError("portConSpot: Port with nil parent")	}
		var aVew : Vew?			= inVew.find(part:aPart, inMe2:true)

		   // H: SeLF, ViEW, World Position
		  // AVew will not exist when it (and its parents) are atomized.
		 // Search upward thru its parents for a visible Vew
		while aVew == nil, 						// we have no Vew yet
		  let aParent			= aPart.parent		// but we have a parent
		{	bug
			atRsi(8, aPart.logd(" not in Vew! (rv = [\(rv.pp())]) See if parent '\(aParent.fullName)' has Vew"))

			 // Move to parent if Vew for slf is not currently being viewed
			aPart				= aParent
			aVew				= inVew.find(part:aPart, inMe2:true)
			rv					= .zero
		}
		guard var aVew 			= aVew else {	panic("No Vew could be found for Part \(self.fullName)) in its parents")
			return rv
		}

		 // Now rv contain's self's portConSpot, in aVewq
		let enaPpWp				= root?.log.params4aux.string("ppViewOptions")?.contains("W") ?? false
		let worldPosition 		= !enaPpWp ? "" :
								"w" + aVew.scn.convertPosition(rv.center, to:rootScn).pp(.short) + " "		// wp wrong
		atRsi(8, aVew.log("INPUT spot=[\(rv.pp())]\(worldPosition). OUTPUT to '\(inVew.pp(.fullName))'"))

		  // Move vew (and rv) to vew's parent, hopefully finding refVew along the way:
		 //
		let trunkScn			= root!.fwDocument!.fwScene!.trunkScn
		repeat {			//.transform	// my position in parent
			let activeScn		= aVew.scn.physicsBody==nil ? aVew.scn
														    : aVew.scn.presentation
			let t				= activeScn.transform
			rv.center			= t * rv.center			// (SCNVector3)
			rv.radius			= length(t.m3x3 * .uY) * rv.radius	// might be scaling
			rv.exclude			= rv.exclude==nil ? aVew.bBox * t :
								 (rv.exclude! * t | aVew.bBox * t)
			let wpStr 			= !enaPpWp || trunkScn==nil ? "" :
								"w" + aVew.scn.convertPosition(rv.center, to:trunkScn).pp(.short) + " "
			guard aVew.parent != nil else {
				break															}

			aVew					= aVew.parent!
			atRsi(8, aVew.log("  now spot=[\(rv.pp())]\(wpStr) (after \(t.pp(.phrase)))"))
		} while aVew != inVew			// we have not found desired Vew		// // HIghest part self is a part of..	From Long Ago...
																				//let hiPart  			= ancestorThats(childOf:commonVew.part)!
		return rv																//let hiVew 			= commonVew.find(part:hiPart)!
	}																			//let hiBBoxInCom		= hiVew.bBox * hiVew.scn.transform

	   /// Find the Peak Spot of me (my Vew) in vew
	  /// - Parameter inVew: -- coordinate system of returned point
	 /// - Returns: Point to connect to
	/// :H: InCommon
	func peakSpot(inVew:Vew, openingUp:Bool) -> SCNVector3 {
																				//bool dn = (openingUp =) [self downInPart:commonView.part];
		assert(inVew.part !== self, "Vew must contain self's Vew, not be it")
//		assert(inVew.part != self, "Vew must contain self's Vew, not be it")
		let spotIC				= portConSpot(inVew:inVew)					//Hotspot hs = [self hotspotOfPortInView:commonView];
		var rv					= spotIC.center
		let exclude				= spotIC.exclude
		if openingUp {		// want largest upper value:
			rv.y				+= spotIC.radius	// assume straight up
			rv.y				= max(rv.y, exclude?.max.y ?? rv.y)	// Exclude zone too?
		}else{				// want smallest lower value:
			rv.y				-= spotIC.radius	// assume straight down
			rv.y				= min(rv.y, exclude?.min.y ?? rv.y) // Exclude zone too?
		}
		atRsi(8, inVew.log("rv:\(rv.pp(.short)) returns peakSpot"))
		return rv
	}

	 // MARK: - 5 Groom
	override func groomModel(parent parent_:Part?, root root_:RootPart?)  {
		super.groomModel(parent:parent_, root:root_)

		 // make sure we are also correctly in our atom's ports[].
		if let a				= self.atom {	// as a Port, our Atom
			if let apn			= a.ports[name], 	// we are registered.
			  apn !== self {
				print("##-##-##-##-## our Atom \(a.fullName) has a Port \(apn.fullName) named \(name), but it's not that")
				a.ports[name]	= self
			}
				// 20210111 Leaf(.port) (an odd case) calls this
			self.parent 	= a						// register
//			if let apn			= a.ports[name]  {	// we are registered.
//				assert(apn === self, "we are registerd as a Port, but under a different name")
//			}
//			else {									// unregistered
//				// 20210111 Leaf(.port) (an odd case) calls this
//				a.ports[name]	= self
//				self.parent 	= a						// register
//			}
		}
	}

	 // MARK: - 8. Reenactment Simulator
	override func reset() {											super.reset()

		value					= 1.0
	}
	 // no specific action required for Ports:
	override func simulate(up upLocal:Bool) {									}

	  // MARK: - 9.1 reVew
	override func reVew(intoVew:Vew?, parentVew:Vew?) {
		let vew					= intoVew						// 1. vew specified
					?? parentVew?.find(part:self, maxLevel:1)	// 2. vew in parent:
					?? addNewVew(in:parentVew)!					// 3. vew created
		assert(vew.part === self, "sanity check")// "=="?
		assert(vew.expose != .invis,  "Invisible not supported!")//atomic//invis//
		markTree(dirty:.size)					// needed ??
		vew.keep				= true				// Mark it's done:
	}

	 // MARK: - 9.3 reSkin
	var height : CGFloat	{ return 1.0	}//1.0  //0.5//0.01//0.5//1.0//2.0//4.0//
	var radius : CGFloat	{ return 1.0	}

	override func reSkin(fullOnto vew:Vew) -> BBox  {		// Ports and Shares
		let scn11 : SCNNode?	= vew.scn.find(name:"s-Port")
		let scn	: SCNNode		= scn11 ?? newPortSkin(vew:vew, skinName:"s-Port")
		let bbox 			 	= scn.bBox()
		return bbox * scn.transform //return vew.scn.bBox()			//scn.bBox()	// Xyzzy44 vsb
	}
	func newPortSkin(vew:Vew, skinName:String) -> SCNNode {
		assert(!(parent is Link), "paranoia")
//		if parent is Link {			// UGLY
//			let rv				= SCNNode(geometry:SCNSphere(radius:0.1))		// the Ports of Links are invisible
//			rv.name				= skinName
//			rv.color0 			= NSColor("lightpink")!//.green"darkred"
//			vew.scn.addChild(node:rv)
//			return rv
//		}
		let r					= radius
		let h0:CGFloat			= 0.04
		let h					= height
		let h2					= height * 0.5
		let ep :CGFloat 		= 0.002

		 // Origin is at bottom, where connection point is // All below origin
	/*								   spin axis
	Disc        _________________________________________________________
	Tube	 B |_|						 \ | /						   |_|
	Cone 								A \|/
										   + Parent's Origin:

				 scnDisc:Disc		scnCone:Cone					scnTube:Tube
		-h0/2-ep   ep  		  		    ep							  ep/2
			.->+  .-->.<PORT......\.......-->....../	  .->+		 .-->...
			|  '->+.h0..SKIN....+======= | =============* |	 |h2/2-ep|..^...
		h	|	  '-->..ORIGIN>.|...\....|.^...../		| |	 v------>+ h2/2-ep
			| 		 			|  .---->+h-2*ep		| |		x	 |..v...
			|					|  |  \..|.v.../		| |			 '-->...
	 <VIEW's|		   -scnDiskY|  |h/2\.|..../-scnDiskY| |+h
	 ORIGIN>+					'->+	\'-+>/			v-*
	 */
		
		let geom				= SCNCylinder(radius: 0.9*r, height:h0)	// elim tear with ring
		let scnDisc				= SCNNode(geometry:geom)
		scnDisc.name			= skinName
		vew.scn.addChild(node:scnDisc)
		let scnDiskY			= h - h0/2 - ep		// top is at h
		scnDisc.position.y 		= scnDiskY
		scnDisc.color0 			= NSColor("lightpink")!//.green"darkred"

		 // A: Cone's tip marks connection point:
		let geomCone			= SCNCone(topRadius:r/2, bottomRadius:r/5, height:h-2*ep)
		let scnCone 			= SCNNode(geometry:geomCone)
		scnDisc.addChild(node:scnCone, atIndex:0)
		scnCone.name			= "s-Cone"
		scnCone.position.y 		= h/2 - scnDiskY - ep/2
		scnCone.color0			= NSColor.black

		 // B: Tube visible from afar:
		let geomTube			= SCNTube(innerRadius: 0.8*r, outerRadius:r, height:h2-ep)
		let scnTube				= SCNNode(geometry:geomTube)
		scnDisc.addChild(node:scnTube, atIndex:0)
		scnTube.name			= "s-Tube"
		scnTube.position.y 		= h - scnDiskY - h2/2 - ep
		scnTube.color0			= NSColor.blue

		 // C: 3D Origin Mark (for debug)
//		let scnOrigin			= originMark(size:0.5)
//		scnOrigin.color0 		= NSColor.black
//		scnOrigin.position.y 	= -scnDiskY
//		scnOrigin.isHidden		= true
//		scnDisc.addChild(node:scnOrigin)

		return scnDisc
	}
	 // MARK: - 9.2 reSize
//	override func reSize(inVew vew:Vew) {
//		super.reSize(inVew:vew)
//		panic("Port.reSize")
//	}
	 // MARK: - 9.4 rePosition
	override func rePosition(vew:Vew, first:Bool=false) {
bug;	(parent as? Atom)?.rePosition(portVew:vew)	// use my parent to reposition me (a Port)
		vew.scn.transform		= SCNMatrix4(0, -height/2, 0, flip:flipped)/// lone Port
	}
	 // MARK: - 9.5: RePaint:
	override func rePaint(on vew:Vew) {
				// Tube with connectedTo's value:
		let tube				= vew.scn.find(name:"s-Tube", maxLevel:2)
		let  curTubeColor0		= tube?.color0
		let     tubeColor0	 	= upInWorld ? NSColor.green : .red
		tube?.color0			= NSColor(mix:NSColor.whiteX, with:value, of:tubeColor0)
		if tube?.color0 != curTubeColor0 {
			vew.scn.play(sound:value>0.5 ? "tick1" : "tock0")
		}
				// Cone with connectedTo's value:
		let cone				= vew.scn.find(name:"s-Cone", maxLevel:2)
		if let val				= connectedTo?.value {		//	GET to my INPUT
			let     coneColor0	= upInWorld ? NSColor.red : .green
			cone?.color0		= NSColor(mix:NSColor.whiteX, with:val, of:coneColor0)
		}
		else {	// Cone unconnected
			cone?.color0		= .black
		}
	}
	static var alternate = 0

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		switch mode! {
		case .fullName:						// -> .name
			return (parent?.pp(.fullName) ?? "") + "." + name
//			return super.pp(mode, aux)			//return self.fullName//pp(.name,   aux)
		case .phrase, .short:
			return self.pp(.fullNameUidClass, aux)
		case .line:
			// e.g: "Ff| |/            P:Port  . . . o| <0.00> -> /prt4/prt2/t1.s0
			var rv				= ppUid(self, post:"", aux:aux)
			rv					+= (upInWorld ? "F" : " ") + (flipped ? "f" : " ")
//log("")
			rv 					+= root?.log.indentString(minus:1) ?? "//AX//"
			rv					+= self.upInWorld 	? 	"|/   " : 
								   						"|\\   "
			rv					+= ppCenterPart(aux)	// adds "name;class<unindent><Expose><ramId>"
			if aux.bool_("ppParam") {		// when printing parameters
				return rv						// stop normal stuff
			}
			rv 					+=  ppPortOutValues() + ">"

			  // Print out the non-Link:
			 // If we are connected to anything, what is it sending to us
			if let con2			= connectedTo {
				rv 				+= "<" + con2.ppPortOutValues()
				let sc			= portPastLinksPp(ppStr:&rv)
				 // now, the last good port:
				rv 				+= " ->\(sc.connectedTo?.fullName ?? "nil")"
			}else{
				rv 				+= "nil"
			}
			rv					+= con2asStr == nil || connectedTo == nil ? "" : " ???:"
			rv					+= con2asStr == nil ? "" : " \"\(con2asStr!)\" "
			return rv
//			  // Print out the non-Link:
//			 // If we are connected to anything, what is it sending to us
//			if connectedTo==nil {
//				return rv + "-nil"
//			}
//			rv 					+= "<" + connectedTo!.ppPortOutValues()
//			let sc				= portPastLinksPp(ppStr:&rv)
//
//			 // now, the last good port:
//			return rv + " ->\(sc.connectedTo?.fullName ?? "nil")"

		default:
			return super.pp(mode, aux)
		}
	}
	func ppPortOutValues() -> String {		// return self.[prev]val
		let before 				= valuePrev ~== value ? "" : fmt("/%.2f", valuePrev)
		return fmt("%.2f%@", value, before)
	}

	 // MARK: - 16. Global Constants
	static let error			= Port()	// Should (?) print error if ever touched
	static let reservedPortNames = [ "P", "S", "T", "U", "B", "KIND", "share"]

	 // MARK: - 17. Debugging Aids
	override var description	  : String 	{	return  "\"\(pp(.short))\""	}
	override var debugDescription : String	{	return   "'\(pp(.short))'"		}
//	override var summary		  : String	{	return   "<\(pp(.short))>"		}

//	 // MARK: - 19. Inspector SwiftUI.View
//	class var body : some View {
//		Text("Part.body lives here")
//	}
}

class ParameterPort : Port {
// TODO: rename GlobalPort

}


