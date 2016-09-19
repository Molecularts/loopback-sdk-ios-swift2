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



public class AccessToken <UserType where UserType:UserModel, UserType:Mappable>: AccessTokenModel, ModelMappable{
    private var _id:ModelId? = nil
    public var id: ModelId?{
        get{
            return _id
        }
        set{
            _id = newValue
        }
    }
    
    public var userId: ModelId?
    public var ttl: Int?
    public var user: UserType?
    
    public static func modelName () -> String{
        return "AccessToken"
    }
    
    public required init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id                  <- map["id"]
        userId              <- map["token"]
        user              <- map["user"]
        
    }
}



public class AccessTokenRepository <UserType where UserType: UserModel, UserType: Mappable> : Repository <AccessToken<UserType>>{
    public override init(client: LoopBackClient, path: String? = nil){
        super.init(client: client, path: path)

    }

    static var currentUser: UserType?{
        get{
            let defaults = NSUserDefaults.standardUserDefaults()
            let userDict: NSDictionary? = defaults.objectForKey(LoopBackConstants.currentUserKey) as? NSDictionary
            return Mapper<UserType>().map(userDict)
        }
        
        set(newUser){
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newUser?.toJSON(), forKey: LoopBackConstants.currentUserKey)
        }
    }
    
    
    public func login(email: String, password: String, include: [String]? = ["user"]) -> Future<AccessToken<UserType>, LoopBackError> {
        let promise = Promise<AccessToken<UserType>, LoopBackError>()
        
        let params:[String: AnyObject] = ["email" : email, "password": password, "include": include!]
        let request: Request = self.prepareRequest(.POST, absolutePath: UserType.modelName() + "/login?include=user", parameters: params)
        
        self.processObjectRequest(request, key: "login").onSuccess { (accessToken : AccessToken<UserType>) in
            self.client.accessToken = accessToken.id
            AccessTokenRepository<UserType>.currentUser = accessToken.user
            promise.success(accessToken)
        }.onFailure { (error: LoopBackError) in
            promise.failure(error)
        }
        
        return promise.future
        
    }
    
    
    public func logout(accessToken: ModelId?) -> Future<Bool, LoopBackError> {
        
        let promise = Promise<Bool, LoopBackError>()
        
        if(accessToken != nil){
            let request: Request = prepareRequest(.POST, absolutePath: UserType.modelName() + "/logout", parameters: ["access_token": self.client.accessToken!])
            processAnyRequest(request).onSuccess { (anyObject: AnyObject) in
                    self.client.accessToken = nil
                    AccessTokenRepository<UserType>.currentUser = nil
                    promise.success(true)
                }.onFailure { (error : LoopBackError) in
                    promise.failure(error)
            }
        }else{
            let error = LoopBackError(httpCode: .UnprocessableEntity, message: "You dont have a valid AccessToken, please login first")
            promise.failure(error)
        }
        
        
        return promise.future
        
    }
}