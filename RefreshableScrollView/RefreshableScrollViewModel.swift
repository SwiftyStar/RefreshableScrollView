//
//

import SwiftUI
import Combine

final class RefreshableScrollViewModel: ObservableObject {
    @Published var progressViewHeight: CGFloat = 0
    @Published var isRefreshing = false
    
    let progressViewMaxHeight: CGFloat
    private let scrollPositionSubject = CurrentValueSubject<CGFloat, Never>(0)
    private let closingAnimationDuration: Double = 0.15
    private var subscriptions: Set<AnyCancellable> = []
    
    private var topYValue: CGFloat?
    private var scrollYValue: CGFloat?
    private var startingDistance: CGFloat?
    private var isClosing = false
    
    /// - Parameter activityIndicatorStyle: Used to derive the size of the indicator. Might be better to get in another way. In case Apple changes the sizes
    init(activityIndicatorStyle: UIActivityIndicatorView.Style = .medium) {
        self.progressViewMaxHeight = activityIndicatorStyle == .large ? 35 : 27
        self.reactToScrollEnding()
    }
    
    private func reactToScrollEnding() {
        self.scrollPositionSubject
            .debounce(for: 0.1, scheduler: RunLoop.main, options: nil)
            .sink { [weak self] _ in
                guard self?.progressViewHeight != 0,
                      self?.isRefreshing != true
                else { return }
                
                self?.reset()
            }
            .store(in: &self.subscriptions)
    }
    
    /// Updates the progressViewHeight and progressViewIsAnimating properties based on the given topFrame and any existing scrollYValue, if any
    /// - Parameter topFrame: CGRect
    func update(topFrame: CGRect) {
        let topY = topFrame.minY
        self.topYValue = topY
        guard let scrollY = self.scrollYValue else { return }
        
        self.update(topY: topY, scrollY: scrollY)
    }
    
    /// Updates the progressViewHeight and progressViewIsAnimating properties based on the given scrollFrame and any existing topYValue, if any
    /// - Parameter scrollFrame: CGRect
    func update(scrollFrame: CGRect) {
        let scrollY = scrollFrame.minY
        self.scrollYValue = scrollY
        self.scrollPositionSubject.send(scrollY)
        guard let topY = self.topYValue else { return }
        
        self.update(topY: topY, scrollY: scrollY)
    }
    
    /// Stops refreshing and hides the progress view
    func endRefreshing() {
        self.reset()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.closingAnimationDuration) {
            self.isRefreshing = false
        }
    }
    
    private func reset() {
        self.isClosing = true
        let topY = self.topYValue ?? 0
        let startDistance = self.startingDistance ?? 0
        let startingScrollYValue = topY + startDistance
        self.scrollYValue = startingScrollYValue
        
        withAnimation(.linear(duration: self.closingAnimationDuration)) {
            self.progressViewHeight = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.closingAnimationDuration) {
            self.isClosing = false
        }
    }
    
    private func update(topY: CGFloat, scrollY: CGFloat) {
        // Don't react to updates while animating closed
        guard !self.isClosing else { return }
        
        let newDistance = max(scrollY - topY, 0)
        
        if self.startingDistance == nil {
            self.startingDistance = newDistance
        }
        
        let differenceFromStart = newDistance - self.startingDistance!
        let constrainedDifference = min(max(differenceFromStart, 0), self.progressViewMaxHeight)
        
        // Don't change the height of the progress view if we are refreshing
        guard !isRefreshing else { return }
        
        DispatchQueue.main.async {
            self.progressViewHeight = constrainedDifference
            self.isRefreshing = constrainedDifference == self.progressViewMaxHeight
        }
    }
}
