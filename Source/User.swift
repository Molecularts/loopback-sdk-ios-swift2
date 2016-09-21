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
import ObjectMapper



public protocol UserModel: PersistedModel{
    var realm: String? { get  set }
    var username: String? { get  set }
    var password: String { get  set }
    var email: String { get  set }
    var emailVerified: Bool { get  set }
    
}

extension Repository where Model : UserModel{
    public func login(email: String, password: String) -> Future<Model, LoopBackError> {
        let promise : Promise = Promise<Model, LoopBackError>()
        
        let params:[String: AnyObject] = ["email" : email, "password": password]
        let request: Request = self.prepareRequest(.POST, absolutePath: Model.modelName() + "/login", parameters: params)
        
        request.responseObject {  (response : Response<AccessToken, NSError>) in
            
            
            
            guard (response.result.isSuccess)
                else{
                    let jsonString = NSString(data: response.data!, encoding: NSASCIIStringEncoding)
                    var error: LoopBackError? = Mapper<LoopBackError>().map(jsonString!)
                    error?.error = response.result.error
                    promise.failure(error!)
                    return
                    
            }
            
            
            let model = response.result.value
            
            self.client.accessToken = model?.id
            
            AccessToken.current = model
            
            self.findById((model?.userId)!).onSuccess(callback: { (user: Model) in
                self.currentUser = user
                promise.success(user)
            }).onFailure(callback: { (error: LoopBackError) in
                promise.failure(error)
            })
        }
        
        return promise.future
        
        
    }
    
    public func logout() -> Future<Bool,LoopBackError>{
        let promise = Promise<Bool, LoopBackError>()
        
        if(self.client.accessToken  != nil){
            let request: Request = prepareRequest(.POST, absolutePath: Model.modelName() + "/logout", parameters: ["access_token": self.client.accessToken!])
            processAnyRequest(request).onSuccess { (anyObject: AnyObject) in
                self.client.accessToken = nil
                AccessToken.current = nil
                self.currentUser = nil
                
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
    
    public var currentUser: Model?{
        get{
            return Repository<Model>.currentUser
        }
        
        set {
            Repository<Model>.currentUser = newValue
        }
    }
    
    public static var currentUser: Model?{
        get{
            let defaults = NSUserDefaults.standardUserDefaults()
            let userDict: NSDictionary? = defaults.objectForKey(LoopBackConstants.currentUserKey) as? NSDictionary
            return Mapper<Model>().map(userDict)
        }
        
        set(newUser){
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newUser?.toJSON(), forKey: LoopBackConstants.currentUserKey)
        }
    }
    
    
    
}
