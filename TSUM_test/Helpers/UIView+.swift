//
//  Copyright © 2019 Daria Gapanyuk. All rights reserved.
//

import UIKit

public typealias Constraint = (_ child: UIView, _ parent: UIView) -> NSLayoutConstraint

extension UIView {
    public func addSubview(_ child: UIView, constraints: [Constraint]) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { $0(child, self) })
    }
}

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

/// ````
/// childView.{axis}Anchor.constraint(equalTo: parentView.{axis}Anchor, constant: constant)
/// ````
public func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                                _ to: KeyPath<UIView, Anchor>,
                                constant: CGFloat = 0,
                                priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { child, parent in
        child[keyPath: keyPath].constraint(equalTo: parent[keyPath: to], constant: constant)
            .with(priority: priority)
    }
}

/// ````
/// childView.{axis}Anchor.constraint(equalTo: parentView.{axis}Anchor, constant: constant)
/// ````
public func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                                constant: CGFloat = 0,
                                priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return equal(keyPath, keyPath, constant: constant, priority: priority)
}

/// ````
/// childView.{axis}Anchor.constraint(equalTo: toView.{axis}Anchor, constant: constant)
/// ````
public func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                                to view: UIView,
                                _ to: KeyPath<UIView, Anchor>,
                                constant: CGFloat = 0,
                                priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { child, _ in
        child[keyPath: keyPath].constraint(equalTo: view[keyPath: to], constant: constant)
            .with(priority: priority)
    }
}

/// ````
/// childView.{dimension}Anchor.constraint(equalToConstant: constant)
/// ````
public func equal<Dimension>(_ keyPath: KeyPath<UIView, Dimension>,
                             constant: CGFloat = 0,
                             priority: UILayoutPriority = .required) -> Constraint where Dimension: NSLayoutDimension {
    return { child, _ in
        child[keyPath: keyPath].constraint(equalToConstant: constant)
            .with(priority: priority)
    }
}

