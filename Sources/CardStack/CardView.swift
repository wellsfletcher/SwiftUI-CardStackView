import SwiftUI

struct CardView<Direction: CardSwipeDirection, Content: View>: View {
    
    @Environment(\.cardStackConfiguration) private var configuration: CardStackConfiguration

    @State private var translation: CGSize = .zero
    
    private let isOnTop: Bool
    private let offset: CGSize
    private let onChange: (Direction?) -> Void
    private let onSwipe: (Direction, CGSize) -> Void
    private let content: (Direction?) -> Content
    
    init(
        isOnTop: Bool,
        offset: CGSize,
        onChange: @escaping (Direction?) -> Void,
        onSwipe: @escaping (Direction, CGSize) -> Void,
        @ViewBuilder content: @escaping (Direction?) -> Content
    ) {
        self.isOnTop = isOnTop
        self.offset = offset
        self.onChange = onChange
        self.onSwipe = onSwipe
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content(ongoingSwipeDirection(geometry))
                .offset(combinedOffsets)
                .rotationEffect(rotation(geometry))
                .simultaneousGesture(isOnTop ? dragGesture(geometry) : nil)
        }
    }
    
    private var combinedOffsets: CGSize {
        .init(width: offset.width + translation.width, height: offset.height + translation.height)
    }
    
    private func dragGesture(_ geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                translation = value.translation
                if let ongoingDirection = ongoingSwipeDirection(geometry) {
                    onChange(ongoingDirection)
                } else {
                    onChange(nil)
                }
            }
            .onEnded { value in
                if let direction = ongoingSwipeDirection(geometry) {
                    withAnimation(configuration.animation) {
                        translation = .zero
                        onSwipe(direction, translation)
                    }
                } else {
                    withAnimation { translation = .zero }
                }
            }
    }
    
    private var translationRadians: Angle {
        .radians(atan2(-translation.height, translation.width))
    }
    
    private func rotation(_ geometry: GeometryProxy) -> Angle {
        .degrees(Double(combinedOffsets.width / geometry.size.width) * 15)
    }
    
    private func ongoingSwipeDirection(_ geometry: GeometryProxy) -> Direction? {
        guard let direction = Direction.from(angle: translationRadians) else { return nil }
        let threshold = min(geometry.size.width, geometry.size.height) * configuration.swipeThreshold
        let distance = hypot(combinedOffsets.width, combinedOffsets.height)
        return distance > threshold ? direction : nil
    }
    
}
