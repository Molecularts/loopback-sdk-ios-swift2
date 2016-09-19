//
//  Repository.swift
//  LoopBackSwift
//
//  Created by Oscar Anton on 27/6/16.
//  Copyright © 2016 Molecularts. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import BrightFutures

public typealias ModelId  = AnyObject


public protocol PersistedModel{
    var id: ModelId? { get  set }
    static func modelName() -> String
    
}


public class Repository <Model where  Model:PersistedModel,  Model:Mappable>{
    public var client : LoopBackClient
    public var path: String
    
    public init(client: LoopBackClient, path: String? = nil){
        self.client = client
        self.path = (path != nil) ? path! : Model.modelName()
        
    }
    
    public func resourcePath(pathComponents:[String]?) -> String{
        var baseUrl : NSURL =   self.client.baseURL.URLByAppendingPathComponent(self.path)!
        if (pathComponents != nil){
            for component in pathComponents! {
                baseUrl = baseUrl.URLByAppendingPathComponent(component)!

            }
        }
        
        return baseUrl.absoluteString!
    }
    
    public func absolutePath(relativePath:String) -> String{
        let baseUrl : NSURL =   self.client.baseURL.URLByAppendingPathComponent(relativePath)!
        
        return baseUrl.absoluteString!
    }
    
    public func findById(id : AnyObject) -> Future<Model, LoopBackError>{
        let request: Request = prepareRequest(.GET  , pathComponents: [id as! String])
        return self.processObjectRequest(request)
    }
    
    public func findOne(filter : Filter?) -> Future<Model, LoopBackError> {
        let parameters :[String: AnyObject]?  = filter?.toRequestParametters()
        
        let request: Request = prepareRequest(.GET, pathComponents: ["findOne"], parameters: parameters, encoding:.URL)
        return self.processObjectRequest(request)
        
    }
    
    public func find(filter : Filter?) -> Future<[Model], LoopBackError> {
        let parameters :[String: AnyObject]?  = filter?.toRequestParametters()
        
        let request: Request = prepareRequest(.GET, parameters: parameters, encoding:.URL)
        return self.processArrayRequest(request)
        
    }
    
    public func save(model: Model) -> Future<Model,LoopBackError>{
        let request: Request = prepareRequest(.POST, parameters:model.toJSON(), encoding: .JSON)
        return self.processObjectRequest(request)
    }
    
    public func upsert(model: Model) -> Future<Model,LoopBackError>{
        let request: Request = prepareRequest(.PUT, parameters:model.toJSON(), encoding: .JSON)
        return self.processObjectRequest(request)
    }
    
    public func update(model: Model) -> Future<Model,LoopBackError>{
        if(model.id != nil){
            let request: Request = prepareRequest(.PUT, parameters:model.toJSON(), encoding: .JSON, pathComponents: [model.id as! String])
            return self.processObjectRequest(request)
        }else{
            let promise = Promise<Model,LoopBackError>()
            let error: LoopBackError = LoopBackError(httpCode: .UnprocessableEntity, message: "A valid model id is required for update, use upsert or save instead.")
            promise.failure(error)
            return promise.future
        }
        
    }
    
    public func delete(id : AnyObject) -> Future<Bool, LoopBackError>{
        let request: Request = prepareRequest(.DELETE  , pathComponents: [id as! String])

        let promise = Promise<Bool, LoopBackError>()
        
        processAnyRequest(request).onSuccess { (anyObject: AnyObject) in
            if(anyObject is NSDictionary){
                let jsonData = anyObject as! NSDictionary
                let count : Int = jsonData["count"] as! Int
                promise.success(count > 0)
            }else{
                let error = LoopBackError(httpCode: .UnprocessableEntity, message: "Unexpected response")
                promise.failure(error)
                
            }
            
            }.onFailure { (error : LoopBackError) in
                promise.failure(error)
        }
        return promise.future
    }
    
    
    public func updateAttributes(id: ModelId, attributes: [String: AnyObject]) -> Future<Model,LoopBackError>{
        let request: Request = prepareRequest(.PUT, parameters:attributes, encoding: .JSON, pathComponents: [id as! String])
        return self.processObjectRequest(request)
    }
    
    public func exist(id: ModelId) -> Future<Bool,LoopBackError>{
        let promise = Promise<Bool, LoopBackError>()
        let request: Request = prepareRequest(.GET, pathComponents: [id as! String, "exists"])
        
        processAnyRequest(request).onSuccess { (anyObject: AnyObject) in
            if(anyObject is NSDictionary){
                let jsonData = anyObject as! NSDictionary
                let modelExist : Bool = jsonData["exists"] as! Bool
                promise.success(modelExist)
            }else{
                let error = LoopBackError(httpCode: .UnprocessableEntity, message: "Unexpected response")
                promise.failure(error)
                
            }

        }.onFailure { (error : LoopBackError) in
            promise.failure(error)
        }
        return promise.future
    }
    
    public func willProcessObjectRequest(request: Request, promise : Promise<Model, LoopBackError>, key:String? = nil){
        
    }
    
    public func didProcessObjectRequest(response : Response<Model, NSError>, key:String? = nil){
        
    }
    
    internal func processAnyRequest(request:Request, key: String? = nil) -> Future<AnyObject, LoopBackError>{
        let promise = Promise<AnyObject, LoopBackError>()

        request.responseJSON { (response : Response<AnyObject, NSError>) in
            guard (response.result.isSuccess)
                else{
                    let jsonString = NSString(data: response.data!, encoding: NSASCIIStringEncoding)
                    var error: LoopBackError? = Mapper<LoopBackError>().map(jsonString!)
                    error?.error = response.result.error
                    promise.failure(error!)
                    return
                    
            }
            
            let data = response.result.value
            
            promise.success(data!)
        }
        
        return promise.future

    }
    
    internal func processObjectRequest(request: Request, key: String? = nil) -> Future<Model, LoopBackError>{
        let promise = Promise<Model, LoopBackError>()
        self.willProcessObjectRequest(request, promise: promise, key: key)
        
        request.responseObject {  (response : Response<Model, NSError>) in
            
            /*let jsonRawString = NSString(data: response.data!, encoding: NSASCIIStringEncoding)
            let testModel = Mapper<Model>().map(jsonRawString)
            print(testModel)
            print(testModel?.toJSON())*/
            
            /*do{
                let httpBody = request.request?.HTTPBody
                if((httpBody) != nil){
                    var body =  try NSJSONSerialization.JSONObjectWithData(httpBody!, options: []) as? [String: AnyObject]
                    print(body)
                }
                
            } catch {
                print(error)
            }*/
            

            
            guard (response.result.isSuccess)
                else{
                    let jsonString = NSString(data: response.data!, encoding: NSASCIIStringEncoding)
                    var error: LoopBackError? = Mapper<LoopBackError>().map(jsonString!)
                    error?.error = response.result.error
                    promise.failure(error!)
                    return
                    
            }
            
            self.didProcessObjectRequest(response, key: key)

            let model = response.result.value
            
            promise.success(model!)
            
            
        }
        
        return promise.future
        
    }
    
    internal func processArrayRequest(request: Request) -> Future<[Model], LoopBackError>{
        let promise = Promise<[Model], LoopBackError>()
        request.responseArray {  (response : Response<[Model], NSError>) in
            guard (response.result.isSuccess)
                else{
                    let jsonString = NSString(data: response.data!, encoding: NSASCIIStringEncoding)
                    var error: LoopBackError? = Mapper<LoopBackError>().map(jsonString!)
                    error?.error = response.result.error
                    promise.failure(error!)
                    return
                    
            }
            let models = response.result.value
            promise.success(models!)
            
        }
        
        return promise.future
        
    }
    
    internal func prepareRequest(method:Method, pathComponents : [String]? = nil, absolutePath: String? = nil, parameters: [String : AnyObject]? = nil, encoding:ParameterEncoding? = .URL, headers: [String : String]? = nil) -> Request{
        var path: String? = self.resourcePath(pathComponents)
        
        if absolutePath != nil{
            let components: [String] = (absolutePath?.componentsSeparatedByString("?"))!
            path = self.absolutePath(components[0])
            if(components.count > 1){
                path = path! + "?" + components[1]

            }
        }
        
        return self.client.request(method,url: path!, parameters: parameters, encoding: encoding, headers: headers)
    }
    
    
}
