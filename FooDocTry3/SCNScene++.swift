//
//  SCNScene++.swift
//  FooDocTry3
//
//  Created by Allen King on 5/25/22.
//

import SceneKit

extension SCNScene {

	 // Get camera node from SCNScene; generate if necessary
	var cameraNode : SCNNode {
		return rootNode.childNode(withName: "camera", recursively: false) ?? {
			groomScene()						// Try a groom once
			return rootNode.childNode(withName: "camera", recursively: false) ?? {
				fatalError("something's amiss")	// Still a problem
			}()
		}()
	}

	 // Add Lights and Camera
	func groomScene() {
		
		 // create and add a light to the scene:
		func addLight(name:String, lightType:SCNLight.LightType, color:Any?=nil, position:SCNVector3?=nil) {
			let newLight 		= SCNNode()
			newLight.name		= name
			newLight.light 		= SCNLight()
			newLight.light!.type = lightType
			if let color		= color {
				newLight.light!.color = color
			}
			if let position		= position {
				newLight.position = position
			}
			rootNode.addChildNode(newLight)
		}
		addLight(name:"light",   lightType:.omni, position:SCNVector3(0, 0, 15))
		addLight(name:"ambient", lightType:.ambient, color:NSColor.darkGray)

		 // Add camera
		let cameraNode 			= SCNNode()
		cameraNode.name			= "camera"
		cameraNode.camera 		= SCNCamera()
		cameraNode.position 	= SCNVector3(0, 0, 15)
		rootNode.addChildNode(cameraNode)
	}
	// FwDocument 
	 // Data in the SCNScene
	var data : Data? {
		let url					= URL(fileURLWithPath:"t1")
		write(to:url, options:nil, delegate:nil, progressHandler:nil)			//URL(string:"xxx")!
		let data				= NSData(contentsOf:url) as? Data				//Data(url:url)		//"String OKAY".data(using:.utf8)!
		//fatalError("debug me")
		return data
	}
	 // SCNScene from Data
	convenience init?(data:Data, encoding:String.Encoding) {
		 // This is broken
		let url0				= URL(string:"xx")
		let url					= URL(dataRepresentation:data, relativeTo:url0)!		//let url = URL(string:"xxx")!
		// read(from:url, options:nil, delegate:nil, progressHandler:nil)		// WHY NO SUCH CALL ???
		let options:[SCNSceneSource.LoadingOption:Any] = [:]
		try? self.init(url:url, options:options)
		//fatalError("debug me")
	}

	func printModel() {
		print("rootNode.name = '\(rootNode.name ?? "<nil>")'")
		print("rootNode.children = '\(rootNode.childNodes.count)'")
		for scn in rootNode.childNodes {
			print("name:'\(scn.name ?? "<nil>")'")
		}
	}
}




	typealias PolyWrap = Part
	class Part : Codable /* PartProtocol*/ {
		func polyWrap() -> PolyWrap {	polyWrap() }
		func polyUnwrap() -> Part 	{	Part()		}
	}
	//protocol PartProtocol {
	//	func polyWrap() -> PolyWrap
	//}

func serializeDeserialize(_ inPart:Part) throws -> Part? {

	 //  - INSERT -  PolyWrap's
	let inPolyPart:PolyWrap	= inPart.polyWrap()	// modifies inPart

		 //  - ENCODE -  PolyWrap as JSON
		let jsonData 			= try JSONEncoder().encode(inPolyPart)

			print(String(data:jsonData, encoding:.utf8) ?? "")

		 //  - DECODE -  PolyWrap from JSON
		let outPoly:PolyWrap	= try JSONDecoder().decode(PolyWrap.self, from:jsonData)

	 //  - REMOVE -  PolyWrap's
	let outPart				= outPoly.polyUnwrap()
	 // As it turns out, the 'inPart.polyWrap()' above changes inPoly!!!; undue the changes
	let _					= inPolyPart.polyUnwrap()	// WTF 210906PAK polyWrap()
	
	return outPart
}

