//
//  RealmDataManager.swift
//  RealmSample
//
//  Created by Moban Michael on 02/12/2020.
//

import Foundation
import Realm
import RealmSwift
import RxSwift


public class RealmDataManager {
    
    public typealias Completion = ((_ error: Error?) -> Void)

    static let shared   : RealmDataManager   = RealmDataManager()
    var realm           : Realm?
    var background      : RealmThread?
    
    init() {
        do {
            try realm = Realm()
        } catch  {
            fatalError(error.localizedDescription)
        }
        
    }
    
//    init(configuration: Realm.Configuration?, fileUrl: URL?) {
//
//        background = RealmThread(start: true, queue: nil)
//
//        background?.enqueue {[weak self] in
//            guard let self = self else { return }
//            do {
//                if let config = configuration {
//                    self.realm = try Realm(configuration: config)
//                } else if let fileUrl = fileUrl {
//                    self.realm = try Realm(fileURL: fileUrl)
//                } else {
//                    self.realm = try Realm()
//                }
//            } catch let error {
//                fatalError(error.localizedDescription)
//            }
//        }
//    }
}

extension RealmDataManager {
    
    func openFile()  {
        do {
            realm =  try Realm()
        } catch  {
            print("DB file error")
        }
    }
    
    func getFileUrl() -> URL?{
        
        if let fileUrl = Realm.Configuration.defaultConfiguration.fileURL{
            print(fileUrl)
            return fileUrl
        }
        return nil
    }
    
    //MARK: Insert
    func insertObject(obj : Object) -> Observable<Bool>{
        
        return Observable<Bool>.create { observer in
            
            do{
                try self.realm?.write {
                    self.realm?.add(obj)
                    print("Insert Sucessfullly")
                    observer.onNext(true)
                }
            }catch{
                print(error)
                observer.onNext(false)
            }
            
            return Disposables.create {
            }
        }
    }
    
    //MARK: Fetch
    func fetchAllObjects() -> Observable<Results<ItemDbModel>> {
        
        return Observable<Results<ItemDbModel>>.create { observer in
            let results = self.realm?.objects(ItemDbModel.self)//.sorted("itemId", ascending: true)
            print("Results : \(String(describing: results))")
            observer.onNext(results!)
            return Disposables.create {
            }
        }
    }
    
    func fetchUsingPredicate(predicate: NSPredicate) -> Results<ItemDbModel> {
        //let predicate = NSPredicate(format: "name BEGINSWITH [c]%@", searchString);
        let results = self.realm?.objects(ItemDbModel.self).filter(predicate).sorted(byKeyPath: "itemId", ascending: true)
        return results!
    }
}

extension RealmDataManager{
    
    fileprivate func addOrUpdateWithRealm<Q: Collection>(realm: Realm,
                                                         object: Q,
                                                         completion: @escaping Completion) where Q.Element == Object  {
        do {
            try realm.write {
                realm.add(object,
                          update: .error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch (let error) {
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }

    fileprivate func addOrUpdateWithRealm<T: Object>(realm: Realm,
                                                     object: T,
                                                     completion: @escaping Completion) {
        do {
            try realm.write {
                realm.add(object,
                          update: .error)

                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch (let error) {
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }

    fileprivate func write(rlmObject: Realm, writeBlock:()-> Void) -> Error? {
        do {
            //try to do a realm transaction
            try rlmObject.write {
                writeBlock()
            }
        } catch let error {
            //catch and return the error if occurs
            return error
        }
        //no error
        return nil
    }

    fileprivate func fetch<Q: Object>(condition: String?,
                                      completion: @escaping(_ result: Results<Q>) -> Void) {

        guard let realm = realm else { return }

        // All object inside the model passed.
        var bufferObjects = realm.objects(Q.self)

        if let cond = condition {
            // filters the result if condition exists
            bufferObjects = bufferObjects.filter(cond)
        }

        DispatchQueue.main.async {
//            if let safe = bufferObjects.copy() as? Results<Q> {
//                completion(safe)
//            }
        }
    }
}

//extension RealmDataManager where T: Collection, T.Element == Object {
//
//    /// Add or Update an object to existing Model
//    ///
//    /// Accept any object that conforms to Collection Protocol,
//    /// Takes a closure as escaping
//    /// parameter.
//    ///
//    /// - Parameter object: [Object] to be saved.
//    /// - Parameter completion: Closure called after
//    ///   realm transaction
//    /// - Parameter error: an optional value containing error
//    public func addOrUpdate(object: T,
//                            completion:@escaping Completion) {
//
//        background?.enqueue {[weak self] in
//            guard let self = self else { return }
//
//            guard let realm = self.realm else { return }
//
//            self.addOrUpdateWithRealm(realm: realm,
//                                      object: object,
//                                      completion: completion)
//        }
//    }
//
//    //MARK: - File Private
//    fileprivate func delete(condition: String?,
//                            objects: T,
//                            completion:@escaping(_ error: Error?) -> Void) {
//        let group = DispatchGroup()
//        var error: Error?
//
//        background?.enqueue {[weak self] in
//            group.enter()
//            guard let self = self else { return }
//            guard let realm = self.realm else { return }
//
//            error = self.write(rlmObject: realm, writeBlock: {
//                realm.delete(objects)
//                group.leave()
//            })
//        }
//
//        group.wait()
//        DispatchQueue.main.async {
//            completion(error)
//        }
//    }
//}

//extension RealmDataManager where T: Object {
//    /// Add or Update an object to existing Model
//    ///
//    /// Accept any object that is a subclass of Object or RealmObject,
//    /// Takes a closure as escaping
//    /// parameter.
//    ///
//    /// - Parameter object: Object to be saved.
//    /// - Parameter completion: Closure called after
//    ///   realm transaction
//    /// - Parameter error: an optional value containing error
//    public func addOrUpdate(configuration: Realm.Configuration? = nil,
//                            object: T,
//                            completion: @escaping Completion) {
//        background?.enqueue {[weak self] in
//            guard let self = self else { return }
//
//            guard let realm = self.realm else { return }
//
//            self.addOrUpdateWithRealm(realm: realm,
//                                      object: object,
//                                      completion: completion)
//        }
//    }
//
//    /// Fetches object from existing model
//    ///
//    ///
//    /// - Parameter type: Type representing the object to be fetch, must be
//    /// subclass of Object
//    /// - Parameter condition: Predicate to be used when fetching
//    ///   data from the Realm database (Optional: String)
//    /// - Parameter completion: Closure called after the
//    ///   realm transaction
//    /// - Parameter result: An Array of Object as result from
//    ///   the fetching
//    public func fetchWith(condition: String?,
//                          completion:@escaping(_ result: Results<T>) -> Void) {
//
//        background?.enqueue {[weak self] in
//            guard let self = self else { return }
//
//            self.fetch(condition: condition,
//                       completion: completion)
//        }
//    }
//
//    /// Deletes an object from the existing model
//    ///
//    ///
//    /// - Parameter configuration: Realm Configuration to be used
//    /// - Parameter model: A string of any class NAME that inherits from 'Object' class
//    /// - Parameter condition: Predicate to be used when deleting
//    ///   data from the Realm database (Optional: String)
//    /// - Parameter completion: Closure called after the
//    ///   realm transaction
//    /// - Parameter error: an optional value containing error
//    public func deleteWithObject(_ object: T?,
//                                 condition: String,
//                                 completion:@escaping(_ error: Error?) -> Void) {
//
//        background?.enqueue {[weak self] in
//            guard let self = self else { return }
//
//            self.delete(object: object,
//                        condition: condition,
//                        completion: completion)
//        }
//    }
//
//    ///MARK: FilePrivates
//    fileprivate func delete(object: T?,
//                            condition: String?,
//                            completion:@escaping(_ error: Error?) -> Void) {
//        guard let realm = realm else { return }
//
//        let group = DispatchGroup()
//        var error: Error?
//
//        background?.enqueue {[weak self] in
//            group.enter()
//            guard let self = self else { return }
//
//            if object == nil {
//                var fetched = realm.objects(T.self)
//
//                if let cond = condition {
//                    // filters the result if condition exists
//                    fetched = fetched.filter(cond)
//                }
//
//                error = self.write(rlmObject: realm, writeBlock: {
//                    realm.delete(fetched)
//                    group.leave()
//                })
//            } else {
//                if let object = object {
//                    error = self.write(rlmObject: realm, writeBlock: {
//                        realm.delete(object)
//                        group.leave()
//                    })
//                }
//            }
//        }
//
//        group.wait()
//        DispatchQueue.main.async {
//            completion(error)
//        }
//    }
//}
