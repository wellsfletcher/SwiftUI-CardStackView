import CardStack
import XCTest

final class DirectionTests: XCTestCase {

    func testLeftRight() {
        func assertDirection(_ degrees: Double, _ direction: LeftRight?) {
            XCTAssertEqual(LeftRight.from(angle: .degrees(degrees)), direction)
        }
        
        assertDirection(0, .right)
        assertDirection(90, nil)
        assertDirection(180, .left)
        assertDirection(270, nil)
    }

    func testFourDirections() {
        func assertDirection(_ degrees: Double, _ direction: FourDirections?) {
            XCTAssertEqual(FourDirections.from(angle: .degrees(degrees)), direction)
        }
        
        assertDirection(0, .right)
        assertDirection(90, .top)
        assertDirection(180, .left)
        assertDirection(270, .bottom)
    }
    
    func testEightDirections() {
        func assertDirection(_ degrees: Double, _ direction: EightDirections?) {
            XCTAssertEqual(EightDirections.from(angle: .degrees(degrees)), direction)
        }
        
        assertDirection(0, .right)
        assertDirection(45, .topRight)
        assertDirection(90, .top)
        assertDirection(135, .topLeft)
        assertDirection(180, .left)
        assertDirection(225, .bottomLeft)
        assertDirection(270, .bottom)
        assertDirection(315, .bottomRight)
    }

}
