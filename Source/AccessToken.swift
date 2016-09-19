//
//  AccessToken.swift
//  LoopBackSwift
//
//  Created by Oscar Anton on 27/6/16.
//  Copyright © 2016 Molecularts. All rights reserved.
//

import Foundation
import ObjectMapper
import BrightFutures


public class AccessToken: PersistedModel, ModelMappable{
    public var id: ModelId?
    var userId: ModelId?
    var ttl: Int?
    var created: String?
    
    
    public static func modelName () -> String{
        return "AccessToken"
    }
    
    public required init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id                  <- map["id"]
        userId              <- map["userId"]
        ttl                 <- map["ttl"]
        created             <- map["created"]
        
    }
    
    static var current: AccessToken?{
        get{
            let defaults = NSUserDefaults.standardUserDefaults()
            let userDict: NSDictionary? = defaults.objectForKey(LoopBackConstants.currentAccessTokenObjectKey) as? NSDictionary
            return Mapper<AccessToken>().map(userDict)
        }
        
        set{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue?.toJSON(), forKey: LoopBackConstants.currentAccessTokenObjectKey)
        }
    }
}
