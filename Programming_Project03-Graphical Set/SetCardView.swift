//
//  SetCardButton.swift
//  Programming_Project02-GameOfSet
//
//  Created by Michel Deiman on 21/11/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit

class SetCardView : UIView {
	
	private func initialise () {
		layer.borderWidth = LayOutMetricsForCardView.borderWidth
		layer.borderColor = LayOutMetricsForCardView.borderColor
		layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
		self.clipsToBounds = true
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialise()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialise()
	}
	
	var cardIndex: Int = 0
	var card: CardForGameOfSet? {
		didSet {
			cardIndex = card != nil ? card!.hashValue : 0
			stateOfSetCardButton = .unselected
			setNeedsDisplay()
		}
	}
	
	override func didMoveToSuperview() {
		setNeedsLayout()
	}

	private let objectSizeToLineWidthRatio: CGFloat = 10
	
	override func draw(_ rect: CGRect) {
		if let card = card {
			var color = UIColor()
			switch card.color {
			case .red: color = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
			case .green: color = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
			case .blue: color = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
			}
			color.setFill()
			color.setStroke()
			
			let objectsForSet = ObjectsForSet(in: bounds, for: card.shape, numberOfObjects: card.number.rawValue)
			let path = objectsForSet.bezierPath
			path.lineWidth = objectsForSet.objectHeight * objectsForSet.fillFactor/objectSizeToLineWidthRatio
			path.stroke()
			switch card.fill {
			case .empty: break
			case .solid: path.fill()
			case .stripe:
				path.addClip()
				let stripesPath = objectsForSet.bezierPathForStripes
				stripesPath.lineWidth = objectsForSet.objectHeight * objectsForSet.fillFactor/(objectSizeToLineWidthRatio * 2)
				stripesPath.stroke()
			}
		}
	}
	
	enum StateOfSetCardButton {
		case unselected
		case selected
		case hinted
		case selectedAndMatched
	}
	
	var stateOfSetCardButton: StateOfSetCardButton = .unselected {
		didSet {
			switch stateOfSetCardButton {
			case .unselected:
				layer.borderWidth = LayOutMetricsForCardView.borderWidth
				layer.borderColor = LayOutMetricsForCardView.borderColor
			case .selected:
				layer.borderWidth = LayOutMetricsForCardView.borderWidthIfSelected
				layer.borderColor = LayOutMetricsForCardView.borderColorIfSelected
			case .selectedAndMatched:
				layer.borderWidth = LayOutMetricsForCardView.borderWidthIfMatched
				layer.borderColor = LayOutMetricsForCardView.borderColorIfMatched
			case .hinted:
				layer.borderWidth = LayOutMetricsForCardView.borderWidthIfHinted
				layer.borderColor = LayOutMetricsForCardView.borderColorIfHinted
			}
		}
	}
}
