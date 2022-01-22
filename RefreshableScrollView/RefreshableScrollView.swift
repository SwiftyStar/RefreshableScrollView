//
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @StateObject private var viewModel = RefreshableScrollViewModel()
    
    private let content: () -> Content
    private let showsIndicators: Bool
    private let onRefresh: () async -> Void
    
    init(showsIndicators: Bool = true, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
    }
    
    private var topGeometryReader: some View {
        GeometryReader { geometry in
            Color.clear
                .framePreferenceKey(geometry.frame(in: .global)) { frame in
                    self.viewModel.update(topFrame: frame)
                }
        }
    }
    
    private var scrollViewGeometryReader: some View {
        GeometryReader { geometry in
            Color.clear
                .framePreferenceKey(geometry.frame(in: .global)) { frame in
                    self.viewModel.update(scrollFrame: frame)
                }
        }
    }
    
    var body: some View {
        VStack() {
            ActivityIndicator(size: self.$viewModel.progressViewHeight, isAnimating: self.$viewModel.isRefreshing)
                .frame(width: self.viewModel.progressViewHeight, height: self.viewModel.progressViewHeight)
                .background { self.topGeometryReader }
            
            ScrollView(.vertical, showsIndicators: self.showsIndicators) {
                self.content()
                    .background { self.scrollViewGeometryReader }
            }
        }
        .onChange(of: self.viewModel.isRefreshing) { isRefreshing in
            guard isRefreshing else { return }
            
            Task {
                await self.onRefresh()
                
                // In case the async method returns quickly.
                // We want to keep it refreshing for some time so it is smooth.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.viewModel.endRefreshing()
                }
            }
        }
    }
}

struct RefreshableScrollView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableScrollView(showsIndicators: true) {
            Text("Hi")
            Text("World")
            Text("Hello")
        } onRefresh: {
            print("Refreshing")
        }
    }
}
