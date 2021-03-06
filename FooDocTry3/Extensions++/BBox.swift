// BBox.swift -- Factal Workbench Bounding Box ©2018PAK

import SceneKit

   /// BBox is used during Placement,
  /// shadows SCN.boundingBox, but with includes only placed views

func == (aBox:BBox, bBox:BBox) -> Bool {
	return aBox.min == bBox.min && aBox.max == bBox.max
}

 /// extend a BBox by another BBox
func + (aBox:BBox, bBox:BBox) -> BBox {
	let min						= aBox.min + bBox.min
	let max						= aBox.max + bBox.max
	return BBox(pair:(max, min))
}
func += ( bBox: inout BBox, aBox:BBox) {
	bBox						= bBox + aBox
}
																				// the above loops infinitely.  It ssems b +
																				//	let orOf 					= bBox | aBox
																				//	bBox						= orOf
 /// extend a BBox so it includes an point
func | (bbox:BBox, point:SCNVector3) -> BBox {
	let min 					= minPerAxis(bbox.min, point)
	let max 					= maxPerAxis(bbox.max, point)
	return BBox(pair:(max, min))
}
func |= ( bbox: inout BBox, point:SCNVector3) {
	bbox 						= bbox | point
}

 /// "_+_" extends size by SCNVector3
func + (bbox:BBox, sizeVect:SCNVector3) -> BBox {
	var rv						= bbox
	rv.size						+= sizeVect
	return rv
}
func += ( bbox: inout BBox, sizeVect:SCNVector3) {
	bbox.size					+= sizeVect
}
// /// "_+_" extends size by CGFloat
//func +  ( bbox: 	  BBox, size:CGFloat) -> BBox {
//	let rv						= bbox + SCNVector3(size, size, size)
//	return rv
//}
//func += ( bbox: inout BBox, size:CGFloat) {
//	bbox.size					+= SCNVector3(size, size, size)
//}


 /// "_*_" scales a FwBBox's size
func * (bbox:BBox, scale:CGFloat) -> BBox {
	var rv						= bbox
	rv.size						*= scale
	return rv
}
func *= (bBox: inout BBox, scale:CGFloat) {
	bBox 						= bBox * scale
}

 /// Biggest BBox encompassing both simultaneously
func & (a:BBox, b:BBox) -> BBox {
	let max 					= minPerAxis(a.max, b.max)
	let min 					= maxPerAxis(a.min, b.min)
	let d						= max - min
	if d.x < eps || d.y < eps || d.z < eps {
		return .empty
	}
	return BBox(pair:(max, min))
}
func &= (a: inout BBox, b:BBox) {
	a 							= a & b
}
 /// Smallest BBox encompassing one or the other
func | (a:BBox, b:BBox) -> BBox {
	let max 					= maxPerAxis(a.max, b.max)
	let min 					= minPerAxis(a.min, b.min)
	return BBox(pair:(max, min))
}
func |= (a: inout BBox, b:BBox) {
	a 							= a | b
}

 /// Transform
func * (bBox:BBox, transform:SCNMatrix4) -> BBox {
	return bBox.transformed(by: transform)
}
func *= (bBox: inout BBox, transform:SCNMatrix4) {
	bBox 						= bBox * transform
}

 /// Approximately Equal
func ~==( left:BBox, right:BBox) -> Bool {
	return left.min ~== right.min && left.max ~== right.max
}

struct BBox : Codable {

         // MARK: - 2. Object Variables:
	public var min 	: SCNVector3
	public var max 	: SCNVector3
	// derrived
	var isEmpty	: Bool   	{
		return min.x >= max.x-eps || min.y >= max.y-eps || min.z >= max.z-eps	}
	var isNan	: Bool 		{ return min.isNan || max.isNan						}
	var size	: SCNVector3 	{
		get {	return max - min
		}
		set(newSize) {
			let deltaSize2	= (newSize - size)/2.0	// for all 3 sides:
			max 			+= deltaSize2			// put   half on one   side
			min 			-= deltaSize2			// other half on other side
		}
	}
	var center	: SCNVector3 	{
		get { return (self.max + self.min)/2.0
		}
		set(newCenter) {
			let deltaCenter	= newCenter - center
			max 			+= deltaCenter
			min 			+= deltaCenter
		}
	}
	var left 	: CGFloat 		 {	return min.x								}
	var right	: CGFloat 		 {	return max.x								}
	var bottom	: CGFloat 		 {	return min.y								}
	var top		: CGFloat 		 {	return max.y								}
	var zNear	: CGFloat 		 {	return min.z								}
	var zFar	: CGFloat 		 {	return max.z								}
	
	//181124 What a bug:
	var centerLeft	 :SCNVector3 { return SCNVector3(min.x, center.y, center.z)	}
	var centerRight  :SCNVector3 { return SCNVector3(max.x, center.y, center.z)	}
	var centerTop	 :SCNVector3 { return SCNVector3(center.x, max.y, center.z)	}
	var centerBottom :SCNVector3 { return SCNVector3(center.x, min.y, center.z)	}
	var centerFront	 :SCNVector3 { return SCNVector3(center.x, center.y, min.z)	}
	var centerBack	 :SCNVector3 { return SCNVector3(center.x, center.y, max.z)	}
	// One of many more to possibly add:
//	var centerYFrontRight:SCNVector3{return SCNVector3(max.x,  center.x, max.z)	}

	func corner(_ i:Int) -> SCNVector3 {
		assert(i<8 && i>=0, "Corner index = \(i) out of range 0..<8")
		return SCNVector3(i&1==0 ? min.x: max.x,  i&2==0 ? min.y: max.y,  i&4==0 ? min.z: max.z)
	}
	func transformed(by transform:SCNMatrix4) -> BBox {	// in transform coorinate system
		let point 			= transform * corner(0)	// first corner
		var bBox			= BBox(point,point)		// make bBox with just that
		for i in 1..<8 {							// add the other 
			let pointI		= transform * corner(i)	
			bBox.max		|>= pointI
			bBox.min		|<= pointI
		}
		return bBox
	}

	 // MARK: - 3. Factory
//	init(of a:SCNNode) {
//		let bBox 			= a.boundingBox
//		self.init(bBox.min, bBox.max)
//	}
	init(pair:(SCNVector3, SCNVector3)) {
		let (a, b) = pair
		self.init(a, b)
	}
	init(size:SCNVector3) {
		self.init(-size/2, size/2)
	}
	init(size sx:CGFloat, _ sy:CGFloat, _ sz:CGFloat) {
		self.init(x:sx/2, -sx/2, y:sy/2, -sy/2, z:sz/2, sz/2)
	}
	init(x:CGFloat, _ bx:CGFloat, y:CGFloat, _ by:CGFloat, z:CGFloat, _ bz:CGFloat) {
		self.init(SCNVector3(x, y, z), SCNVector3(bx, by, bz))
	}
	init(_ a:SCNVector3, _ b:SCNVector3) {
		min					= SCNVector3(a.x <  b.x ? a.x : b.x,
										 a.y <  b.y ? a.y : b.y,
										 a.z <  b.z ? a.z : b.z)
		max					= SCNVector3(a.x >= b.x ? a.x : b.x,
										 a.y >= b.y ? a.y : b.y,
										 a.z >= b.z ? a.z : b.z)
	}

	 // MARK: - 15. PrettyPrint
	func pp(_ mode:PpMode? = .tree, _ aux:FwConfig) -> String	{

		if min.isNan || max.isNan 	{
			return "nan"
		}
		let a 				= aux.int_("ppFloatA")			// %a.bf
		let b 				= aux.int_("ppFloatB")
		let m				= aux.string("ppXYZWena") ?? "XYZ"
		var rv = ""
		switch mode! {
			case .fullName:
				rv 			= "BBox has no name"
			case .phrase:
				if m.contains("X") 	{	rv += fmt("%4.1f<%4.1f", min.x, max.x)	}
				if m.contains("Y") 	{	rv += fmt("%4.1f<%4.1f", min.y, max.y)	}
				if m.contains("Z") 	{	rv += fmt("%4.1f<%4.1f", min.z, max.z)	}
			case .short:
				if m.contains("X") 	{	rv += fmt("%4.1f<%4.1f", min.x, max.x)	}
				if m.contains("Y") 	{	rv += fmt("%4.1f<%4.1f", min.y, max.y)	}
				if m.contains("Z") 	{	rv += fmt("%*.*f<%*.*f", a,b,min.z, a,b,max.z)	}
			case .line:
				if m.contains("X") 	{	rv += fmt("%*.*f<%*.*f, ", a,b,min.x, a,b,max.x)	}
				if m.contains("Y") 	{	rv += fmt("%*.*f<%*.*f, ", a,b,min.y, a,b,max.y)	}
				if m.contains("Z") 	{	rv += fmt("%*.*f<%*.*f, ", a,b,min.z, a,b,max.z)	}
				rv 			= String(rv.dropLast(2))
			case .tree:
				if m.contains("X") 	{	rv += fmt("x: %6.3f < %6.3f\n", min.x, max.x)	}
				if m.contains("Y") 	{	rv += fmt("y: %6.3f < %6.3f\n", min.y, max.y)	}
				if m.contains("Z") 	{	rv += fmt("z: %6.3f < %6.3f\n", min.z, max.z)	}
				rv 			= String(rv.dropLast())
			default:
				panic()
				rv 			= "oops ?23"
		}
		return rv
	}

	 // MARK: - 16. Global Constants
	static let unity 		= BBox(-.unity/2, .unity/2)
	static let empty 		= BBox(SCNVector3.zero, SCNVector3.zero)
	static let nan 			= BBox(SCNVector3.nan,  SCNVector3.nan)

	 // MARK: - 17. Debugging Aids
	var description			:String	{	return "\"\(pp(.short))\""				}
	var debugDescription 	:String	{	return  "'\(pp(.short))'"				}
//	var summary				:String	{	return  "<\(pp(.short))>"				}
}
