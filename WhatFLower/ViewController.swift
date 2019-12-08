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
import SDWebImage



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var label: UILabel!
    
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
       
            
        
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage) {
        
        guard  let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("cannot import model")
        }
        let request = VNCoreMLRequest(model: model)  { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("could not classify flower")
            }
            
            
            self.navigationItem.title = classification.identifier.capitalized
            self.infoRequest(flowerName: classification.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
       
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
            }
        }
    
    func infoRequest(flowerName: String) {
        
        let parameters : [String:String] = [
         "format" : "json",
         "action" : "query",
         "prop" : "extracts | pageimages",
         "exintro" : "",
         "explaintext" : "",
         "titles" : flowerName,
         "indexpageids" : "",
         "redirects" : "1",
         "pithumbsize" : "500"
         ]

        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got the wikipedia info.")
                print(response)
                
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                
                self.label.text = flowerDescription
            }
        }
    }
   
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

