//
//  ViewController.swift
//  CodingAssignment2021
//
//  Created by Jeff Huang on 1/19/21.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    let contentView = UIHostingController(rootView: {() -> BabyCryEventView in
        let viewModel = BabyCryEventViewModel()
        return BabyCryEventView(viewModel: viewModel)
    }())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(contentView)
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        setupConstraints()
    }

    fileprivate func setupConstraints() {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
    }
    
}


// MARK: SwiftUI Preview
#if DEBUG
struct ContentViewControllerContainerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct ContentViewController_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentViewControllerContainerView().colorScheme(.dark).previewInterfaceOrientation(.portrait)
        } else {
            // Fallback on earlier versions
            ContentViewControllerContainerView().preferredColorScheme(.none)
        }
    }
}
#endif
