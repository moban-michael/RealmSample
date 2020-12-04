//
//  ItemListViewModel.swift
//  RealmSample
//
//  Created by Moban Michael on 02/12/2020.
//

import Foundation
import RxSwift

class ItemListViewModel: ObservableObject {
    
    private let disposeBag = DisposeBag()
    @Published private(set) var items : [ItemUIModel] = []
    
    func loadData() -> Observable<[ItemUIModel]>{
        
        return Observable<[ItemUIModel]>.create { observer in
            var obj = ItemWebModel(itemId: UUID())
            obj.dodiCode = "testDodi"
            obj.title = "testTitle"
            self.insertAndFetchFromDB(itemWebModel: obj).asObservable().subscribe { (event) in
                if let uiObjs = event.element, uiObjs.count > 0{
                    self.items = uiObjs
                }
            }.disposed(by: self.disposeBag)
            return Disposables.create {
            }
        }
    }
    
    func insertAndFetchFromDB(itemWebModel: ItemWebModel) -> Observable<[ItemUIModel]>{
        
        return Observable<[ItemUIModel]>.create { observer in
            let dbObj = ItemDbModel(itemWebModel: itemWebModel)
            //Insert
            self.insertIntoDB(obj: dbObj).asObservable().subscribe { (event) in
                if let isDataInserted = event.element, isDataInserted{
                    //fetch
                    self.fetchFromDB().asObservable().subscribe { (event) in
                        if let dbObjects = event.element,dbObjects.count > 0{
                            var uiObjects: [ItemUIModel] = []
                            //convert db object to ui ibject
                            for dbObj in dbObjects{
                                let uiObj = ItemUIModel.init(itemDbModel: dbObj)
                                uiObjects.append(uiObj)
                            }
                            observer.onNext(uiObjects)
                        }
                    }.disposed(by: self.disposeBag)
                }
            }.disposed(by: self.disposeBag)
            return Disposables.create {
            }
        }
    }
    
    func insertIntoDB(obj:ItemDbModel)-> Observable<Bool>{
        
        return Observable<Bool>.create { observer in
            RealmDataManager.shared.insertObject(obj: obj).asObservable().subscribe({ (event) in
                if let isDataInserted = event.element, isDataInserted{
                    print("Insert sucessfully : \(isDataInserted)")
                }
            }).disposed(by: self.disposeBag)
            return Disposables.create {
            }
        }
    }
    
    func fetchFromDB() -> Observable<[ItemDbModel]> {
        
        return Observable<[ItemDbModel]>.create { observer in
            
            //        let results = RealmDataManager.shared.realm?.objects(ItemDbModel.self)
            //        print("fetch sucessfully : \(String(describing: results?.count))")
            //        return results
            
            RealmDataManager.shared.fetchAllObjects().asObservable().subscribe { (event) in
                if let results = event.element {
                    var dbObjects: [ItemDbModel] = []
                    for result in results{
                        let dbObj = ItemDbModel.init(itemId: result.itemId, dodiCode: result.dodiCode, title: result.title)
                        dbObjects.append(dbObj)
                    }
                    observer.onNext(dbObjects)
                }
            }.disposed(by: self.disposeBag)
            
            return Disposables.create {
            }
        }
    }
}
