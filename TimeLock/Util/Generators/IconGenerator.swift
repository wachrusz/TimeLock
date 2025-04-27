//
//  IconGenerator.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 22.04.2025.
//

import UIKit
import CryptoKit

final class IconGenerator {
    static let shared = IconGenerator()
    
    init(){}
    
    func generateIdenticon(from data: Data, size: CGFloat = 100) -> UIImage? {
        let digest = SHA256.hash(data: data)
        let hash = Array(digest)
        
        let gridSize = 5
        let scale = UIScreen.main.scale
        let contextSize = CGSize(width: size, height: size)
        let cellSize = floor(size / CGFloat(gridSize))
        
        let color = UIColor(
            red: CGFloat(hash[0]) / 255.0,
            green: CGFloat(hash[1]) / 255.0,
            blue: CGFloat(hash[2]) / 255.0,
            alpha: 1.0
        )
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        
        var hashIndex = 3
        
        for row in 0..<gridSize {
            for col in 0..<(gridSize / 2 + 1) {
                if hashIndex >= hash.count { break }
                let byte = hash[hashIndex]
                hashIndex += 1
                
                if byte & 1 == 1 {
                    let x = CGFloat(col) * cellSize
                    let y = CGFloat(row) * cellSize
                    let rect = CGRect(x: x.rounded(.down), y: y.rounded(.down), width: ceil(cellSize + 1), height: ceil(cellSize + 1))
                    context.fill(rect)
                    
                    let mirroredX = size - x - cellSize
                    let mirroredRect = CGRect(x: mirroredX.rounded(.down), y: y.rounded(.down), width: ceil(cellSize + 1), height: ceil(cellSize + 1))
                    context.fill(mirroredRect)
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
