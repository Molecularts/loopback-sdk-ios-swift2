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


public class AccessToken: AccessTokenModel, ModelMappable{
    public var id: ModelId?
    public var userId: ModelId?
    public var ttl: Int?
    public var created: String?
    
    
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


public class AccessTokenRepository <UserType where UserType: UserModel, UserType: Mappable> : Repository <AccessToken>{
    public override init(client: LoopBackClient, path: String? = nil){
        super.init(client: client, path: path)
        
    }
    
    
    
    
}