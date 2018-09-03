//
//  ViewController.swift
//  ObjectDectector
//
//  Created by Vincent Landolfi on 2018-06-08.
//  Copyright © 2018 Vincent Landolfi. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let label = UILabel()
    var type = "obj"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // start the camera
        
        let captureSesh = AVCaptureSession()
        captureSesh.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSesh.addInput(input)
        
        captureSesh.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSesh)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSesh.addOutput(dataOutput)
        
        self.label.textAlignment = .center
        
        self.label.frame = CGRect(x: self.view.frame.width/2 - 150, y: self.view.frame.height - 100, width: 300, height: 100)
        view.addSubview(self.label)
        
        let objBtn = UIButton()
        objBtn.frame = CGRect(x: 20, y: 40, width: 50, height: 30)
        objBtn.backgroundColor = .red
        objBtn.setTitle("Obj", for: .normal)
        objBtn.addTarget(self, action: #selector(ViewController.objPressed(sender:)), for: .touchUpInside)
        view.addSubview(objBtn)
        
        let textBtn = UIButton()
        textBtn.frame = CGRect(x: objBtn.frame.maxX + 20, y: 40, width: 50, height: 30)
        textBtn.backgroundColor = .red
        textBtn.setTitle("Text", for: .normal)
        textBtn.addTarget(self, action: #selector(ViewController.textPressed(sender:)), for: .touchUpInside)
        view.addSubview(textBtn)
        
        let carBtn = UIButton()
        carBtn.frame = CGRect(x: textBtn.frame.maxX + 20, y: 40, width: 50, height: 30)
        carBtn.backgroundColor = .red
        carBtn.setTitle("Car", for: .normal)
        carBtn.addTarget(self, action: #selector(ViewController.carPressed(sender:)), for: .touchUpInside)
        view.addSubview(carBtn)
        
        let foodBtn = UIButton()
        foodBtn.frame = CGRect(x: carBtn.frame.maxX + 20, y: 40, width: 50, height: 30)
        foodBtn.backgroundColor = .red
        foodBtn.setTitle("Food", for: .normal)
        foodBtn.addTarget(self, action: #selector(ViewController.foodPressed(sender:)), for: .touchUpInside)
        view.addSubview(foodBtn)
        
        let ageBtn = UIButton()
        ageBtn.frame = CGRect(x: foodBtn.frame.maxX + 20, y: 40, width: 50, height: 30)
        ageBtn.backgroundColor = .red
        ageBtn.setTitle("Age", for: .normal)
        ageBtn.addTarget(self, action: #selector(ViewController.agePressed(sender:)), for: .touchUpInside)
        view.addSubview(ageBtn)

        //let request = VNCoreMLRequest(model: <#T##VNCoreMLModel#>,completionHandler: )
        //VNImageRequestHandler(cgImage: , options: [:])
    }
    
    @objc func objPressed(sender: UIButton) {
        self.type = "obj"
        print("obj")
    }
    
    @objc func textPressed(sender: UIButton) {
        self.type = "text"
        print("text")
    }
    
    @objc func carPressed(sender: UIButton) {
        self.type = "car"
        print("text")
    }
    
    @objc func foodPressed(sender: UIButton) {
        self.type = "food"
        print("text")
    }
    
    @objc func agePressed(sender: UIButton) {
        self.type = "age"
        print("text")
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera captured frame", Date())
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var model: VNCoreMLModel
        if (self.type == "obj") {
            do {
                model = try VNCoreMLModel(for: MobileNet().model)
            } catch {
                return
            }
        } else if (self.type == "text") {
            do {
                model = try VNCoreMLModel(for: MNIST().model)
            } catch {
                return
            }
        } else if (self.type == "car") {
            do {
                model = try VNCoreMLModel(for: CarRecognition().model)
            } catch {
                return
            }
        } else if (self.type == "food") {
            do {
                model = try VNCoreMLModel(for: Food101().model)
            } catch {
                return
            }
        } else {
            do {
                model = try VNCoreMLModel(for: AgeNet().model)
            } catch {
                return
            }
        }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as?
                [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                self.label.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

