//
//  QrGenerateView.swift
//  Muhtas2Proje
//
//  Created by Okan Özdemir on 29.05.2023.
//
import CoreImage
import CoreImage.CIFilterGenerator
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct QrBarcodeGenerateView: View {
    @State private var textWillGenerate = ""
    @State private var generatedImage: UIImage?
    @State private var selectedOption: options = .QR
    @State private var savedQr = (UserDefaults.standard.stringArray(forKey: "QR") ?? [])
    @State private var savedBarcode = (UserDefaults.standard.stringArray(forKey: "Barcode") ?? [])
    
    @State private var goToSheet: Bool = false
    @State var lastCode: String = ""
    @State var pop = false
    @State var isAlerted: Bool = false
    
    var mode: [String] {
        if selectedOption.rawValue == "QR" {
            return savedQr
        } else {
            return savedBarcode
        }
    }
    
    private enum options: String, CaseIterable{
        case QR, Barcode
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.4), Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    mainView
        }.accentColor(.white)
    }
}

struct QrGenerateView_Previews: PreviewProvider {
    static var previews: some View {
        QrBarcodeGenerateView()
    }
}

extension QrBarcodeGenerateView {
    
    func getImage() -> Void {
        switch options(rawValue: selectedOption.rawValue) {
        case .QR:
            generatedImage = UIImage(qrCode: textWillGenerate)
        case .Barcode:
            generatedImage = UIImage(barcode: textWillGenerate)
        default:
            break
        }
    }
    //MARK: - Main View
    private var mainView: some View {
        VStack {
            headerView
            saveButtonView
            Spacer()
            imageView
            Spacer()
            Spacer()
            bottomButtonView
        }
        .onChange(of: textWillGenerate, perform: { newValue in
            getImage()
        })
        .onChange(of: selectedOption, perform: { newValue in
            getImage()
        })
        .padding()
        .sheet(isPresented: $goToSheet) {
            sheetMainView
                .sheet(isPresented: $pop) {
                    tapOnSheetView
                }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        Picker("Please specify the type of barcode", selection: $selectedOption) {
            ForEach(options.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }
        .pickerStyle(.segmented)        
        Text("Enter Text")
            .frame(maxWidth: .infinity)
            .overlay{
                RoundedRectangle(cornerRadius: 10).opacity(0.1)
            }
        
        TextField("Here",
                  text: $textWillGenerate)
        .textFieldStyle(.roundedBorder)
    }
    
    private var saveButtonView: some View {
        Button {
            if textWillGenerate != ""{
                switch options(rawValue: selectedOption.rawValue) {
                case .QR:
                    savedQr.append(textWillGenerate)
                    UserDefaults.standard.set(savedQr, forKey: "QR")
                    
                case .Barcode:
                    savedBarcode.append(textWillGenerate)
                    UserDefaults.standard.set(savedBarcode, forKey: "Barcode")
                default:
                    break
                }
            }
        } label: {
            Text("SAVE")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(.blue)
                .cornerRadius(80)
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let generatedImage = generatedImage {
            ScaledImage(image: generatedImage)
                .frame(width: 400, height: 400)
        }
    }
    
    private var bottomButtonView: some View {
        Button {
            goToSheet = true
        } label: {
            Text("GO TO SAVED CODES")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(20)
        }
    }
    
    //MARK: - Sheet View
    
    @ViewBuilder
    private var sheetMainView: some View {
        VStack {
            ScrollView{
                sheetPickerView
                savedCodesView
            }
        }
        Spacer()
        removeAllButtonView
    }
    
    private var sheetPickerView: some View {
        Picker("Please specify the type of barcode", selection: $selectedOption) {
            ForEach(options.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var savedCodesView: some View {
        ForEach(mode, id: \.self) { code in
            HStack {
                Spacer()
                Text(code)
                    .font(.headline)
                Spacer()

                switch selectedOption {
                case .QR:
                    if let image = UIImage(qrCode: code) {
                            ScaledImage(image: image)
                            .frame(maxWidth: 200, maxHeight: 200)
                            .onTapGesture {
                                lastCode = code
                                pop = true
                            }
                    }
                case .Barcode:
                    if let image = UIImage(barcode: code){
                        ScaledImage(image: image)
                            .frame(maxWidth: 200, maxHeight: 200)
                            .onTapGesture {
                                lastCode = code
                                pop = true
                            }
                    }
                }
            }
            .padding()
        }
    }
    
    private var removeAllButtonView: some View {
        Button {
            isAlerted = true
        } label: {
            Text("Remove All")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(20)
                .padding(.horizontal)
        }.alert("Are you sure?", isPresented: $isAlerted) {
            Button("Yes") {
                UserDefaults.standard.removeObject(forKey: selectedOption.rawValue)
                if selectedOption == .QR {
                    savedQr = []
                } else {
                    savedBarcode = []
                }
            }
            Button("No") {
            }
        }
        
    }
        //MARK: - Tapped Code View Sheet
    
    @ViewBuilder
    private var tapOnSheetView: some View {
        VStack(alignment: .trailing){
            if selectedOption == .QR {
                if let image = UIImage(qrCode: lastCode){
                    saveButton(image: image)
                        .padding()
                    ScaledImage(image: image)
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                if let image = UIImage(barcode: lastCode){
                    saveButton(image: image)
                        .padding()
                    ScaledImage(image: image)
                        .frame(width: 300, height: 300)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    @ViewBuilder
    func saveButton(image: UIImage) -> some View {
        Button {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print(image)
           
        } label: {
            Image(systemName: "square.and.arrow.down.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .scaledToFit()
        }
        .alert(isPresented: $isAlerted) {
            Alert(title: Text("Saved Succesfully"))
        }
    }
}
