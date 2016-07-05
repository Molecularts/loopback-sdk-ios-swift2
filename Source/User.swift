//
//  User.swift
//  LoopBackSwift
//
//  Created by Oscar Anton on 27/6/16.
//  Copyright © 2016 Molecularts. All rights reserved.
//

import Foundation
import ObjectMapper
import BrightFutures



public protocol UserModel: PersistedModel{
    var realm: String? { get  set }
    var username: String? { get  set }
    var password: String { get  set }
    var email: String { get  set }
    var emailVerified: Bool { get  set }

}

extension UserModel{
    public static func getCurrentUser<UserType where UserType:UserModel, UserType:ModelMappable>(_: UserType.Type) -> UserType?{
        return AccessTokenRepository<UserType>.currentUser
    }
    
    public static func setCurrentUser<UserType where UserType:UserModel, UserType:ModelMappable>(user:UserType?){
        AccessTokenRepository<UserType>.currentUser = user
    }
}

extension Repository where Model : UserModel{
    public func login(email: String, password: String) -> Future<Model, LoopBackError> {
        let accessTokenRepository : AccessTokenRepository = AccessTokenRepository<Model>(client: self.client)
        let promise : Promise = Promise<Model, LoopBackError>()
        
        accessTokenRepository.login(email, password: password)
        .onSuccess { (accessToken : AccessToken<Model>) in
            promise.success(accessToken.user!)

        }.onFailure { (error: LoopBackError) in
                promise.failure(error)
        }
        
        return promise.future
        
    }
    
    public func logout() -> Future<Bool,LoopBackError>{
        //let promise = Promise<Bool, LoopBackError>()
        let accessTokenRepository : AccessTokenRepository = AccessTokenRepository<Model>(client: self.client)
        return accessTokenRepository.logout(self.client.accessToken)

    }
    
    
    
}
