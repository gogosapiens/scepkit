//
//  SCEPAnimatedCollectionViewCell.swift
//  SCEPKit
//
//  Created by Illia Harkavy on 24/12/2024.
//

import UIKit

class SCEPAnimatedCollectionViewCell: UICollectionViewCell {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setHighlighted(true, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setHighlighted(false, animated: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setHighlighted(false, animated: true)
    }
    
    private func setHighlighted(_ isHighlighted: Bool, animated: Bool) {
        let scale = isHighlighted ? 0.95 : 1
        let alpha = isHighlighted ? 0.8 : 1
        UIView.animate(withDuration: animated ? 0.1 : 0, delay: 0, options: [.curveLinear]) {
            self.alpha = alpha
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
