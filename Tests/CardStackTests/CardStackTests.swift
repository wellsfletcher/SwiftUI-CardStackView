import SnapshotTesting
import SwiftUI
import XCTest

@testable import CardStack

final class CardStackTests: XCTestCase {
    
    private struct SimpleIndex: Identifiable {
        let id: UUID = .init()
        let index: Int
    }
    
    private func assertCardStack(
        with data: [SimpleIndex],
        configuration: CardStackConfiguration? = nil,
        testName: String = #function
    ) {
        guard
            !ProcessInfo.processInfo.environment.keys
                .contains("GITHUB_WORKFLOW")
        else { return }
        
        let model = CardStackModel<_, LeftRight>(data)
        let view = CardStack<LeftRight, _, _>(
            model: model,
            onSwipe: { _, _ in }
        ) { indexObject, _ in
            Text(String(indexObject.index))
                .frame(width: 300, height: 300, alignment: .center)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.blue, Color.red]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .foregroundColor(Color.white)
        }
            .frame(width: 500, height: 500, alignment: .center)
        
        if let configuration = configuration {
            assertSnapshot(
                matching: view.environment(\.cardStackConfiguration, configuration),
                as: .image(size: CGSize(width: 500, height: 500)),
                testName: "\(Self.namePrefix).\(testName)"
            )
        } else {
            assertSnapshot(
                matching: view,
                as: .image(size: CGSize(width: 500, height: 500)),
                testName: "\(Self.namePrefix).\(testName)"
            )
        }
    }
    
    func testOneCard() {
        assertCardStack(with: [SimpleIndex(index: 1)])
    }
    
    func testTwoCards() {
        let indices = [1, 2].map { SimpleIndex(index: $0) }
        assertCardStack(with: indices)
    }
    
    func testThousandCards() {
        let indices = Array(1...1000).map { SimpleIndex(index: $0) }
        assertCardStack(with: indices)
    }
    
    func testCustomConfiguration() {
        assertCardStack(
            with: Array(1...7).map { SimpleIndex(index: $0) },
            configuration: CardStackConfiguration(
                maxVisibleCards: 7,
                cardOffset: 20,
                cardScale: 0.05
            )
        )
    }
    
    static var allTests = [
        ("testOneCard", testOneCard),
        ("testTwoCards", testTwoCards),
        ("testThousandCards", testThousandCards),
        ("testCustomConfiguration", testCustomConfiguration),
    ]
}

extension CardStackTests {
    
#if os(iOS)
    private static var namePrefix: String { "iOS" }
#elseif os(macOS)
    private static var namePrefix: String { "macOS" }
#endif
    
}
