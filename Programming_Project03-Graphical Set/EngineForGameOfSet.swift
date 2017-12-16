//
//  EngineForGameOfSet.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 20/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation

class EngineForGameOfSet: CustomStringConvertible {

	private var deck = DeckOfCardsForGameOfSet()
	lazy var cardsOnTable: [CardForGameOfSet] = deck.draw(n: .twelve) ?? []
	var cardsTakenFromTable: [CardForGameOfSet] = []
	
	func drawCards() -> [CardForGameOfSet]? {
		let cards = deck.draw(n: .three) ?? []
		cardsOnTable +=  cards
		return cards
	}
	
	func ifSetThenRemoveFromTable(cards: [CardForGameOfSet]) -> Bool {
		guard isSet(cards: cards) else { return false }
		for card in cards {
			if let index = cardsOnTable.index(of: card) {
				let cardFromTable = cardsOnTable.remove(at: index)
				cardsTakenFromTable.append(cardFromTable)
			}
		}
		score += 3
		return true
	}
	
	var score: Int = 0
	
	func isSet(cards: [CardForGameOfSet]) -> Bool {
		guard cards.count == 3 else { return false }
		var sumMatrix  = [Int](repeating: 0, count: cards[0].matrixWithIntValues.count)
		for card in cards {
			let matrix = card.matrixWithIntValues
			for valueIndex in matrix.indices {
				sumMatrix[valueIndex] += matrix[valueIndex]
			}
		}
		return sumMatrix.reduce(true, { $0 && ($1 % 3 == 0) })
	}
	
	var hints: [[CardForGameOfSet]] {
		var hints = [[CardForGameOfSet]]()
		for i in 0..<cardsOnTable.count - 2 {
			for j in (i+1)..<cardsOnTable.count - 1 {
				for k in (j+1)..<cardsOnTable.count {
					let cards = [cardsOnTable[i], cardsOnTable[j], cardsOnTable[k]]
					if isSet(cards: cards) {
						hints.append(cards)
					}
				}
			}
		}
		return hints
	}
	
	var description: String {
		var returnString = ""
		returnString += "cardsOnTable: \(cardsOnTable.count)\n \(cardsOnTable)"
		returnString += "\n\ncardsTakenFromTable: \(cardsTakenFromTable.count)\n \(cardsTakenFromTable)"
//		returnString += "\n\nTest drawCards(): \n \(drawCards()!)"
		let date = Date()
		let hints = self.hints
		returnString += "\n\nHints: \(hints.count)\n \(hints) \n\nIt took hints \(-date.timeIntervalSinceNow) seconds"
		return returnString
	}
}


