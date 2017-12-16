//
//  CardForGameOfSet.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 20/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation

struct CardForGameOfSet: Equatable, Hashable ,CustomStringConvertible {
	
	let number: Numbers
	let color: Colors
	let shape: Shapes
	let fill: Fills
	
	var matrixWithIntValues: [Int] {
		return [number.rawValue, color.rawValue, shape.rawValue, fill.rawValue]
	}
	
	private static var identifierFactory = 0
	let hashValue: Int = {
		identifierFactory += 1
		return identifierFactory
	}()

	static func ==(lhs: CardForGameOfSet, rhs: CardForGameOfSet) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	var description: String {
		return "number: \(number), color: \(color), shape: \(shape), fill: \(fill)\n"
	}
	
	init(with n: Int, _ c: Int, _ s: Int, _ f: Int) {
		self.number = Numbers(rawValue: n)!
		self.color = Colors(rawValue: c)!
		self.shape = Shapes(rawValue: s)!
		self.fill = Fills(rawValue: f)!
	}
	
}


enum Numbers: Int, CustomStringConvertible  {
	case one = 1
	case two
	case three
	
	var description: String {
		switch self {
		case .one: return "one"
		case .two: return "two"
		case .three: return "three"
		}
	}
}

enum Colors: Int, CustomStringConvertible {
	case red = 1
	case green
	case blue
	
	var description: String {
		switch self {
		case .red: return "red"
		case .green: return "green"
		case .blue: return "blue"
		}
	}
}

enum Shapes: Int, CustomStringConvertible {
	case circle = 1
	case square
	case triangle
	
	var description: String {
		switch self {
		case .circle: return "circle"
		case .square: return "square"
		case .triangle: return "triangle"
		}
	}
}

enum Fills: Int, CustomStringConvertible {
	case solid = 1
	case stripe
	case empty
	
	var description: String {
		switch self {
		case .solid: return "solid"
		case .stripe: return "stripe"
		case .empty: return "empty"
		}
	}
}




