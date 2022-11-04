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
        
        // returns that element you swiped on
        completion?(element, direction)
    }
    
    public func unswipe(completion: (Element?, Element?, Direction?) -> Void = {_,_,_ in }) {
        var element: Element?
        var newlyDisplayedElement: Element?
        var direction: Direction?
        
        var currentIndex: Int! = self.currentIndex
        if currentIndex == nil {
            // this usually happens when you're at the end of the stack
            currentIndex = data.count
        } else {
            element = data[currentIndex].element
        }
        
        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            direction = data[previousIndex].direction
            newlyDisplayedElement = data[previousIndex].element
            data[previousIndex].direction = nil
            self.currentIndex = previousIndex
        }
        
        // elementUnswipedOn, newlyDisplayedElement, direction
        // previousElement, nextElement, direction
        // should this return the element you unswiped on or the previous element?
        // I feel like it should be the element you unswiped on, which should be able to be nil if you're at max index (or the list is empty? but that should never really happen; although it could if the app is bad)
        completion(element, newlyDisplayedElement, direction)
    }
    
    internal func indexInStack(_ dataPiece: CardStackData<Element, Direction>) -> Int? {
        guard let index = data.firstIndex(where: { $0.id == dataPiece.id }) else { return nil }
        return index - (currentIndex ?? data.count)
    }
    
    
}
