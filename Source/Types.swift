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
    var lat: Float = 0
    var lng: Float = 0
    
    public init?(_ map: Map) {
        
    }
    
    mutating public func mapping(map: Map) {
        lat        <- map["lat"]
        lng        <- map["lng"]
        
    }
}
