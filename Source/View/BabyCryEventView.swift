//
//  BabyCryEventView.swift
//  CodingAssignment2021
//
//  Created by Nimish Sharma on 12/20/21.
//

import SwiftUI

struct BabyCryEventView: View {
    
    @ObservedObject private var viewModel: BabyCryEventViewModel
    
    init(viewModel: BabyCryEventViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.babyCryEvents) { recognitionInfo in
                HStack {
                    Text(recognitionInfo.title)
                    Spacer()
                    Text(recognitionInfo.displayTime).foregroundColor(.purple)
                }
           }
           .navigationBarTitle(Text("Baby Cry Monitor"))
        }
        .onAppear(perform: viewModel.startListeningToUpdates)
        .onDisappear(perform: viewModel.stopListeningToUpdates)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    public func callToTest() {
        let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            viewModel.addTestData(BabyCryEvent(title: "baby crying...", timestamp: Date().timeIntervalSince1970))
        }
    }
}

struct BabyCryEventView_Previews: PreviewProvider {
    static var previews: some View {
        let view = BabyCryEventView(viewModel: BabyCryEventViewModel())
        view.callToTest()
        return view
    }
}
