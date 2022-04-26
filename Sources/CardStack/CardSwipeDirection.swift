import Foundation
import SwiftUI


// Directions are created from angles, such as follow
//          π/2
//           |
//           |
//           |
//   π ------------- 0
//           |
//           |
//           |
//          3π/2
public protocol CardSwipeDirection: Equatable {

    static func from(angle: Angle) -> Self?
    
    var angle: Angle { get }
    
}

public enum LeftRight: CardSwipeDirection {

    case left, right

    public static func from(angle: Angle) -> Self? {
        switch angle.normalized.radians {
        case 3 * .pi / 4 ..< 5 * .pi / 4: return .left
        case 0 ..< .pi / 4: return .right
        case 7 * .pi / 4 ..< 0: return .right
        default: return nil
        }
    }

    public var angle: Angle {
        switch self {
        case .left:
            return .radians(.pi)
        case .right:
            return .zero
        }
    }

}

public enum FourDirections: CardSwipeDirection {
    case top, right, bottom, left
    
    public static func from(angle: Angle) -> Self? {
        switch angle.normalized.radians {
        case .pi / 4 ..< 3 * .pi / 4: return .top
        case 3 * .pi / 4 ..< 5 * .pi / 4: return .left
        case 5 * .pi / 4 ..< 7 * .pi / 4: return .bottom
        default: return .right
        }
    }
    
    public var angle: Angle {
        switch self {
        case .top:
            return .radians(.pi / 2)
        case .right:
            return .zero
        case .bottom:
            return .radians(3 * .pi / 2)
        case .left:
            return .radians(.pi)
        }
    }
}

extension Angle {
    
    var normalized: Angle {
        if self.radians < 0 { return .radians(self.radians + 2 * .pi) }
        return self
    }
    
}
