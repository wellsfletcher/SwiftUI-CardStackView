import Foundation
import SwiftUI


// Directions are created from Angle, such as follow
//
//          π/2
//           |
//           |
//           |
//   π ------------- 0
//           |
//           |
//           |
//          3π/2
//
// or in degrees:
//          90
//           |
//           |
//           |
//  180 ------------ 0
//           |
//           |
//           |
//          270
public protocol CardSwipeDirection: Equatable {

    static func from(angle: Angle) -> Self?
    
    var angle: Angle { get }
    
}

public enum LeftRight: CardSwipeDirection {

    case left, right

    public static func from(angle: Angle) -> Self? {
        switch angle.normalized.radians {
        case 3 * .pi / 4 ..< 5 * .pi / 4:   return .left
        case 0 ..< .pi / 4:                 return .right
        case 7 * .pi / 4 ..< 2 * .pi:       return .right
        default:                            return nil
        }
    }

    public var angle: Angle {
        switch self {
        case .left:     return .radians(.pi)
        case .right:    return .zero
        }
    }

}

public enum FourDirections: CardSwipeDirection {
    case top, right, bottom, left
    
    public static func from(angle: Angle) -> Self? {
        switch angle.normalized.radians {
        case .pi / 4 ..< 3 * .pi / 4:       return .top
        case 3 * .pi / 4 ..< 5 * .pi / 4:   return .left
        case 5 * .pi / 4 ..< 7 * .pi / 4:   return .bottom
        default:                            return .right
        }
    }
    
    public var angle: Angle {
        switch self {
        case .top:      return .radians(.pi / 2)
        case .right:    return .zero
        case .bottom:   return .radians(3 * .pi / 2)
        case .left:     return .radians(.pi)
        }
    }
}

public enum EightDirections: CardSwipeDirection {
    case top, right, bottom, left, topLeft, topRight, bottomLeft, bottomRight
    
    public static func from(angle: Angle) -> Self? {
        switch angle.normalized.degrees {
        case 022.5..<067.5: return .topRight
        case 067.5..<112.5: return .top
        case 112.5..<157.5: return .topLeft
        case 157.5..<202.5: return .left
        case 202.5..<247.5: return .bottomLeft
        case 247.5..<292.5: return .bottom
        case 292.5..<337.5: return .bottomRight
        default:            return .right
        }
    }
    
    public var angle: Angle {
        switch self {
        case .top:          return .degrees(90)
        case .right:        return .zero
        case .bottom:       return .degrees(270)
        case .left:         return .degrees(180)
        case .topLeft:      return .degrees(135)
        case .topRight:     return .degrees(45)
        case .bottomLeft:   return .degrees(225)
        case .bottomRight:  return .degrees(315)
        }
    }
}

public extension Angle {
    
    var normalized: Angle {
        if self.radians < 0 { return .radians(self.radians + 2 * .pi) }
        return self
    }
    
}
