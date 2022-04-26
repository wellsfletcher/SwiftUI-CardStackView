//
//  CardStackModel.swift
//  BruxOrNot
//
//  Created by Romain Vincens on 22/04/2022.
//

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
    
    @Published private(set) var data: [CardStackData<Element, Direction>]
    @Published private(set) public var currentIndex: Int?
        
    public init(_ elements: [Element]) {
        data = elements.map { CardStackData($0) }
        currentIndex = elements.count > 0 ? 0 : nil
    }
    
    public func setElements(_ elements: [Element]) {
        data = elements.map { CardStackData($0) }
        currentIndex = elements.count > 0 ? 0 : nil
    }
    
    public func addElement(_ element: Element) {
        data.append(CardStackData(element))
    }
    
    func indexInStack(_ dataPiece: CardStackData<Element, Direction>) -> Int? {
        guard let index = data.firstIndex(where: { $0.id == dataPiece.id }) else { return nil }
        return index - (currentIndex ?? data.count)
    }
    
    public func swipe(direction: Direction, completion: ((Direction) -> Void)?) {
        guard let currentIndex = currentIndex else {
            return
        }
        
        data[currentIndex].direction = direction

        let nextIndex = currentIndex + 1
        if nextIndex < data.count {
            self.currentIndex = nextIndex
        } else {
            self.currentIndex = nil
        }
        
        completion?(direction)
    }
    
    public func unswipe() {
        
        var currentIndex: Int! = self.currentIndex
        if currentIndex == nil {
            currentIndex = data.count
        }
        
        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            data[previousIndex].direction = nil
            self.currentIndex = previousIndex
        }
    }
    
}
