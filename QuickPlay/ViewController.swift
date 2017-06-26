//
//  ViewController.swift
//  QuickPlay
//
//  Created by Michael Briscoe on 1/5/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
  @IBOutlet weak var videoTable: UITableView!
  
  var imagePicker: UIImagePickerController!
  var videoURLs = [URL]()
  var currentTableIndex = -1

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func addVideoClip(_ sender: AnyObject) {
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    imagePicker.allowsEditing = false
    imagePicker.mediaTypes = ["public.movie"]
    
    present(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func addRemoteStream(_ sender: AnyObject) {
    let theAlert = UIAlertController(title: "Add Remote Stream",
      message: "Enter URL for remote stream.",
      preferredStyle: UIAlertControllerStyle.alert)
    
    theAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
    theAlert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: {
      action in
      
      let theTextField = theAlert.textFields![0] as UITextField
      self.addVideoURL(URL(string: theTextField.text!)!)
    }))
    
    theAlert.addTextField(configurationHandler: {
      textField in
      textField.text = "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
    })
    
    present(theAlert, animated: true, completion:nil)

  }
  
  func addVideoURL(_ url: URL) {
    videoURLs.append(url)
    videoTable.reloadData()
  }
  
  @IBAction func deleteVideoClip(_ sender: AnyObject) {
    if currentTableIndex != -1 {
      let theAlert = UIAlertController(title: "Remove Clip",
        message: "Are you sure you want to remove this video clip from playlist?",
        preferredStyle: UIAlertControllerStyle.alert)
      
      theAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
      theAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: {
        action in
        self.videoURLs.remove(at: self.currentTableIndex)
        self.videoTable.reloadData()
        self.currentTableIndex = -1
      }))
      
      present(theAlert, animated: true, completion:nil)

    }
  }
  
  @IBAction func playVideoClip(_ sender: AnyObject) {

  }
  
  @IBAction func playAllVideoClips(_ sender: AnyObject) {

  }
  
  // MARK: - Helpers
  
  func previewImageFromVideo(_ url: URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    var time = asset.duration
    time.value = min(time.value, 2)
    
    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch {
      return nil
    }
  }


}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let theImagePath: URL = info["UIImagePickerControllerReferenceURL"] as! URL
    addVideoURL(theImagePath)
    
    imagePicker.dismiss(animated: true, completion: nil)
    imagePicker = nil
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    imagePicker.dismiss(animated: true, completion: nil)
    imagePicker = nil
  }

  
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videoURLs.count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "VideoClipCell") as! VideoTableViewCell
    
    cell.clipName.text = "Video Clip \(indexPath.row + 1)"
    
    if let previewImage = previewImageFromVideo(videoURLs[indexPath.row]) {
      cell.clipThumbnail.image = previewImage
    }

    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    currentTableIndex = indexPath.row
  }
}

