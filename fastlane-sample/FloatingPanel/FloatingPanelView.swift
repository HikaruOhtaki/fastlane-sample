// Copyright 2021 the FloatingPanel authors. All rights reserved. MIT license.

import FloatingPanel
import SwiftUI

/// A proxy for exposing the methods of the floating panel controller.
public struct FloatingPanelProxy {
    /// The associated floating panel controller.
    public weak var fpc: FloatingPanelController?

    /// Tracks the specified scroll view to correspond with the scroll.
    ///
    /// - Parameter scrollView: Specify a scroll view to continuously and
    ///   seamlessly work in concert with interactions of the surface view.
    public func track(scrollView: UIScrollView) {
        fpc?.track(scrollView: scrollView)
    }

    /// Moves the floating panel to the specified position.
    ///
    /// - Parameters:
    ///   - FloatingPanelPosition: The state to move to.
    ///   - animated: `true` to animate the transition to the new state; `false`
    ///     otherwise.
    public func move(
        to floatingPanelState: FloatingPanelPosition,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        fpc?.move(to: floatingPanelState, animated: animated, completion: completion)
    }
}

/// A view with an associated floating panel.
struct FloatingPanelView<Content: View, FloatingPanelContent: View>: UIViewControllerRepresentable {
    /// A type that conforms to the `FloatingPanelControllerDelegate` protocol.
    var delegate: FloatingPanelControllerDelegate?

    /// The view builder that creates the floating panel parent view content.
    @ViewBuilder var content: Content

    /// The view builder that creates the floating panel content.
    @ViewBuilder var floatingPanelContent: (FloatingPanelProxy) -> FloatingPanelContent

    public func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = nil
        DispatchQueue.main.async {
            context.coordinator.setupFloatingPanel(hostingController)
        }
        return hostingController
    }

    public func updateUIViewController(
        _ uiViewController: UIHostingController<Content>,
        context: Context
    ) {
        context.coordinator.updateIfNeeded()
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    /// `FloatingPanelView` coordinator.
    ///
    /// Responsible to setup the view hierarchy and floating panel.
    final class Coordinator {
        private let parent: FloatingPanelView<Content, FloatingPanelContent>
        private lazy var fpc = FloatingPanelController()

        init(parent: FloatingPanelView<Content, FloatingPanelContent>) {
            self.parent = parent
        }

        func setupFloatingPanel(_ parentViewController: UIViewController) {
            updateIfNeeded()
            let panelContent = parent.floatingPanelContent(FloatingPanelProxy(fpc: fpc))
            let hostingViewController = UIHostingController(rootView: panelContent)
            hostingViewController.view.backgroundColor = nil
            fpc.isRemovalInteractionEnabled = true
            fpc.set(contentViewController: hostingViewController)
            fpc.addPanel(toParent: parentViewController, belowView: nil, animated: true)
        }

        func updateIfNeeded() {
            if fpc.delegate !== parent.delegate {
                fpc.delegate = parent.delegate
            }
        }
    }
}
