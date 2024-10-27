//
//  CustomCameraView.swift
//  Sustainable Choices Test
//
//  Created by Htet Aung Shine on 27/10/2024.
//

import Foundation
import SwiftUI

struct CustomCameraView: View {
    
    let cameraService = CameraService()
    @Binding var captureImage: UIImage?
    var completion: (UIImage?) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View{
        ZStack {
            
            CameraView(cameraService: cameraService) { result in
                switch result {
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        let newImage = UIImage(data: data)
                        captureImage = newImage
                        completion(newImage)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error: No Image Data Found!")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            // Camera Screen Preview UI
            VStack {
                Spacer()
                Button {
                    cameraService.capturePhoto()
                }label: {
                    Image(systemName: "circle")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                }
                .padding(.bottom)
            }
        }
    }
}
