//
//  ViewController.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 20/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var cardButtons: [SetCardView] = []
	
	@IBOutlet weak var drawCardsButton: UIButton! {
		didSet {
			drawCardsButton!.titleLabel?.numberOfLines = 0
			drawCardsButton.setTitle("none", for: .disabled)
		}
	}
	@IBOutlet weak var hintButton: UIButton! { didSet { layOutFor(button: hintButton) } }
	@IBOutlet weak var startNewGameButton: UIButton!  { didSet { layOutFor(button: startNewGameButton) } }
	@IBOutlet weak var scoreLabel: UILabel! { didSet { layOutFor(button: scoreLabel) } }

	func layOutFor(button: UIView) {
		button.layer.borderWidth = LayOutMetricsForCardView.borderWidth
		button.layer.borderColor = LayOutMetricsForCardView.borderColor
		button.layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		button.clipsToBounds = true
	}
	
	@IBOutlet weak var superViewForCards: UIView! {
		didSet {
			let swipe = UISwipeGestureRecognizer(target: self, action: #selector(onDrawCardsSwipe(_:)))
			swipe.direction = [.down]
			superViewForCards.addGestureRecognizer(swipe)
			superViewForCards.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(onReShuffleCards(_:))))
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let grid = aspectRatioGrid(for: superViewForCards.bounds, withNoOfFrames: gameEngine.cardsOnTable.count)
		for index in cardButtons.indices {
			let insetXY = (grid[index]?.height ?? 400)/100
			cardButtons[index].frame = grid[index]?.insetBy(dx: insetXY, dy: insetXY) ?? CGRect.zero
		}
	}
	
	private var gameEngine: EngineForGameOfSet! {
		didSet {
			let cardsOnTable = gameEngine.cardsOnTable
			hints.cards = gameEngine.hints
			for index in cardsOnTable.indices {
				addSetCardView(for: cardsOnTable[index])
			}
		}
	}

	private func addSetCardView(for card: CardForGameOfSet){
		let setCardButton = SetCardView()
		setCardButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0.9070095486, alpha: 1)
		setCardButton.card = card
		setCardButton.contentMode = .redraw
		cardButtons.append(setCardButton)
		setCardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardButton(_:))))
		superViewForCards.addSubview(setCardButton)
	}
	
	@objc func onReShuffleCards(_ recognizer : UIRotationGestureRecognizer) {
		if recognizer.state == .ended {
			var cardsOnTable = gameEngine.cardsOnTable
			var index = 0
			while cardsOnTable != [] {
				let card = cardsOnTable.remove(at: cardsOnTable.count.arc4Random)
				cardButtons[index].card = card
				index += 1
			}
		}
	}
	
	private var selectedButtons: [SetCardView] {
		return cardButtons.filter { cardView in
			cardView.stateOfSetCardButton == .selected || cardView.stateOfSetCardButton == .selectedAndMatched
		}
	}
	
	private var thereIsASet: Bool {
		let cards = selectedButtons.map { $0.card! }
		if cards.count == 3 && gameEngine.isSet(cards: cards) {
			selectedButtons.forEach { $0.stateOfSetCardButton = .selectedAndMatched }
			drawCardsButton.isEnabled = true
			return true
		}
		return false
	}
	
	private func handleSetState() {
		let cards = selectedButtons.map { $0.card! }
		if cards.count == 3 && gameEngine.ifSetThenRemoveFromTable(cards: cards) {
			hints.cards = gameEngine.hints
			scoreLabel.text = "\(gameEngine.score)"
			selectedButtons.forEach {
				$0.card = nil
				cardButtons.remove(at: cardButtons.index(of: $0)!)
				$0.removeFromSuperview()
			}
		}
	}
	
	@objc func onCardButton(_ recognizer: UITapGestureRecognizer) {
		guard let tappedCard = recognizer.view as? SetCardView else { return }
		if selectedButtons.count == 3  {
			if thereIsASet {
				return
			}
			selectedButtons.forEach { $0.stateOfSetCardButton = .unselected }
		}
		tappedCard.stateOfSetCardButton = tappedCard.stateOfSetCardButton == .selected ? .unselected : .selected
		if thereIsASet {
			return
		}
	}
	
	@IBAction func onDrawCardsSwipe(_ recognizer: UISwipeGestureRecognizer) {
		drawCards()
	}
	
	@IBAction func onDrawCardButton(_ sender: UIButton) {
		drawCards()
	}
	
	private func drawCards() {
		if thereIsASet {
			handleSetState()
			drawCardsButton.isEnabled = gameEngine.deckCount >= 3
		}
		if let cards = gameEngine.drawCards() {
			for index in cards.indices {
				addSetCardView(for: cards[index])
				hints.cards = gameEngine.hints
			}
		} else {
			drawCardsButton.isEnabled = false
		}
	}
	
	@IBAction func onNewGameButton(_ sender: UIButton) {
		cardButtons.forEach {
			$0.card = nil
			$0.removeFromSuperview()
		}
		cardButtons = []
		gameEngine = EngineForGameOfSet()
		drawCardsButton.isEnabled = true
	}
	
	private var hints: (cards: [[CardForGameOfSet]], index: Int) = ([[]], 0) {
		didSet {
			if hints.index == oldValue.index {
				hints.index = 0
			}
			hintButton!.isEnabled = !hints.cards.isEmpty ? true : false
			hintButton!.setTitle("hints: \(hints.cards.count)", for: .normal)
		}
	}
	
	private var timer: Timer?
	private var _lastHint: [SetCardView]?
	@IBAction func onHintButton(_ sender: UIButton) {
		timer?.invalidate()
		_lastHint?.forEach { $0.stateOfSetCardButton = .unselected }
		selectedButtons.forEach { $0.stateOfSetCardButton = .unselected }
		let cardButtonsWithSet = buttonsFor(cards: hints.cards[hints.index])
		cardButtonsWithSet.forEach { $0.stateOfSetCardButton = .hinted  }
		_lastHint = cardButtonsWithSet
		hints.index = hints.index < hints.cards.count - 1 ? hints.index + 1 : 0
		timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {  timer in
			cardButtonsWithSet.forEach { [weak self] in
				if $0.stateOfSetCardButton == .hinted {
					$0.stateOfSetCardButton = .unselected
					self?._lastHint = nil
				}
			}
		}
	}
	
	private func buttonsFor(cards: [CardForGameOfSet])-> [SetCardView] {
		var buttons: [SetCardView] = []
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
	static var borderWidthIfSelected: CGFloat = 4.0
	static var borderColorIfSelected: CGColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
	
	static var borderWidthIfHinted: CGFloat = 4.0
	static var borderColorIfHinted: CGColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1).cgColor
	
	static var borderWidthIfMatched: CGFloat = 4.0
	static var borderColorIfMatched: CGColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
	
	static var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderColorForDrawButton: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
	static var borderWidthForDrawButton: CGFloat = 3.0
	static var cornerRadius: CGFloat = 8.0
}
