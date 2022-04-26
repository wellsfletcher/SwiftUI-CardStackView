//
//  ContentView.swift
//  Example
//
//  Created by Deniz Adalar on 13/04/2020.
//  Copyright © 2020 Dadalar It Software. All rights reserved.
//

import CardStack
import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    let name: String
    let image: UIImage
    let distance: Int = { .random(in: 1..<20) }()
    
    static let mock: [Person] = [
        Person(name: "Niall Miller", image: UIImage(named: "1")!),
        Person(name: "Sammy Smart", image: UIImage(named: "2")!),
        Person(name: "Edie Bain", image: UIImage(named: "3")!),
        Person(name: "Gia Velez", image: UIImage(named: "4")!),
        Person(name: "Harri Devine", image: UIImage(named: "5")!),
    ]
    
    static func random() -> Person {
        let randomPerson = Person.mock.randomElement()!
        return Person(name: randomPerson.name, image: randomPerson.image)
    }
}

struct CardView: View {
    let person: Person
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Image(uiImage: self.person.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: geo.size.width)
                    .clipped()
                HStack {
                    Text(self.person.name)
                    Spacer()
                    Text("\(self.person.distance) km away")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }
}

struct CardViewWithThumbs: View {
    let person: Person
    let direction: LeftRight?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .topLeading) {
                CardView(person: person)
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .foregroundColor(Color.green)
                    .opacity(direction == .right ? 1 : 0)
                    .frame(width: 100, height: 100)
                    .padding()
            }
            
            Image(systemName: "hand.thumbsdown.fill")
                .resizable()
                .foregroundColor(Color.red)
                .opacity(direction == .left ? 1 : 0)
                .frame(width: 100, height: 100)
                .padding()
        }
        .animation(.default)
    }
}

struct Basic: View {
    @State var model = CardStackModel<_, LeftRight>(Person.mock)
    
    var body: some View {
        CardStack(
            model: model,
            onSwipe: { card, direction in
                print("Swiped \(card.name) to \(direction)")
            },
            content: { person, _ in
                CardView(person: person)
            }
        )
        .padding()
        .scaledToFit()
        .frame(alignment: .center)
        .navigationBarTitle("Basic", displayMode: .inline)
    }
}

struct Thumbs: View {
    @State var model = CardStackModel<_, LeftRight>(Person.mock)
    
    var body: some View {
        CardStack(
            model: model,
            onSwipe: { card, direction in
                print("Swiped \(card.name) to \(direction)")
            },
            content: { person, direction in
                CardViewWithThumbs(person: person, direction: direction)
            }
        )
        .padding()
        .scaledToFit()
        .frame(alignment: .center)
        .navigationBarTitle("Thumbs", displayMode: .inline)
    }
}

struct AddingCards: View {
    @State var model = CardStackModel<_, LeftRight>(Person.mock)
    
    var body: some View {
        CardStack(
            model: model,
            onSwipe: { _, _ in
                model.addElement(Person.random())
            },
            content: { person, _ in
                CardView(person: person)
            }
        )
        .padding()
        .scaledToFit()
        .frame(alignment: .center)
        .navigationBarTitle("Adding cards", displayMode: .inline)
    }
}

struct ReloadCards: View {
    @State var reloadToken = UUID()
    @State var model = CardStackModel<_, LeftRight>(Person.mock.shuffled())
    
    var body: some View {
        CardStack(
            model: model,
            onSwipe: { card, direction in
                print("Swiped \(card.name) to \(direction)")
            },
            content: { person, _ in
                CardView(person: person)
            }
        )
        .id(reloadToken)
        .padding()
        .scaledToFit()
        .frame(alignment: .center)
        .navigationBarTitle("Reload cards", displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    self.reloadToken = UUID()
                    self.model = CardStackModel<_, LeftRight>(Person.mock.shuffled())
                }) {
                    Text("Reload")
                }
        )
    }
}

struct ProgrammaticCards: View {
    @State var model = CardStackModel<_, LeftRight>(Person.mock)
    
    var body: some View {
        VStack {
            CardStack(
                model: model,
                onSwipe: { card, direction in
                    print("Swiped \(card.name) to \(direction)")
                },
                content: { person, direction in
                    CardViewWithThumbs(person: person, direction: direction)
                }
            )
            .padding()
            .scaledToFit()
            
            HStack {
                Button {
                    withAnimation {
                        model.swipe(direction: .right, completion: nil)
                    }
                } label: {
                    Image(systemName: "hand.thumbsup.fill")
                        .resizable()
                        .foregroundColor(Color.green)
                        .frame(width: 50, height: 50)
                        .padding()
                }
                Button {
                    withAnimation {
                        model.swipe(direction: .left, completion: nil)
                    }
                } label: {
                    Image(systemName: "hand.thumbsdown.fill")
                        .resizable()
                        .foregroundColor(Color.red)
                        .frame(width: 50, height: 50)
                        .padding()
                }
            }.padding(.top, 50)
        }
        .frame(alignment: .center)
        .navigationBarTitle("Programmatic", displayMode: .inline)
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        model.unswipe()
                    }
                }) {
                    Text("Undo")
                }
        )
    }
}

struct CustomDirection: View {
    enum MyDirection: CardSwipeDirection {
        case up, down
        
        static func from(angle: Angle) -> MyDirection? {
            switch angle.normalized.degrees {
            case 45 ..< 135: return .up
            case 225 ..< 315: return .down
            default: return nil
            }
        }
        
        var angle: Angle {
            switch self {
            case .up: return .degrees(90)
            case .down: return .degrees(270)
            }
        }
    }
    
    @State var model = CardStackModel<_, MyDirection>(Person.mock)
    
    var body: some View {
        CardStack(
            model: model,
            onSwipe: { card, direction in
                print("Swiped \(card.name) to \(direction)")
            },
            content: { person, _ in
                CardView(person: person)
            }
        )
        .padding()
        .scaledToFit()
        .frame(alignment: .center)
        .navigationBarTitle("Custom direction", displayMode: .inline)
    }
}

struct CustomConfiguration: View {
    @State var model = CardStackModel<_, LeftRight>(Person.mock)
    
    var body: some View {
        CardStack(
            model: model,
            onSwipe: { card, direction in
                print("Swiped \(card.name) to \(direction)")
            },
            content: { person, _ in
                CardView(person: person)
            }
        )
        .environment(
            \.cardStackConfiguration,
             CardStackConfiguration(
                maxVisibleCards: 3,
                swipeThreshold: 0.1,
                cardOffset: 40,
                cardScale: 0.2,
                animation: .linear
             )
        )
        .padding()
        .scaledToFit()
        .frame(alignment: .center)
        .navigationBarTitle("Custom configuration", displayMode: .inline)
    }
}

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Basic()) {
                    Text("Basic")
                }
                NavigationLink(destination: Thumbs()) {
                    Text("Thumbs")
                }
                NavigationLink(destination: AddingCards()) {
                    Text("Adding cards")
                }
                NavigationLink(destination: ReloadCards()) {
                    Text("Reload cards")
                }
                NavigationLink(destination: ProgrammaticCards()) {
                    Text("Programmatic")
                }
                NavigationLink(destination: CustomDirection()) {
                    Text("Custom direction")
                }
                NavigationLink(destination: CustomConfiguration()) {
                    Text("Custom configuration")
                }
            }
            .navigationBarTitle("Examples")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

