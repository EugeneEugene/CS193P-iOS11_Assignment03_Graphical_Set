//
//  MainView.swift
//  Programming_Project03-Graphical_Set
//
//  Created by Michel Deiman on 25/12/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit

protocol LayoutViews: class {
	func updateViewFromModel()
}

class MainView: UIView {
	
	weak var delegate: LayoutViews?
	
	override func layoutSubviews() {
		super.layoutSubviews()
		delegate?.updateViewFromModel()
	}
	
}

