//
//  ScannerViewModel.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 24.05.2023.
//

import VisionKit
import AVKit
import PhotosUI
import SwiftUI

enum ScanType: String {
    case barcode, text
}

enum DataScannerAccesStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvaible
    case scannerNotAvaible
    
}

@MainActor
final class ScannerViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccesStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true
    
    @Published var shouldCapturePhoto = false
    @Published var capturedPhoto: IdentifiableImage? = nil
    @Published var selectedPhotoPickerItem: PhotosPickerItem? = nil
    @Published var isSaved: Bool = false
    @Published var shouldAlert: Bool = false

    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count) item(s)"
        }
    }
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessRequestStatus() async {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvaible : .scannerNotAvaible
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvaible : .scannerNotAvaible
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
        default: break
        }
        
        
    }
}
