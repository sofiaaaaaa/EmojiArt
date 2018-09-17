//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by 임지후 on 2018. 9. 16..
//  Copyright © 2018년 임지후. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            print("aaaaaaaaa")
            textField.delegate = self
        }
    }
    
    var resignationHandler: (() -> Void )?
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
