//
//  ScaledImage.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 1.06.2023.
//

import Foundation
import SwiftUI

struct ScaledImage: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
    }
}
