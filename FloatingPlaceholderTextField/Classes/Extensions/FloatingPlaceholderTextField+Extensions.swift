import UIKit

extension FloatingPlaceholderTextField {
    public typealias Attributes = [NSAttributedString.Key: Any]
    
    public struct State: OptionSet, Hashable {
        public let rawValue: Int
        
        public static let `default` = State()
        /// Состояние, когда поле в фокусе
        public static let active = State(rawValue: 1 << 0)
        /// Состояние, когда в поле есть контент
        public static let filled = State(rawValue: 1 << 1)
        public static let disabled = State(rawValue: 1 << 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
