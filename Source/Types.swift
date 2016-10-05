//
//  Types.swift
//  LoopBackSwift
//
//  Created by Oscar Anton on 28/6/16.
//  Copyright © 2016 Molecularts. All rights reserved.
//

import Foundation
import ObjectMapper


public struct GeoPoint : ModelMappable{
    public var lat: Double = 0
    public var lng: Double = 0
    
    public init?(_ map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        lat        <- map["lat"]
        lng        <- map["lng"]
        
    }
}
