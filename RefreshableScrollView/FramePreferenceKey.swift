//
//


import SwiftUI

/// There might be an existing preference key that does the same thing. But I haven't found good documentation with all of the existing preference keys.
struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    func framePreferenceKey(_ value: CGRect, onFrameChange: @escaping (CGRect) -> Void) -> some View {
        self
            .preference(key: FramePreferenceKey.self, value: value)
            .onPreferenceChange(FramePreferenceKey.self, perform: onFrameChange)
    }
}
