//
//  StartView.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 1.06.2023.
//

import SwiftUI

struct StartView: View {
    @StateObject private var vm = ScannerViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.83), Color.blue]), startPoint: .leading, endPoint: .trailing).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("ScanGenerate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    Spacer()
                    NavigationLink(destination: QrBarcodeGenerateView()) {
                        Text("Generate QR/Barcode")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(width: 350, height: 100)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.4), Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .ignoresSafeArea())
                            .foregroundColor(.white)
                            .cornerRadius(80)
                    }
                    .padding(.bottom, 50)
                    NavigationLink(
                        destination: ScanView()
                        .environmentObject(vm)
                        .task { @MainActor in
                            await vm.requestDataScannerAccessRequestStatus()
                        })
                    {
                        Text("Scan Everything")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(width: 350, height: 100)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(80)
                    }
                    Spacer()
                }
                .navigationBarHidden(true)
            }
        }
    }
}

