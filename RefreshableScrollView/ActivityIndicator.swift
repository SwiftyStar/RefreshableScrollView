//
//


import SwiftUI

final class ActivityIndicator: UIViewRepresentable {
    @Binding var size: CGFloat
    @Binding var isAnimating: Bool
    private let style: UIActivityIndicatorView.Style
    
    init(style: UIActivityIndicatorView.Style = .medium, size: Binding<CGFloat>, isAnimating: Binding<Bool>) {
        self._size = size
        self._isAnimating = isAnimating
        self.style = style
    }
    
    func makeUIView(context: Context) -> UIView {
        let activityIndicator = UIActivityIndicatorView(style: self.style)
        activityIndicator.hidesWhenStopped = false

        if self.isAnimating {
            activityIndicator.startAnimating()
        }

        let containerView = UIView()
        containerView.layer.cornerRadius = self.size / 2
        containerView.clipsToBounds = true
        
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator
            .centerXAnchor
            .constraint(equalTo: containerView.centerXAnchor)
            .isActive = true
        activityIndicator
            .centerYAnchor
            .constraint(equalTo: containerView.centerYAnchor)
            .isActive = true
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.cornerRadius = self.size / 2
        
        guard let activityIndicator = uiView.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView
        else { return }
        
        if self.isAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
