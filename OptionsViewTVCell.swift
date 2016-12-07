//
//  OptionsViewCell.swift
//  assetplus
//
//  Created by Sayeed Munawar Hussain on 10/10/16.
//  Copyright © 2016 Sayeed Munawar Hussain. All rights reserved.
//

import UIKit

class OptionsViewTVCell: UITableViewCell {

    @IBOutlet private weak var lbl: UILabel!

    override func awakeFromNib() {
       
        super.awakeFromNib()
        
        //for selection color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        selectedBackgroundView = bgColorView
    }
    
    override func prepareForReuse() {
        clearCell()
        super.prepareForReuse()
    }
    
    private func clearCell() {
        lbl.text = nil
    }

    func setTextValue(_ str: String) {
        self.lbl.text = str
    }
}
