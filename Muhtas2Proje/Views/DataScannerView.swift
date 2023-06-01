//
//  DataScannerView.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 24.05.2023.
//

import VisionKit
import SwiftUI

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var shouldCapturePhoto: Bool
    @Binding var capturedPhoto: IdentifiableImage?
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isHighFrameRateTrackingEnabled: false,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
        if shouldCapturePhoto {
            capturePhoto(dataScannerVC: uiViewController)
            shouldCapturePhoto = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    private func capturePhoto(dataScannerVC: DataScannerViewController) {
        Task { @MainActor in
            do {
                let photo = try await dataScannerVC.capturePhoto()
                self.capturedPhoto = .init(image: photo)
            } catch {
                print(error.localizedDescription)
            }
            self.shouldCapturePhoto = false
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognizedItems: [RecognizedItem]

        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//            print("did tap on item \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
//            print("didAddItems \(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter({ item in
                !removedItems.contains (where: {$0.id == item.id })
            })
//            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("become unavailable with error \(error.localizedDescription)")
        }
    }
}

    //MARK: - DUZENLE

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
