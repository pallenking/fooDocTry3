//  LinkVew.swift -- Vew for a Link C20200115PAK

import SceneKit

class LinkVew : Vew {

	 // MARK: - 2. Object Variables:
	lazy var  pCon2Vew : Vew	= .null		// Vew to which my Ports are connected
	 lazy var sCon2Vew : Vew	= .null		// dummy values for now
//	var  pEndVip : SCNVector3?	= nil		// H: P END scnVector3 position In Parent coordinate system
//	 var sEndVip : SCNVector3?	= nil		// H: S END scnVector3 position In Parent coordinate system

	 // MARK: - 3. Factory
	override init(forPart part:Part?=nil, scn scn_:SCNNode? = nil, expose expose_:Expose? = nil) {
		super.init(forPart:part, scn:scn_, expose:expose_)
	}
	 // MARK: - 3.5 Codable
	enum LinkVewKeys : CodingKey { 	case pCon2Vew, sCon2Vew, pEndVip, sEndVip	}
	override func encode(to encoder: Encoder) throws {
		try super.encode(to: encoder)											//try super.encode(to: container.superEncoder())
		var container 			= encoder.container(keyedBy:LinkVewKeys.self)
		try container.encode(pCon2Vew, 	forKey:.pCon2Vew 	)
		try container.encode(sCon2Vew,	forKey:.sCon2Vew 	)
		atSer(3, logd("Encoded  as? Path        '\(String(describing: fullName))'"))
	}
	required init(from decoder: Decoder) throws {
		super.init()
		let container 			= try decoder.container(keyedBy:LinkVewKeys.self)
		pCon2Vew				= try container.decode(		   Vew.self, forKey:.pCon2Vew)
		sCon2Vew 				= try container.decode(		   Vew.self, forKey:.sCon2Vew)
 		atSer(3, logd("Decoded  as? Vew       named  '\(String(describing: fullName))'"))
	}
	 // MARK: - 3.6 NSCopying
	override func copy(with zone: NSZone?=nil) -> Any {
		let theCopy : LinkVew		= super.copy(with:zone) as! LinkVew
		theCopy.pCon2Vew			= self.pCon2Vew
		theCopy.sCon2Vew			= self.sCon2Vew
		atSer(3, logd("copy(with as? LinkVew       '\(fullName)'"))
		return theCopy
	}
//	 // MARK: - 3.7 Equitable
//	func varsOfLinkVewEq(_ rhs:Part) -> Bool {
//		guard let rhsAsLinkVew	= rhs as? LinkVew else {	return false		}
//		return pCon2Vew			== rhsAsLinkVew.pCon2Vew
//			&& sCon2Vew			== rhsAsLinkVew.sCon2Vew
//	}
//	override func equalsPart(_ part:Part) -> Bool {
//		return	super.equalsPart(part) && varsOfLinkVewEq(part)
//	}

 // // Links now have a bBox. Print it!
	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{
		var rv			= super.pp(mode, aux)
		if mode! == .line {
			rv				+= " ->\(pCon2Vew.pp(.uid)),\(sCon2Vew.pp(.uid))"
		}
		return rv
	}

	 // MARK: - 17. Debugging Aids
	override var description	  : String 	{ return  "\"\(pp(.short))\""		}
	override var debugDescription : String	{ return   "'\(pp(.short))'"		}
//	override var summary		  : String	{ return   "<\(pp(.short))>"		}
}
