//
//  SCNImageColorNode.swift
//  ImageToGeo
//
//  Created by Toshihiro Goto on 2019/03/12.
//  Copyright © 2019 Toshihiro Goto. All rights reserved.
//

import UIKit
import SceneKit

class SCNImageColorNode: SCNNode {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image:UIImage, imageWidth:UInt, imageHeight:UInt, geometry:SCNGeometry, geometoryOffsetX:Float = 0, geometoryOffsetZ:Float = 0){
        super.init()
        
        var array = image.getColorArray()

        let w = imageWidth
        let h = imageHeight
        
        let dx = (geometry.boundingBox.max.x - geometry.boundingBox.min.x)
        let dz = (geometry.boundingBox.max.z - geometry.boundingBox.min.z)
        
        for j in 0..<w {
            for k in 0..<h {
                let index = Int((j * w) + k)
                let node = SCNNode(geometry: geometry.copy() as? SCNGeometry)
                let material = SCNMaterial()
                
                material.lightingModel = .physicallyBased
                material.diffuse.contents = UIColor(
                    red: CGFloat(array[index][0]) / 255,
                    green: CGFloat(array[index][1]) / 255,
                    blue: CGFloat(array[index][2]) / 255,
                    alpha: CGFloat(array[index][3]) / 255
                )
                
                node.geometry?.materials = [material]
                
                let posX = Float(k) * (dx + geometoryOffsetX)
                let posZ = Float(j) * (dz + geometoryOffsetZ)
                
                node.simdPosition = float3(posX, 0, posZ)
                                
                self.addChildNode(node)
            }
        }
    }
    
}

extension UIImage {
    func getColorArray() -> [[UInt8]] {
        
        let imageRef = self.cgImage!
        
        let data = imageRef.dataProvider!.data
        let length = CFDataGetLength(data)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        
        
        var colorArray = [[UInt8]]()
        
        let sepalatorLength = rawData.count / 4
        
        for i in 0..<sepalatorLength {
            let firstNumber = 4 * i
            let LastNumber = 4 * i + 3
            
            colorArray.append(
                Array(rawData[firstNumber...LastNumber])
            )
        }
        
        return colorArray
    }
}
