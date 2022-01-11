import UIKit

extension UIView {
          
    // Check if view is currently on screen.
    // Use case: view is on different ViewController then currently presented, it returns false.
    var isViewOnScreen: Bool {
        return window != nil
    }
    
    func addZeroConstraintsView(_ containedView: UIView,
                                constraintPriorityHorizontal: UILayoutPriority = .required,
                                constraintPriorityVertical: UILayoutPriority = .required) {
        addSubview(containedView)
        addConstraintsForContainedView(containedView, insets: .zero, constraintPriorityHorizontal: constraintPriorityHorizontal, constraintPriorityVertical: constraintPriorityVertical)
    }
    
    func addConstraintsViewWithInsets(_ containedView: UIView,
                                      insets: UIEdgeInsets,
                                      constraintPriorityHorizontal: UILayoutPriority = .required,
                                      constraintPriorityVertical: UILayoutPriority = .required) {
        addSubview(containedView)
        addConstraintsForContainedView(containedView, insets: insets, constraintPriorityHorizontal: constraintPriorityHorizontal, constraintPriorityVertical: constraintPriorityVertical)
    }
    
    func addConstraintsForContainedView(_ containedView: UIView,
                                        insets: UIEdgeInsets,
                                        constraintPriorityHorizontal: UILayoutPriority = .required,
                                        constraintPriorityVertical: UILayoutPriority = .required) {
        if containedView.translatesAutoresizingMaskIntoConstraints {
            containedView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let dictionary = ["containedView": containedView]
        let horizontalFormat = "H:|-(\(insets.left)@\(constraintPriorityHorizontal.rawValue))-[containedView]-(\(insets.right)@\(constraintPriorityHorizontal.rawValue))-|"
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalFormat,
                                                      options: [],
                                                      metrics: nil,
                                                      views: dictionary))
        
        let verticalFormat = "V:|-(\(insets.top)@\(constraintPriorityVertical.rawValue))-[containedView]-(\(insets.bottom)@\(constraintPriorityVertical.rawValue))-|"
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalFormat,
                                                      options: [],
                                                      metrics: nil,
                                                      views: dictionary))
    }
   
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
