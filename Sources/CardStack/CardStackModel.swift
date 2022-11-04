import Combine
import Foundation
import SwiftUI
import CoreGraphics

public class CardStackData<Element: Identifiable, Direction: Equatable>: Identifiable {
    
    public var id: Element.ID {
        return element.id
    }
    let element: Element
    var direction: Direction?
    
    init(_ element: Element, direction: Direction? = nil) {
        self.element = element
        self.direction = direction
    }
    
}

public class CardStackModel<Element: Identifiable, Direction: Equatable>: ObservableObject {
    
    @Published private(set) public var numberOfElements: Int
    @Published private(set) public var numberOfElementsRemaining: Int

    @Published private(set) var data: [CardStackData<Element, Direction>]
    @Published private(set) var currentIndex: Int?
    
    public var index: Int? {
        return currentIndex
    }
    
    public var datum: Element? {
        if index == nil {
            return nil
        }
        return data[index!].element
    }
    
    private var subscriptions: Set<AnyCancellable> = []
        
    public init(_ elements: [Element]) {
        data = elements.map { CardStackData($0) }
        currentIndex = elements.count > 0 ? 0 : nil
        numberOfElements = elements.count
        numberOfElementsRemaining = elements.count
        
        $data
            .sink { [weak self] data in
                guard let self = self else { return }
                self.numberOfElements = data.count
            }
            .store(in: &subscriptions)
        
        $numberOfElements.combineLatest($currentIndex)
            .sink { [weak self] number, index in
                guard let self = self else { return }
                if let index = index  {
                    self.numberOfElementsRemaining = number - index
                } else {
                    self.numberOfElementsRemaining = 0
                }
            }
            .store(in: &subscriptions)
    }
    
    public func setElements(_ elements: [Element]) {
        data = elements.map { CardStackData($0) }
        currentIndex = elements.count > 0 ? 0 : nil
    }
    
    public func appendElement(_ element: Element) {
        data.append(CardStackData(element))
        if currentIndex == nil { currentIndex = 0 }
    }
    
    public func appendElements(_ elements: [Element]) {
        data.append(contentsOf: elements.map { CardStackData($0) })
        if currentIndex == nil { currentIndex = 0 }
    }
    
    public func removeAllElements() {
        data.removeAll()
        currentIndex = nil
    }
    
    public func swipe(direction: Direction, completion: ((Element, Direction) -> Void)?) {
        guard let currentIndex = currentIndex else {
            return
        }
        
        let element = data[currentIndex].element
        data[currentIndex].direction = direction

        let nextIndex = currentIndex + 1
        if nextIndex < data.count {
            self.currentIndex = nextIndex
        } else {
            self.currentIndex = nil
        }
        
        completion?(element, direction)
    }
    
    public func unswipe(completion: () -> Void = {}) {
        
        var currentIndex: Int! = self.currentIndex
        if currentIndex == nil {
            currentIndex = data.count
        }
        
        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            data[previousIndex].direction = nil
            self.currentIndex = previousIndex
        }
        
        completion()
    }
    
    internal func indexInStack(_ dataPiece: CardStackData<Element, Direction>) -> Int? {
        guard let index = data.firstIndex(where: { $0.id == dataPiece.id }) else { return nil }
        return index - (currentIndex ?? data.count)
    }
    
    
}
