// SoundAtom.mm -- an Atom to connect to Generators C2014PAK
/*
	  Ports:
		 S	             S
			         ----o----
			  .-----|L|     in|-----.
			  [      ^       |      ]
sound:		  [      |       |      ]
			  [sound |       |      ]
			  [    ^\|       |      ]
			  '-----|in     |L|-----'
				     ----o----
		 P			     P
 */
import SceneKit

class SoundAtom : Atom {

	 // MARK: - 2. Object Variables:
	var sound 	: String? 		= nil
	var playing	: Bool			= false

	 // MARK: - 3. Part Factory
	override init(_ config:FwConfig = [:]) {

		super.init(config)	//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

		if let snd				= localConfig["sound"] as? String {
			sound				= snd
			localConfig["sound"] = nil
		}
	}
	 // MARK: - 3.1 Port Factory
	override func hasPorts() -> [String:String]	{
		var rv					= super.hasPorts()
		rv["S"]					= "af"
		return rv
	}

	 // MARK: - 3.5 Codable
	enum SoundAtomKeys: String, CodingKey {
		case sound
		case playing
	}
	 // Serialize
	override func encode(to encoder: Encoder) throws  {
		try super.encode(to: encoder)
		var container 			= encoder.container(keyedBy:SoundAtomKeys.self)

		try container.encode(sound,   forKey:.sound)
		try container.encode(playing, forKey:.playing)
		atSer(3, logd("Encoded  as? SoundAtom   '\(fullName)'"))
	}
	 // Deserialize
	required init(from decoder: Decoder) throws {
		try super.init(from:decoder)
		let container 			= try decoder.container(keyedBy:SoundAtomKeys.self)

		sound	 				= try container.decode(String.self, forKey:.sound)
		playing	 				= try container.decode(  Bool.self, forKey:.playing)
		atSer(3, logd("Decoded  as? SoundAtom  named  '\(name)'"))
	}
	 // MARK: - 3.6 NSCopying				// ## IMPLEMENT!
	 // MARK: - 3.7 Equitable
	func varsOfSoundAtomEq(_ rhs:Part) -> Bool {
		guard let rhsAsSoundAtom	= rhs as? SoundAtom else {	return false	}
		return   sound == rhsAsSoundAtom.sound
			&& playing == rhsAsSoundAtom.playing
	}
	override func equalsPart(_ part:Part) -> Bool {
		return	super.equalsPart(part) && varsOfSoundAtomEq(part)
	}

	// MARK: - 4.1 Part Properties
	func apply(prop:String, withVal val:String) -> Bool {

		if prop == "sound" {			// e.g. "sound:di-sound" or
			panic("Must debug! old code was:")
			self.sound			= val		//sound's val must be string
			return true						// found a spin property
		}
		return super.apply(prop:prop, withVal:val)
	}

	 // MARK: - 8. Reenactment Simulator
	override func simulate(up:Bool)  {
		super.simulate(up:up)
		let pPort				= ports["P"] ?? .error
		let sPort				= ports["S"] ?? .error

		if up {						// /////// going UP /////////

			if let pPortCon 	= pPort.connectedTo,
			  pPortCon.valueChanged() {			// Input = other guy's output
				let (val, valPrev) = pPortCon.getValues()	// Get value from S
//				let v1 = val, v2 = valPrev 

				sPort.take(value:val)			// Pass it on to P

				 // Rising edge starts a Sound
				if val>=0.5 && valPrev<0.5 { 	// Rising Edge +
					atDat(4, logd("starting sound '\(self.sound ?? "-")'"))
					
//					AppDel.appSounds.play(sound, onNode:)
//					if sObj.isPlaying {
//						print("\n\n NOTE: Going TOO FAST\n\n")
//					}
//					 // If this terminates the previous sound, it's okay!
//panic()//			sObj.play						// start playing sound
//					playing 	= true;				// delay loading primary.L
				}
			}
		}
		if !up {					// /////// going DOWN ////////////
			if let sPortIn		= sPort.connectedTo,
			  sPortIn.valueChanged() {
				pPort.take(value:sPortIn.getValue())
			}
		}
		return;
	}
	 // MARK: - 9.0 3D Support
	func colorOf(ratio:Float) -> NSColor {	return .orange						}
	 // MARK: - 9.4 rePosition
	override func rePosition(portVew vew:Vew) {
		let port				= vew.part as! Port
		if port == ports["S"] {			// P: Primary
			vew.scn.transform	= SCNMatrix4(0, 2 + port.height, 0, flip:true)
		}
		else {
			super.rePosition(portVew:vew) 
		}
	}

	 // MARK: - 15. PrettyPrint
	override func pp(_ mode:PpMode?, _ aux:FwConfig) -> String	{
		var rv 					= super.pp(mode, aux)
		if mode ==  .line {
			if let s			= sound {
				rv 				+= " sound:'\(s)'"
			}
			if playing {
				rv				+= "playing"
			}
			assert(!(playing && sound != nil), "should not be!!!");
		}
		return rv
	}
}
