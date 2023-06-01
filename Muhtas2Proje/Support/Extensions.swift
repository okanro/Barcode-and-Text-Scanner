//
//  Extensions.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 31.05.2023.
//

import Foundation
import UIKit

extension UIImage {
    
    convenience init?(barcode: String) {
        let ciContext = CIContext()
        
        let data = barcode.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil}
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        let cgFinishedImage = ciContext.createCGImage(output, from: output.extent)!
        
        self.init(cgImage: cgFinishedImage)
    }
    convenience init?(qrCode: String) {
        let ciContext = CIContext()

        let data = qrCode.data(using: String.Encoding.ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        guard let output = filter.outputImage?.transformed(by: transform) else {
            return nil
        }
        let cgFinishedImage = ciContext.createCGImage(output, from: output.extent)!
        self.init(cgImage: cgFinishedImage)
    }
}
