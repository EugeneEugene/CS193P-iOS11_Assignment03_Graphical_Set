//
//  ViewController.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 20/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

	@IBOutlet var cardButtons: [SetCardButton]!
	
	@IBOutlet weak var drawCardsButton: UIButton! {
		didSet {
			setup(drawCardsButton)
			drawCardsButton!.titleLabel?.numberOfLines = 0
		}
	}
	@IBOutlet weak var hintButton: UIButton! { didSet { setup(hintButton) } }
	@IBOutlet weak var startNewGameButton: UIButton! { didSet { setup(startNewGameButton) } }
	
	func setup(_ button: UIButton) {
		button.layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		button.layer.borderWidth = LayOutMetricsForCardView.borderWidthForDrawButton
		button.layer.borderColor = LayOutMetricsForCardView.borderColorForDrawButton
	}
	
	let grid = Grid(layout: .aspectRatio(1.5), frame: <#T##CGRect#>)
	
	var gameEngine: EngineForGameOfSet! {
		didSet {
			let cardsOnTable = gameEngine.cardsOnTable
			hints.cards = gameEngine.hints
			
			for index in cardsOnTable.indices {
				let setCardButton = cardButtons[index]
				setCardButton.card = cardsOnTable[index]
			}
		}
	}
	
	var selectedButtons = [SetCardButton]() {
		willSet(willSelectedButtons) {
			if willSelectedButtons == [] {
				_ = selectedButtons.map { $0.stateOfSetCardButton = .unselected }
				if thereIsASet {
					_ = drawCards()
					thereIsASet = false
				}
			} else if willSelectedButtons.count == 3 {
				let indices = willSelectedButtons.map { $0.cardIndex }
				let cards = cardsFor(cardIndices: indices)
				if gameEngine.ifSetThenRemoveFromTable(cards: cards) {
					_ = willSelectedButtons.map { $0.stateOfSetCardButton = .selectedAndMatched }
					thereIsASet = true
					hints.cards = gameEngine.hints
				}
			}
		}
	}
	
	@IBOutlet weak var scoreLabel: UILabel!
	
	var thereIsASet = false {
		didSet {
			scoreLabel.text = "\(gameEngine.score)"
		}
	}
	
	@IBAction func onNewGameButton(_ sender: UIButton) {
		thereIsASet = false
		selectedButtons = []
		_ = cardButtons.map {
			$0.stateOfSetCardButton = .unselected
			$0.card = nil
		}
		gameEngine = EngineForGameOfSet()
	}
	
	@IBAction func onCardButton(_ sender: SetCardButton) {
		if selectedButtons.count == 3  { selectedButtons = [] }
		if sender.cardIndex == 0  { return }
		
		switch sender.stateOfSetCardButton {
		case .unselected:
			sender.stateOfSetCardButton = .selected
			selectedButtons.append(sender)
		case .selected:
			if let index = selectedButtons.index(of: sender) {
				sender.stateOfSetCardButton = .unselected
				selectedButtons.remove(at: index)
			}
		default: break
		}
	}
	
	@IBAction func onDrawCardButton(_ sender: UIButton) {
		guard !thereIsASet else	{
			selectedButtons = []
			return
		}
		_ = drawCards()
	}
	
	var hints: (cards: [[CardForGameOfSet]], index: Int) = ([[]], 0) {
		didSet {
			if hints.index == oldValue.index {
				hints.index = 0
			}
			hintButton!.isEnabled = !hints.cards.isEmpty ? true : false
			hintButton!.setTitle("hints: \(hints.cards.count)", for: .normal)
		}
	}
	
	@IBAction func onHintButton(_ sender: UIButton) {
		selectedButtons = []
		let cardButtonsWithSet = buttonsFor(cards: hints.cards[hints.index])
		_ = cardButtonsWithSet.map { $0.stateOfSetCardButton = .selected  }
		hints.index = hints.index < hints.cards.count - 1 ? hints.index + 1 : 0
		Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {  timer in
			_ = cardButtonsWithSet.map { $0.stateOfSetCardButton = .unselected  }
		}
	}
	
	func drawCards() -> Bool {
		let freeSlotsCount = cardButtons.count - gameEngine.cardsOnTable.count
		guard freeSlotsCount >= 3, let cards = gameEngine.drawCards()  else { return false }
		hints.cards = gameEngine.hints
		
		var freeSlots: [SetCardButton] = thereIsASet ? selectedButtons: cardButtons.filter { $0.cardIndex == 0 }
		
		for index in cards.indices {
			let setCardButton = freeSlots[index]
			setCardButton.card = cards[index]
		}
		return true
	}
	
	
	private func cardsFor(cardIndices: [Int]) -> [CardForGameOfSet] {
		var cards = [CardForGameOfSet]()
		for hashValue in cardIndices {
			if let card = (gameEngine.cardsOnTable.filter { $0.hashValue == hashValue }).first {
				cards.append(card)
			}
		}
		return cards
	}
	
	private func buttonsFor(cards: [CardForGameOfSet])-> [SetCardButton] {
		var buttons: [SetCardButton] = []
		for card in cards {
			if let button = (cardButtons.filter { $0.cardIndex == card.hashValue }).first  {
				buttons.append(button)
			}		
		}
		return buttons
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		gameEngine = EngineForGameOfSet()
	}
}

struct LayOutMetricsForCardView {
	static var borderWidth: CGFloat = 1.0
	static var borderWidthIfSelected: CGFloat = 3.0
	static var borderColorIfSelected: CGColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
	
	static var borderWidthIfMatched: CGFloat = 4.0
	static var borderColorIfMatched: CGColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
	
	static var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderColorForDrawButton: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderWidthForDrawButton: CGFloat = 3.0
	static var cornerRadius: CGFloat = 8.0
}
