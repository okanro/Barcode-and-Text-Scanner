//
//  Muhtas2ProjeApp.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 24.05.2023.
//

import SwiftUI

@main
struct MuhtasProjeApp: App {
    
    @StateObject private var vm = ScannerViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task {
                    await vm.requestDataScannerAccessRequestStatus()
                }
        }
    }
}
