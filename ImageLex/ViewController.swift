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
    spinner.hidesWhenStopped = true
    
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
    search.isEnabled = true
    
    labels.isHidden = false
    labels.text = "Label 1\nLabel 2\nLabel 3"
    
    analyze.isEnabled = false
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
  
  // MARK: Google Vision API
  
  
}
