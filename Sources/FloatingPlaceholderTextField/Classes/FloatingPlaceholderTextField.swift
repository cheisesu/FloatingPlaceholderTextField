import UIKit

extension FloatingPlaceholderTextField {
    /// Just an alias for NSAttributedString attributes dictionary
    public typealias Attributes = [NSAttributedString.Key: Any]
    
    /// States of the field
    public struct State: OptionSet, Hashable {
        public let rawValue: Int
        
        /// Default state. It means when the field is not a first responder, not disabled and not filled.
        public static let `default` = State()
        /// State when the field is a first responder
        public static let active = State(rawValue: 1 << 0)
        /// State when there's text in the field
        public static let filled = State(rawValue: 1 << 1)
        /// State when the field is not enabled
        public static let disabled = State(rawValue: 1 << 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

/**
 Text field with floating placeholder with animation of its transition.
 
 Usage is similar to **UIButton**. You have different states of the field and can set
 placeholder attributes and underline colors for each state or its combination.
 */
open class FloatingPlaceholderTextField: UITextField {
    // MARK: - PRIVATE PROPERTIES
    
    private lazy var _placeholderLabel: FontAnimatableLabel = {
        let view = FontAnimatableLabel()
        view.layer.isOpaque = false
        self.addSubview(view)

        return view
    }()
    
    private var placeholderAttributes: [State: Attributes] = [:]
    private var lineColors: [State: UIColor] = [:]
    
    /// Offset of text and placeholder when the field is not a first responder depending
    /// on the height of font for active (first responder) state
    private var topNormalInset: CGFloat {
        let font = self.font(for: .active)
        return self.height(for: font)
    }

    // MARK: - OVERRIDDEN PROPERTIES
    
    open override var placeholder: String? {
        get { return self._placeholderLabel.text }
        set {
            self.updatePlaceholderStyling(with: newValue ?? "")
            self.setNeedsLayout()
        }
    }
    
    open override var attributedPlaceholder: NSAttributedString? {
        get { return self._placeholderLabel.attributedText }
        set {
            self.updatePlaceholderStyling(with: newValue?.string ?? "")
            self.setNeedsLayout()
        }
    }
    
    open override var isEnabled: Bool {
        get { return super.isEnabled }
        set {
            super.isEnabled = newValue
            self.updatePlaceholderStyling()
            self.setNeedsLayout()
        }
    }
    
    //MARK: - PUBLIC PROPERTIES
    
    /// Width of line under the field. Default value 2
    open var bottomLineWidth: CGFloat = 2 {
        didSet { self.setNeedsDisplay() }
    }
    
    /// Current state of the field
    public var currentState: State {
        var state = State()
        
        if self.isFirstResponder {
            state.insert(.active)
        }
        if !self.isEnabled {
            state.remove(.active) //this case is impossible i hope
            state.insert(.disabled)
        }
        if !(self.text?.isEmpty ?? true) {
            state.insert(.filled)
        }
        
        return state
    }
    
    //MARK: - INITIALIZATION
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.placeholder = super.placeholder
        super.placeholder = nil
        
        self.setNeedsDisplay()
    }
    
    //MARK: - PUBLIC METHODS
    
    /// Sets attributes of a placeholder for passed state
    ///
    /// - Parameters:
    ///   - attributes: NSAttributedString attributes
    ///   - state: state or its combination
    open func setPlaceholderAttributes(_ attributes: Attributes?, for state: State) {
        self.placeholderAttributes[state] = attributes
        self.updatePlaceholderStyling()
        self.setNeedsLayout()
    }
    
    /// Gets attributes for passed state. If there's no attributes for passed state defaultTextAttributes will be returned
    /// - Parameter state: state or its combination
    /// - Returns: NSAttributedString attrubutes dictionary
    open func placeholderAttributes(for state: State) -> Attributes {
        var subDefaultState = State.default
        if state.contains(.active) {
            subDefaultState = .active
        } else if state.contains(.disabled) {
            subDefaultState = .disabled
        }
        return self.placeholderAttributes[state] ??
            self.placeholderAttributes[subDefaultState] ??
            self.placeholderAttributes[.default] ??
            self.defaultTextAttributes
    }
    
    /// Sets color of line under the field for passed state
    /// - Parameters:
    ///   - color: underline color
    ///   - state: state or its combination
    open func setLineColor(_ color: UIColor?, for state: State) {
        self.lineColors[state] = color
        self.setNeedsDisplay()
    }
    
    /// Gets line color. If there's no color for passed state UIColor.clear will be returned
    /// - Parameter state: state or its combination
    /// - Returns: color of underline
    open func lineColor(for state: State) -> UIColor {
        var subDefaultState = State.default
        if state.contains(.active) {
            subDefaultState = .active
        } else if state.contains(.disabled) {
            subDefaultState = .disabled
        }
        return self.lineColors[state] ??
            self.lineColors[subDefaultState] ??
            self.lineColors[.default] ??
            .clear
    }
}

//MARK: - OVERRIDDEN METHODS

extension FloatingPlaceholderTextField {
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updatePlaceholderPosition()
        self.setNeedsDisplay()
    }

    open override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.lineWidth = self.bottomLineWidth
        self.lineColor(for: self.currentState).setStroke()
        path.stroke()
    }

    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        defer {
            self.updatePlaceholderStyling()
            self.setNeedsLayout()
        }
        return super.becomeFirstResponder()
    }

    @discardableResult
    open override func resignFirstResponder() -> Bool {
        defer {
            self.updatePlaceholderStyling()
            self.setNeedsLayout()
        }
        return super.resignFirstResponder()
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let insets = UIEdgeInsets(top: self.topNormalInset, left: 0, bottom: 0, right: 0)
        let identityRect = superRect.inset(by: insets)
        
        if self.currentState.contains(.filled) || self.currentState.contains(.active) {
            let height = self.bounds.height - identityRect.height
            let width = identityRect.width
            let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
            return rect
        } else {
            return identityRect
        }
    }

    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let bounds = bounds.insetBy(dx: 0, dy: 8)
        var size = self.rightView?.sizeThatFits(bounds.size) ?? .zero
        size.width = min(0.4 * bounds.width, size.width)
        size.height = bounds.height
        var result = CGRect()
        result.origin.x = bounds.maxX - size.width
        result.origin.y = bounds.minY
        result.size = size
        return result
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let insets = UIEdgeInsets(top: self.topNormalInset, left: 0, bottom: 0, right: 0)
        let result = superRect.inset(by: insets)
        return result
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let insets = UIEdgeInsets(top: self.topNormalInset, left: 0, bottom: 0, right: 0)
        let result = superRect.inset(by: insets)
        return result
    }
}

//MARK: - PRIVATE METHODS

extension FloatingPlaceholderTextField {
    private func updatePlaceholderPosition() {
        let rect = self.placeholderRect(forBounds: bounds)
        let font = self.font(for: self.currentState)
        
        self._placeholderLabel.animateToFrame(rect, font: font)
    }
    
    private func updatePlaceholderStyling(with text: String) {
        let attributes = self.placeholderAttributes(for: self.currentState)
        self._placeholderLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    private func updatePlaceholderStyling() {
        self.updatePlaceholderStyling(with: self.placeholder ?? "")
    }
    
    private func height(for font: UIFont?) -> CGFloat {
        guard let font = font else { return 0 }
        let height = font.ascender + (-font.descender)
        return height
    }
    
    private func font(for state: State) -> UIFont {
        return (self.placeholderAttributes(for: state)[.font] as? UIFont) ?? .systemFont(ofSize: UIFont.systemFontSize)
    }
}
