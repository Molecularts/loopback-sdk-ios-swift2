//
//  LoopBack.swift
//  LoopBackSwift
//
//  Created by Oscar Anton on 22/5/16.
//

import Foundation
import Alamofire
import ObjectMapper
import BrightFutures

public typealias Method = Alamofire.Method;
public typealias ParameterEncoding = Alamofire.ParameterEncoding;
public typealias ModelMappable = Mappable
public typealias Response = Alamofire.Response
public typealias Request = Alamofire.Request


struct LoopBackConstants {
    static let currentUserKey = "LoopBackCurrentUser"
    static let currentAccessTokenKey = "LoopBackCurrentAccessToken"
    static let currentAccessTokenObjectKey = "currentAccessTokenObjectKey"
    
}


public protocol LoopBackClient{
    var baseURL: NSURL { get }
    var accessToken : ModelId? { get set }
    
}

public extension LoopBackClient{
    
    var accessToken: ModelId? {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.objectForKey(LoopBackConstants.currentAccessTokenKey)
        }
        set(newAccessToken){
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newAccessToken, forKey: LoopBackConstants.currentAccessTokenKey)
        }
    }
    
    
    func request(method : Method, url : String, parameters: [String : AnyObject]? = nil, encoding:ParameterEncoding? = .URL, headers: [String : String]? = nil) -> Request{
        
        var clientHeaders : [String : String] = ["Authorization" : (self.accessToken != nil) ? self.accessToken! as! String : ""]
        headers?.forEach({ (key, value) -> Void in clientHeaders[key] = value })
        
        return Alamofire.request(method, url, parameters: parameters,  headers:clientHeaders, encoding: encoding!).validate();
    }
    
    
    func repository<Model where  Model:PersistedModel,  Model:Mappable> (path: String) -> Repository<Model>{
        let repository = Repository<Model>(client: self,path: path)
        return repository
    }
    
    
}



public struct LoopBackError : Mappable, ErrorType{
    var name:String? = nil
    var status:Int? = 200 {
        didSet{
            self.httpStatusCode = HTTPStatusCode(rawValue: status!)
        }
    }
    
    var message:String? = nil
    
    var error: NSError? = nil
    var httpStatusCode: HTTPStatusCode? = nil
    
    
    
    internal static let errorDomain = "com.loopback.error"
    
    public init?(_ map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        name <- map["error.name"]
        status <- map["error.status"]
        message <- map["error.message"]
    }
    
    public init(httpCode:HTTPStatusCode, message: String?){
        self.name = httpCode.description
        self.status = httpCode.rawValue
        self.message = message
        self.error = NSError(domain: LoopBackError.errorDomain, code: httpCode.rawValue, userInfo: nil)
    }
}

public struct Filter : Mappable{
    public var Where: [String: AnyObject]?
    public var Limit: Int?
    public var Include : [String]?
    public var Order : [String]?
    public var Skip : Int?
    
    public init?(_ map: Map) {
        
    }
    
    public init(Where:[String:AnyObject]? = nil, Limit:Int? = nil, Include:[String]? = nil, Order:[String]? = nil, Skip:Int? = nil){
        self.Where = Where;
        self.Limit = Limit;
        self.Include = Include;
        self.Order = Order;
        self.Skip = Skip;
    }
    
    public mutating func mapping(map: Map) {
        Where <- map["where"]
        Limit <- map["limit"]
        Order <- map["order"]
        Include <- map["include"]
        Skip <- map["skip"]
    }
    
    public func toRequestParametters() -> [String:AnyObject]{
        let parametters: [String:AnyObject] = ["filter": self.toJSON()]
        return parametters
    }
    
}



