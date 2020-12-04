//
//  ItemListView.swift
//  RealmSample
//
//  Created by Moban Michael on 02/12/2020.
//

import SwiftUI
import RxSwift

struct ItemListView: View {
    
    private let disposeBag      = DisposeBag()
    //@ObservedObject var viewModel: ItemListViewModel
    
    @State var items : [ItemUIModel] = []
    
    func loadData()  {
        ItemListViewModel().loadData().asObservable().subscribe { (event) in
            if let uiObjects = event.element {
                self.items = uiObjects
            }
        }.disposed(by: disposeBag)
    }
    
    var body: some View {
        NavigationView {
            List(items) { item in

                NavigationLink(destination: Text(item.itemId!)) {
                    Image(systemName: "photo")
                    VStack(alignment: .leading) {
                        Text(item.itemId!)
                        Text(item.dodiCode!)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle(Text("Items"))
        }
        .onAppear {loadData()}
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
    }
}
