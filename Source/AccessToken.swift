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

public protocol AccessTokenModel : PersistedModel{
    var userId: ModelId? { get  set }
    var ttl: Int? { get  set }
    
}


struct AccessToken: PersistedModel, ModelMappable{
    var id: ModelId?
    var userId: ModelId?
    var ttl: Int?
    var created: String?
    
    
    internal static func modelName () -> String{
        return "AccessToken"
    }
    
    internal init?(_ map: Map) {
        
    }
    
    internal mutating func mapping(map: Map) {
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

