//
//  DeckOfCardsForGameOfSet.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 20/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation


struct DeckOfCardsForGameOfSet: CustomStringConvertible {
	
	private(set) var cards = [CardForGameOfSet]()
	
	mutating func draw(n: validDraws = .three) -> [CardForGameOfSet]?  {
		if cards.count < n.rawValue { return nil }
		
		var returnArray = [CardForGameOfSet]()
		for _ in 1...n.rawValue {
			returnArray.append(cards.remove(at: cards.count.arc4Random))
		}
		return returnArray
	}
	
	var count: Int {
		return cards.count
	}
	
	enum validDraws: Int {
		case three = 3
		case twelve = 12
	}
	
	init() {
		let rangeOfThree = 1...3
		for number in rangeOfThree {
			for color in rangeOfThree {
				for shape in rangeOfThree {
					for fill in rangeOfThree {
						let card = CardForGameOfSet(with: number, color, shape, fill)
						cards.append(card)
					}
				}
			}
		}
	}
	
	var description: String {
		var returnString = ""
		for card in cards {
			returnString += "\(card)\n"
		}
		return returnString
	}
}

extension Int {
	var arc4Random: Int {
		switch self {
		case 1...Int.max:
			return Int(arc4random_uniform(UInt32(self)))
		case -Int.max..<0:
			return Int(arc4random_uniform(UInt32(self)))
		default:
			return 0
		}
		
	}
}
