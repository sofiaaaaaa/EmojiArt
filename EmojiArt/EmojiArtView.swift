//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by 임지후 on 2018. 9. 5..
//  Copyright © 2018년 임지후. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {

    var backgoundImage: UIImage? { didSet { setNeedsDisplay() }}
    override func draw(_ rect: CGRect){
        backgoundImage?.draw(in:bounds)
    }

}
