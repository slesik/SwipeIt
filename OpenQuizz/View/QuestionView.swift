//
//  QuestionView.swift
//  OpenQuizz
//
//  Created by Svetlana Lesik on 10/11/2018.
//  Copyright © 2018 Svetlana Lesik. All rights reserved.
//

import Foundation
import UIKit

class QuestionView: UIView {

    @IBOutlet private var label: UILabel!
    @IBOutlet private var icon: UIImageView!    
    enum Style { case correct, incorrect, standard }
    
    var style: Style = .standard {
        didSet { setStyle(style) }
    }

    private func setStyle (_ style: Style) {
        switch style {
        case .correct:
            backgroundColor = UIColor(red: 200/255.0, green: 236/255.0, blue: 160/255.0, alpha: 0.66)
            icon.image = UIImage(named: "Icon Correct")
            icon.isHidden = false
        case .incorrect:
            backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.5529411765, blue: 0.5843137255, alpha: 0.6609856592)
            icon.image = UIImage(named: "Icon Error")
            icon.isHidden = false
        case .standard:
            backgroundColor = #colorLiteral(red: 0.8442058563, green: 0.8657580018, blue: 0.8946512341, alpha: 0.5870612158)
            icon.isHidden = true
        }
    }
    
    var title = "" {
        didSet { label.text = title }
    }
}
