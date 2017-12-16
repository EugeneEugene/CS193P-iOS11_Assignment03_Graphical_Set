//
//  ViewForSetCard.swift
//  Programming_Project03-Graphical_Set
//
//  Created by Michel Deiman on 13/12/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit


struct ObjectsForSet {
	
	// See supporting files - ViewForSetCard measures.pdf
	
	let fillFactor: CGFloat
	let maxNumberOfObjects: Int
	let numberOfObjects: Int
	let objectType: Shapes
	let numberOfStripes = 8
	
	var bezierPath: UIBezierPath {
		let paths = UIBezierPath()
		switch objectType {
		case .circle:
			for center in objectsCenter {
				let bezierPath = UIBezierPath(arcCenter: center, radius: objectHeight/2, startAngle: CGFloat(0), endAngle:CGFloat.pi * 2, clockwise: true)
				paths.append(bezierPath)
			}
		case .triangle:
			for trianglePath in pathsForTriangles {
				let bezierPath = UIBezierPath()
				bezierPath.move(to: trianglePath.point1)
				bezierPath.addLine(to: trianglePath.point2)
				bezierPath.addLine(to: trianglePath.point3)
				bezierPath.close()
				paths.append(bezierPath)
			}
		case .square:
			for origin in objectsOrigin {
				let bezierPath = UIBezierPath(rect: CGRect(origin: origin, size: CGSize(width: objectWidth, height: objectHeight)))
				paths.append(bezierPath)
			}
		}
		return paths
	}
	
	var bezierPathForStripes: UIBezierPath {
		let path = UIBezierPath()
		for objectGrid in stripesForObjects {
			for (p1, p2) in objectGrid {
				path.move(to: p1)
				path.addLine(to: p2)
			}
			path.append(bezierPath)
		}
		return path
	}
	
	private var objectsOrigin: [CGPoint] {
		guard numberOfObjects > 0 && numberOfObjects <= maxNumberOfObjects else { return [] }
		var objectsOrigin: [CGPoint] = []
		let y0 = (height - (objectHeight * CGFloat(numberOfObjects) + CGFloat(numberOfObjects-1)*interObjectsSpace))/2
		let x = (width - objectWidth) / 2
		for n in 0..<numberOfObjects {
			switch orientation {
			case .vertical:
				objectsOrigin.append(CGPoint(x: x, y: y0 + CGFloat(n)*(objectHeight+interObjectsSpace)))
			case .horizontal:
				objectsOrigin.append(CGPoint(x: y0 + CGFloat(n)*(objectHeight+interObjectsSpace), y: x))
			}
		}
		return objectsOrigin
	}
	
	private var objectsCenter: [CGPoint] {
		var objectsCenter: [CGPoint] = []
		objectsOrigin.forEach { origin in
			objectsCenter.append(CGPoint(x: origin.x + objectWidth/2, y: origin.y + objectHeight/2) )
		}
		return objectsCenter
	}
	
	private var pathsForTriangles: [(point1: CGPoint, point2: CGPoint, point3: CGPoint)] {
		var pointsForTriangles: [(CGPoint, CGPoint, CGPoint)] = []
		objectsOrigin.forEach { origin in
			let firstPoint = CGPoint(x: origin.x + objectWidth/2, y: origin.y)
			let secondPoint = CGPoint(x: origin.x + objectWidth, y: origin.y + objectHeight)
			let thirdPoint = CGPoint(x: origin.x, y: origin.y + objectHeight)
			pointsForTriangles.append((firstPoint, secondPoint, thirdPoint))
		}
		return pointsForTriangles
	}
	
	private var stripesForObjects: [[(CGPoint, CGPoint)]] {
		var deltaStripe: CGFloat {
			return (objectWidth + objectHeight)/(CGFloat(numberOfStripes) + 1)
		}
		
		var stripesForObjects: [[(CGPoint, CGPoint)]] = [[]]
		for origin in objectsOrigin {
			var pointsForStripes: [(CGPoint, CGPoint)] = []
			var n = 1
			while n <= numberOfStripes/2 {
				let p1 = CGPoint(x: origin.x, y: origin.y + CGFloat(n)*deltaStripe)
				let p2 = CGPoint(x: origin.x+CGFloat(n)*deltaStripe, y: origin.y)
				pointsForStripes.append((p1, p2))
				let q1 = CGPoint(x: origin.x+objectWidth-CGFloat(n)*deltaStripe, y: origin.y+objectHeight)
				let q2 = CGPoint(x: origin.x+objectWidth, y: origin.y+objectHeight-CGFloat(n)*deltaStripe)
				pointsForStripes.append((q1, q2))
				n+=1
			}
			if numberOfStripes % 2 != 0 {
				let r1 = CGPoint(x: origin.x, y: origin.y+objectHeight)
				let r2 = CGPoint(x: origin.x+objectWidth, y: origin.y)
				pointsForStripes.append((r1, r2))
			}
			stripesForObjects.append(pointsForStripes)
		}
		return stripesForObjects
	}
	
	init(in rect: CGRect, for objectType: Shapes, numberOfObjects: Int, fillFactor: CGFloat = 0.65, maxNumberOfObjects: Int = 3) {
		self.numberOfObjects = numberOfObjects
		self.fillFactor = fillFactor
		self.maxNumberOfObjects = maxNumberOfObjects
		orientation = rect.height >= rect.width ? .vertical: .horizontal
		height = orientation == .vertical ? rect.height: rect.width
		width = orientation == .vertical ? rect.width: rect.height
		self.objectType = objectType
	}
	
	private enum Orientation {
		case horizontal
		case vertical
	}
	private var orientation: Orientation
	
	private var height: CGFloat
	private var width: CGFloat
	
	// See supporting files - ViewForSetCard measures.pdf - a
	var objectHeight: CGFloat {
		return min(height * fillFactor/CGFloat(maxNumberOfObjects), fillFactor * width)
	}
	var objectWidth: CGFloat {
		return objectHeight
	}
	
	private var interObjectsSpace: CGFloat {
		return (height - CGFloat(maxNumberOfObjects)*objectHeight)/CGFloat(maxNumberOfObjects+1)
	}
}

