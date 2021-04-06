import UIKit

private extension NSTextAlignment {
    /// конвертация в TextAlignment от CATextLayer
    var textLayerAlignment: CATextLayerAlignmentMode {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified: return .justified
        case .natural: return .natural
        @unknown default: return .natural
        }
    }
}

private class FontAnimatableLabelLayer: CATextLayer {
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "fontSize" { return true }
        return super.needsDisplay(forKey: key)
    }

    override func action(forKey event: String) -> CAAction? {
        if let presLayer = self.presentation(), event == "fontSize" {
            let fontSizeAnimation = CABasicAnimation(keyPath: event)
            fontSizeAnimation.fromValue = presLayer.fontSize
            return fontSizeAnimation
        }
        return super.action(forKey: event)
    }
}

/// класс для анимации изменения размера шрифта
class FontAnimatableLabel: UILabel {
    // swiftlint:disable force_cast
    override var layer: CATextLayer { return super.layer as! CATextLayer }
    // swiftlint:enable force_cast
    override class var layerClass: AnyClass { return FontAnimatableLabelLayer.self }
}

extension FontAnimatableLabel {
    override var text: String? {
        willSet { self.layer.string = newValue }
    }
    override var attributedText: NSAttributedString? {
        willSet { self.layer.string = newValue }
    }
    override var font: UIFont! {
        willSet {
            self.layer.font = newValue.fontName as CFTypeRef
            self.layer.fontSize = newValue.pointSize
        }
    }
    override var textAlignment: NSTextAlignment {
        willSet { self.layer.alignmentMode = newValue.textLayerAlignment }
    }
    override var textColor: UIColor! {
        willSet { self.layer.foregroundColor = newValue.cgColor }
    }
}

extension FontAnimatableLabel {
    func animateToFrame(_ newFrame: CGRect, font: UIFont?, duration: TimeInterval = 0.3, curve: AnimationCurve = .easeInOut) {
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            self.frame = newFrame
            self.font = font
        }
        animator.startAnimation()
    }
}
