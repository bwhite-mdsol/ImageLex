//
//  ViewController.swift
//  ImageLex
//
//  Created by Bob White on 7/1/17.
//  Copyright © 2017 Bob White. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  let picker = UIImagePickerController()
  let apiKey = "AIzaSyDM7GQFY5WTl4AP02TuQFXIfuzJwAMDRS8"
  let sharedSession = URLSession.shared
  
  var apiTask: URLSessionDataTask?
  
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  @IBOutlet weak var labels: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var analyze: UIButton!
  @IBOutlet weak var search: UIButton!
  
  // MARK: View Handling

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    picker.delegate = self
    
    self.resetViewState()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Actions
  
  @IBAction func loadPhoto(_ sender: Any) {
    self.resetViewState()
    
    picker.allowsEditing = false
    picker.sourceType = .photoLibrary
    
    present(picker, animated: true, completion: nil)
  }
  
  @IBAction func analyzePhoto(_ sender: Any) {
    // search.isEnabled = true
    
    labels.isHidden = true
    // labels.text = "Label 1\nLabel 2\nLabel 3"
    
    analyze.isEnabled = false
    
    updateSpinner(true)

    apiRequest(using: imageView.image!)
  }
  
  // MARK: ImagePicker
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.contentMode = .scaleToFill
      imageView.image = image
      
      analyze.isEnabled = true
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: Helpers
  
  func resetViewState() {
    labels.text = ""
    labels.isHidden = true
    
    analyze.isEnabled = false
    
    search.isEnabled = false
  }
  
  
  func updateLabels(_ text: String) {
    // update UI on main thread
    DispatchQueue.main.async {
      self.labels.text = text;
      self.labels.isHidden = false
      
      self.analyze.isEnabled = true
      
      self.search.isEnabled = true
    }
  }
  
  func updateSpinner(_ run: Bool) {
    DispatchQueue.main.async {
      if run {
        self.spinner.startAnimating()
      } else {
        self.spinner.stopAnimating()
      }
    }
  }
  
  // MARK: Google Vision API
  
  func apiRequest(using image: UIImage) {
    // encoded image
    let data = UIImagePNGRepresentation(image)!.base64EncodedString()
    
    // api url
    let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    
    // compose request
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let reqJSON = [
      "requests": [
        "image": [ "content": data ],
        "features": [ [ "type": "LABEL_DETECTION", "maxResults": 15 ] ]
      ]
    ]
    
    if JSONSerialization.isValidJSONObject(reqJSON) {
      do {
        let body = try JSONSerialization.data(withJSONObject: reqJSON, options: .prettyPrinted)
        
        req.httpBody = body
        
        // aysnc http request
        DispatchQueue.global().async { self.asyncHTTPRequest(req) }
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  func asyncHTTPRequest(_ request: URLRequest) {
    apiTask = sharedSession.dataTask(with: request, completionHandler: { (data, response, error) in
      if let error = error {
        print(error.localizedDescription)
      }
      self.postProcessing(data!)
    })
    
    apiTask?.resume()
  }
  
  func postProcessing(_ data: Data) {
    do {
      let object = try JSONSerialization.jsonObject(with: data)
      if let dictionary = object as? [String: AnyObject] {
        var resultText: String = ""
        // print(dictionary as Any)

        if dictionary["error"] != nil {
          // present error message
          var error = dictionary["error"] as? [String: AnyObject]
          resultText = error?["message"] as! String
        } else {
          // get labels from labelAnnontations
          let responses = dictionary["responses"]?[0] as! [String: AnyObject]
          let annotations = responses["labelAnnotations"] as! Array<[String: AnyObject]>

          for label:[String: Any] in annotations {
            resultText += label["description"] as! String
            resultText += "\n"
          }
        }
        
        self.updateSpinner(false)
        self.updateLabels(resultText)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}
