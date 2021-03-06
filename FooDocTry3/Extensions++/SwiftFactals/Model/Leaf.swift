// Leaf.swift -- Terminal element of a FwBundle C2015PAK

import SceneKit

// A Leaf is both:
//		The mechanism for a bit in some FwBundle in the machine
//		A prototype for making said mechanisms
// N.B: There is an inherent circularity in this definition:
// 181011:	1. Factory explicitly makes any kind of Part, we use it for Leafs in Bundles

/* ?? Find Home
	Access Ports:
		P	Primary Port of Atom
		S	Secondary Port of Atom
		T	Terciary, TimeDel, ...
		M	Mode
		L	Latch
 */

 /// A Leaf is a functional terminal of a FwBundle
class Leaf : FwBundle {			// perhaps : Atom is better 200811PAK
	 // MARK: - 2. Object Variables:
	var type : String 				 = "undefined"	// for printout/debug

	 // MARK: - 3. Part Factory
//	convenience init(_ leafKind:LeafKind, fwConfig:FwConfig=[:], bindings:FwConfig=[:], parts:[Part]) { // NEW WAY
	convenience init(of leafKind:LeafKind, bindings:FwConfig=[:], parts:[Part], fwConfig:FwConfig=[:]) { // OLD WAY
		let xtraConfig:FwConfig = ["parts":parts, "bindings":bindings]		// /*"type":type,*/ 
		self.init(leafKind:leafKind, fwConfig + xtraConfig) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
	}
	    /// Terminal element of a FwBundle
	   /// - parameter leafKind: -- of terminal Leaf
	  /// - parameter config_: -- to configure Leaf
	 /// ## --- bindings: FwConfig -- binds external Ports to internal Ports by name
	init(leafKind:LeafKind? = .genAtom, _ config_:FwConfig=[:]) {//override
		let config				= ["placeMy":"linky"] + config_
		super.init(of:leafKind!, config)//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		type					= leafKind!.rawValue
	}
	 // MARK: - 3.5 Codable
	enum LeafsKeys: String, CodingKey {
		case type
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:LeafsKeys.self)

		try container.encode(type, 		forKey:.type)
		atSer(3, logd("Encoded  as? Leaf        '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 		= try decoder.container(keyedBy:LeafsKeys.self)

		type	 			= try container.decode(String.self, forKey:.type)
		atSer(3, logd("Decoded  as? Leaf       named  '\(name)'"))
	}
	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : Leaf		= super.copy(with:zone) as! Leaf
		theCopy.type			= self.type
		atSer(3, logd("copy(with as? Leaf       '\(fullName)'"))
		return theCopy
	}
	 // MARK: - 3.7 Equitable
	func varsOfLeafEq(_ rhs:Part) -> Bool {
		guard let rhsAsLeaf		= rhs as? Leaf else {	return false			}
		return true
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfLeafEq(part)
	}

	// MARK: - 4.1 Part Properties
	override func apply(prop:String, withVal val:FwAny?) -> Bool {
		 // Leafs get sound names from the .nib file:
		if prop == "sound" {	// e.g. "sound:di-sound" or
			if let sndPPort		= port(named:"SND"),
			  let sndAtom		= sndPPort.atom as? SoundAtom,
			  let v				= val as? String {
				sndAtom.sound	= v
			}
			else {
				panic()
			}
		}
		return super.apply(prop:prop, withVal:val)
	}
	 // MARK: - 4.5 Iterate (forAllLeafs)
	override func forAllLeafs(_ leafOperation : LeafOperation)  {
		leafOperation(self)
	}
	 // MARK: - 9.2 reSize
	override func reSize(inVew vew:Vew) {
		super.reSize(inVew:vew) //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
		 // Minimum Size:
		if let ms				= minSize {
			vew.bBox.size		|>= ms
		}
	}
	 // MARK: - 9.3 reSkin
	override func reSkin(fullOnto vew:Vew) -> BBox  {
		let scn					= vew.scn.find(name:"s-Leaf") ?? {
			let scn				= SCNNode()
			vew.scn.addChild(node:scn, atIndex:0)
			scn.name			= "s-Leaf"
			return scn
		}()

		 /// Purple Ring at bottom:
		let bb					= vew.bBox		// | BBox(size:0.5, 0.5, 0.5)
		let gsnb				= vew.config("gapTerminalBlock")?.asCGFloat ?? 0.0
		// thrashes:
		let bbs					= bb.size
		scn.geometry 			= SCN3DPictureframe(width:bbs.x, length:bbs.z, height:gsnb, step:gsnb) //SCNPictureframe(width:bb.size.x, length:bb.size.z, step:gsnb)//bb.size.x/2)//0.1) //*gsnb/2)
		scn.position			= bb.centerBottom //+ .uY * gsnb
		scn.color0				= .red
		return bb						// vew.scn.bBox()//scn.bBox()// Xyzzy44 ** bb
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv 				= super.pp(mode, aux)
		if mode == .line {
			if aux.bool_("ppParam") {			// Ad Hoc: if printing Param's,
				return rv							// don't print extra
			}
			rv				+= "type:.\(type) "	// print type and bindings:
		//	rv				+= "bindings:\(bindings.pp(.line)) "
		}
		return rv
	}
}
