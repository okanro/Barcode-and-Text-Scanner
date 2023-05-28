//
//  LiveTextView.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 26.05.2023.
//

import Foundation
import SwiftUI
import VisionKit
import Vision

@MainActor
struct LiveTextInteractionView: UIViewRepresentable {
    
    let image: UIImage
    let imageView = LiveTextImageView()
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.addInteraction(interaction)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task {
            let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
            do {
                if let image = imageView.image {
                    let analysis = try await analyzer.analyze(image, configuration: configuration)
                    interaction.analysis = analysis;
                    interaction.preferredInteractionTypes = .textSelection
                    
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}

class LiveTextImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        .zero
    }
    
}
