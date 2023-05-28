//
//  ContentView.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 24.05.2023.
//

import SwiftUI
import VisionKit
import PhotosUI

struct ContentView: View {
    
    @EnvironmentObject var vm: ScannerViewModel
    
    private let textContentTypes: [(title: String, contentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Adress", .fullStreetAddress),
        
    ]
    
    var body: some View {
        mainView
        switch vm.dataScannerAccessStatus {
        case .scannerAvaible:
            Text("Scanner is available")
        case .cameraNotAvailable:
            Text("Your device doesn't have camera")
        case .scannerNotAvaible:
            Text("Your device doesn't have support for scanning barcode with this app")
        case .cameraAccessNotGranted:
            Text("Please provide access to camera in settings")
        case .notDetermined:
            Text("Requesting camera access")
        }
    }
    private var mainView: some View {
        ZStack{
            liveImageFeed
            .background(Color.gray.opacity(0.3))
            .ignoresSafeArea()
            .id(vm.dataScannerViewId)
            .onChange(of: vm.scanType) { _ in vm.recognizedItems = [] }
            .onChange(of: vm.textContentType) { _ in vm.recognizedItems = [] }
            .onChange(of: vm.recognizesMultipleItems) { _ in vm.recognizedItems = [] }
            .onChange(of: vm.selectedPhotoPickerItem) { value in
                guard let value = value else { return }
                Task {
                    guard let data = try? await value.loadTransferable(type: Data.self),
                          let image = UIImage(data: data)
                    else {
                        return
                    }
                    self.vm.capturedPhoto = .init(image: image)
                }
            }
            Spacer()
            scannerSheetView
                .sheet(item: $vm.capturedPhoto) { photo in
                    ZStack(alignment: .topTrailing) {
                        LiveTextInteractionView(image: photo.image)
                        Button {
                            vm.capturedPhoto = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                        .foregroundColor(.white)
                        .padding([.trailing, .top])
                        }
                    .edgesIgnoringSafeArea(.bottom)
                }
        }
    }
    
    @ViewBuilder
    private var liveImageFeed: some View {
        if let capturedPhoto = vm.capturedPhoto {
            Image(uiImage: capturedPhoto.image)
                .resizable()
                .scaledToFit()
        } else {
            DataScannerView(
                shouldCapturePhoto: $vm.shouldCapturePhoto,
                capturedPhoto: $vm.capturedPhoto,
                recognizedItems: $vm.recognizedItems,
                recognizedDataType: vm.recognizedDataType,
                recognizesMultipleItems: vm.recognizesMultipleItems
            )
        }
    }
    // header view
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }
                .pickerStyle(.segmented)
                Toggle("Scan Multiple", isOn: $vm.recognizesMultipleItems)
            }
            .padding(.top)
            if vm.scanType == .text {
                Picker("Text content type", selection: $vm.textContentType) {
                    ForEach(textContentTypes, id: \.self.contentType) { content in
                        Text(content.title).tag(content.contentType)
                    }
                }.pickerStyle(.segmented)
            }
            HStack {
                Text(vm.headerText)
                Spacer()
                PhotosPicker(selection: $vm.selectedPhotoPickerItem, matching: .images) {
                    Image(systemName: "photo.circle")
                        .imageScale(.large)
                        .font(.system(size: 32))
                    
                }
                Button {
                    vm.shouldCapturePhoto = true
                } label: {
                    Image(systemName: "camera.circle")
                        .imageScale(.large)
                        .font(.system(size: 32))
                }
            }
        }.padding(.horizontal)
    }
    
    // bottom container view
    private var bottomContainerView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        case .text(let text):
                            Text(text.transcript)
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }.padding()
            }
        }
    }
    
    // scanner sheet view
    private var scannerSheetView: some View {
        VStack{
            Spacer()
            bottomContainerView.frame(height: 250, alignment: .bottom)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
                .cornerRadius(10)
        }.allowsHitTesting(vm.capturedPhoto == nil)
    }
}
