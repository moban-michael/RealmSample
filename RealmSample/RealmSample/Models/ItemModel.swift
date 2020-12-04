//
//  ItemModel.swift
//  RealmSample
//
//  Created by Moban Michael on 02/12/2020.
//

import Foundation
import RealmSwift

 class ItemDbModel : Object {
    
    @objc dynamic var itemId: UUID      = UUID()
    @objc dynamic var dodiCode: String  = ""
    @objc dynamic var title: String     = ""
    
    override static func primaryKey() -> String? {
            return "itemId"
        }
    
    override init() {
        
    }
    
    convenience init(itemId: UUID, dodiCode: String, title: String){
        self.init()
        self.itemId     = itemId
        self.dodiCode   = dodiCode
        self.title      = title
    }
    
    convenience init(itemWebModel: ItemWebModel){
        self.init()
        self.itemId = itemWebModel.itemId
        self.dodiCode = itemWebModel.dodiCode!
        self.title = itemWebModel.title
    }
}

struct ItemUIModel :Identifiable {
    var id: UUID = UUID()
    var itemId: UUID
    var dodiCode: String?
    
    init(itemDbModel: ItemDbModel){
        
        self.itemId = itemDbModel.itemId
        self.dodiCode = itemDbModel.dodiCode
    }
}

struct ItemWebModel  {
    var itemId: UUID
    var dodiCode: String?
    var title: String = ""
}

//Alloy models
/*class ItemDbModel : Object {
    @objc dynamic var itemId: String = ""
    @objc dynamic var dodiCode: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var subtitle: String = ""
    @objc dynamic var colour: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var boundingBoxSwLat: Double = 0
    @objc dynamic var boundingBoxSwLon: Double = 0
    @objc dynamic var boundingBoxNeLat: Double = 0
    @objc dynamic var boundingBoxNeLon: Double = 0
    var attributes: List<ItemDbModelAttribute> = List()
    
    override static func primaryKey() -> String? {
        return "itemId"
    }
}

struct ItemMobileModel {
    var itemId: String?
    var dodiCode: String?
    var title: String?
    var subtitle: String?
    var colour: UIColor?
    var icon: String?
    var attributes: ItemMobileModelAttribute?
}

struct ItemMobileModelAttribute {
    var attributeCode: String?
    var valueString: String?
    var valueInt: Int?
    var valueDouble: Double?
    var valueBoolean: Bool?
    var valueDate: String?
    var valueDatetime: String?
    var valueTime: String?
    var valueSeasonal: String?
    var valueAqs: String?
    var valueJson: String?
    var valueGeoJson: String?
    var valueLink: List<String>?
}

 class ItemDbModelAttribute : Object {
    var attributeCode: String = ""
    var valueString: String = ""
    var valueInt: Int = 0
    var valueDouble: Double = 0
    var valueBoolean: Bool = true
    var valueDate: String = ""
    var valueDatetime: String = ""
    var valueTime: String = ""
    var valueSeasonal: String = ""
    var valueAqs: String = ""
    var valueJson: String = ""
    var valueGeoJson: String = ""
    var valueLink: List<String>?
}*/
