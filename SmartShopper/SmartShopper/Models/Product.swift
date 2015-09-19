//
//  Product.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import Argo
//import Runes

/* Sample JSON response
{
    "numItems" : 10,
    "totalResults" : 3117,
    "query" : "sweater",
    "sort" : "relevance",
    "items" : [
        {
            "shortDescription" : "Get an affordable hoodie from a great brand with Hanes Men's EcoSmart Fleece Pullover Hood. This comfortable hoodie makes an excellent everyday jacket. Wear this hoodie with jeans and sneakers on a cool evening.",
            "productUrl" : "http://c.affil.walmart.com/t/api02?l=http%3A%2F%2Fwww.walmart.com%2Fip%2FFAST-TRACK-Hanes-Men-s-EcoSmart-Fleece-Pullover-Hood%2F22471486%3Faffp1%3DJ1dU9ghtbbzCAw51HUTbwUFSdp6L5onI8w46S_QWGwY%26affilsrc%3Dapi%26veh%3Daff%26wmlspartner%3Dreadonlyapi",
            "name" : "Hanes Men's ComfortBlend EcoSmart Fleece Pullover Hood",
            "itemId" : 22471486,
            "salePrice" : 10,
            "thumbnailImage" : "http://i.walmartimages.com/i/p/00/76/63/69/05/0076636905974_Color_Navy_SW_100X100.jpg"
        },
        ...
    ]
}
*/
public struct Product {
    let id: Int
    let name: String
    let salePrice: Double
    var thumbnailImage: NSURL?
    let productURL: NSURL
}

extension Product: CustomStringConvertible {
    public var description : String {
        return "id: \(id), name: \(name), price: \(salePrice), thumbnail: \(thumbnailImage)"
    }
}

extension Product: Decodable {
    
    static func create(id: Int)(name: String)(salePrice: Double)(thumbnailImage: String)(productURL: String) -> Product {
        return Product(id: id, name: name, salePrice: salePrice, thumbnailImage: NSURL(string: thumbnailImage), productURL: NSURL(string: productURL)!)
    }
    
    public static func decode(j: JSON) -> Decoded<Product> {
        return Product.create
            <^> j <| "itemId"
            <*> j <| "name"
            <*> j <| "salePrice"
            <*> j <| "thumbnailImage"
            <*> j <| "productUrl"
    }
}

extension Product {
    
    init(dictionary: [String: String]) {
        self.id = Int(dictionary["itemId"]!)!
        self.name = dictionary["name"]!
        self.salePrice = Double(dictionary["salePrice"]!)!
        if let thumb = dictionary["thumbnailImage"] {
            self.thumbnailImage = NSURL(string: thumb)
        }
        self.productURL = NSURL(string: dictionary["productUrl"]!)!
    }
    
    // TODO: Define protocol
    func toDictionary() -> [String: String] {
        var dictionary = [
            "itemId": String(id),
            "name": name,
            "salePrice": String(salePrice),
            "productUrl": productURL.absoluteString
        ]
        
        if let _ = thumbnailImage {
            dictionary["thumbnailImage"] = thumbnailImage!.absoluteString
        }
        
        return dictionary
    }
}

extension Product: Hashable {
    
    public var hashValue: Int {
        return id.hashValue ^ name.hashValue ^ salePrice.hashValue ^ productURL.hashValue
    }
}

// MARK: Equatable

public func ==(lhs: Product, rhs: Product) -> Bool {
    return lhs.id == rhs.id
}
