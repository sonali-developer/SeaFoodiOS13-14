//
//  ViewController.swift
//  SeaFood
//
//  Created by Sonali Patel on 12/24/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Error converting the UIImage to CIImage")
            }
            
            detect(image: ciImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        let inceptionV3 = Inceptionv3()
        let inceptionModel = inceptionV3.model
        guard let model = try? VNCoreMLModel(for: inceptionModel) else {
            fatalError("Error converting to VNCoreMLModel")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model process failed")
            }
            
            print(results)
            
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.contains("hotdog") ? "Hot Dog!!!" : "Not a Hot Dog!!!"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error executing the VNVoreMLRequest - \(error.localizedDescription)")
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

