//
//  ContentView.swift
//  AnimalFriendsSUI2021
//
//  Created by Amit Gupta on 12/2/21.
//


import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @State var animalName = " "
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = UIImage(named: "paws")
    
    var body: some View {
        HStack {
            VStack (alignment: .center,
                    spacing: 20){
                Text("Animal Friends")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                        Text(animalName)
                        Image(uiImage: inputImage!).resizable()
                            .aspectRatio(contentMode: .fit)
                        //Text(animalName)
                        Button("Who am I?"){
                            self.buttonPressed()
                        }
                        .padding(.all, 14.0)
                        .foregroundColor(.white)
                            .background(Color.green)
                        .cornerRadius(10)
            }
            .font(.title)
        }.sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func processImage() {
        self.showingImagePicker = false
        self.animalName="Checking..."
        guard let inputImage = inputImage else {return}
        print("Processing image due to Button press")
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPGcvrt).base64EncodedData()
        let imageJPGcvrt = imageJPG.data(using: .utf8)
        let uploadURL="https://982pk2w7mh.execute-api.us-east-1.amazonaws.com/h5to_onnx/h5toonnx"
        
        AF.upload(imageJPGcvrt, to: uploadURL).responseJSON { response in
            
            debugPrint(response)
            switch response.result {
               case .success(let responseJsonStr):
                   print("\n\n Success value and JSON: \(responseJsonStr)")
                   let myJson = JSON(responseJsonStr)
                let predictedValue = myJson["body"].string
                   print("Saw predicted value \(String(describing: predictedValue))")

                   let predictionMessage = predictedValue!
                   self.animalName=predictionMessage
               case .failure(let error):
                   print("\n\n Request failed with error: \(error)")
               }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        //picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
