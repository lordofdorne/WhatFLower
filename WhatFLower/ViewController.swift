//
//  ViewController.swift
//  WhatFLower
//
//  Created by Asim on 12/3/19.
//  Copyright © 2019 Asim Samuel. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage]  as? UIImage {
        
            guard  let convertedCIImage = CIImage(image: userPickedImage) else {
                
                fatalError("cannot convert to CIImage.")
            }
        detect(image: convertedCIImage)
       
            imageView.image = userPickedImage
        
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage) {
        
        guard  let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("cannot import model")
        }
        let request = VNCoreMLRequest(model: model)  { (request, error) in
            let classification = request.results?.first as? VNClassificationObservation
            
            
            self.navigationItem.title = classification?.identifier.capitalized
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
       
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
            }
        }
    
   
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

