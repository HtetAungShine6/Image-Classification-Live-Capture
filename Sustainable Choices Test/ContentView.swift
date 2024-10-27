//
//  ContentView.swift
//  Sustainable Choices Test
//
//  Created by Htet Aung Shine on 27/10/2024.
//

import SwiftUI
import Foundation
import Vision
import CoreML

struct ContentView: View {
    
    @State private var captureImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @State private var classificationLabel: String = "No Label available"
    
    var model: VNCoreMLModel? = {
        guard let mLModel = try? TestImageClassification(configuration: .init()).model else { return nil }
        return try? VNCoreMLModel(for: mLModel)
    }()
    
    var body: some View {
        ZStack {
            
            if let image = captureImage {
                VStack{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    Text(classificationLabel)
                        .font(.title)
                        .padding()
                }
            } else {
                Color(UIColor.systemBackground)
            }
            
            VStack{
                Spacer()
                Button {
                    isCustomCameraViewPresented.toggle()
                }label: {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .clipShape(Circle())
                }
                .padding(.bottom)
                .sheet(isPresented: $isCustomCameraViewPresented) {
                    CustomCameraView(captureImage: $captureImage) { newImage in
                        classifyImage(newImage)
                    }
                    
//                        .onChange(of: captureImage) { newImage, oldImage in
//                            if newImage != oldImage {
//                                classificationLabel = "Classifying..."
//                                classifyImage(newImage)
//                            }
//                        }
                }
            }
        }
        .padding()
    }
    
    private func classifyImage(_ image: UIImage?) {
        guard let image = image, let ciImage = CIImage(image: image), let model = model else { return }
        
        // Create a request to classify the image
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            if let results = request.results as? [VNClassificationObservation], let firstResult = results.first {
                DispatchQueue.main.async {
                    self.classificationLabel = firstResult.identifier
                    print("Result: \(results)")
                }
            } else {
                DispatchQueue.main.async {
                    self.classificationLabel = "Could not classify image."
                }
            }
        }
        
        // Run the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.classificationLabel = "Image classification failed."
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}

