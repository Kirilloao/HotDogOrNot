//
//  ViewController.swift
//  HotDogOrNot
//
//  Created by Kirill Taraturin on 12.10.2023.
//

import UIKit
import CoreML
import Vision
import Social

final class ViewController: UIViewController {
    
    // MARK: - Private UI Properties
    private lazy var hotdogImageView: UIImageView = {
        var hotdog = UIImageView()
        hotdog.image = UIImage(named: "hotdog")
        hotdog.translatesAutoresizingMaskIntoConstraints = false
        return hotdog
    }()
    
    private lazy var answerView: UIImageView = {
        var answer = UIImageView()
        answer.image = UIImage(named: "correct")
        answer.translatesAutoresizingMaskIntoConstraints = false
        answer.isHidden = true
        return answer
    }()
    
    private lazy var answerLabel: UILabel = {
        var answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.text = "Yes, It's HotDog!"
        answerLabel.textColor = .systemGreen
        answerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        answerLabel.isHidden = true
        return answerLabel
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        var imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(hotdogImageView)
        view.addSubview(answerView)
        view.addSubview(answerLabel)
        setupConstraints()
        setupNavigationBar()
        
        imagePicker.delegate = self
    }
    
    // MARK: - Private Actions
    @objc private func cameraButtonDidTapped() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            answerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            answerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answerView.heightAnchor.constraint(equalToConstant: 50),
            answerView.widthAnchor.constraint(equalToConstant: 50),
            
            answerLabel.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 10),
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            hotdogImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hotdogImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hotdogImageView.heightAnchor.constraint(equalToConstant: 100),
            hotdogImageView.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    private func setupNavigationBar() {
        let cameraButton = UIBarButtonItem(
            barButtonSystemItem: .camera,
            target: self,
            action: #selector(cameraButtonDidTapped)
        )
        
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9238868356, green: 0.381075263, blue: 0.3808981776, alpha: 1)
        navigationItem.rightBarButtonItem = cameraButton
    }
    
    private func showAnswer(with isRightAnswer: Bool) {
        if isRightAnswer {
            answerView.image = UIImage(named: "correct")
            answerLabel.text = "Yes, It's HotDog!"
            answerLabel.textColor = #colorLiteral(red: 0.2951729596, green: 0.6820793748, blue: 0.311968863, alpha: 1)
        } else {
            answerView.image = UIImage(named: "incorrect")
            answerLabel.text = "No, It's not HotDog!"
            answerLabel.textColor = #colorLiteral(red: 0.8569052815, green: 0.2289541364, blue: 0.237477541, alpha: 1)
        }
        answerView.isHidden = false
        answerLabel.isHidden = false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imagePicker.dismiss(animated: true)
            guard let ciiimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(image: ciiimage)
        }
    }
    
    private func detect(image: CIImage) {
        let config = MLModelConfiguration()
        
        do {
            let model = try VNCoreMLModel(for: Inceptionv3(configuration: config).model)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first
                else {
                    fatalError("Model failed to process image")
                }
                
                print(topResult.identifier)
                if topResult.identifier.contains("hotdog") {
                    
                    DispatchQueue.main.async {
                        self.showAnswer(with: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAnswer(with: false)
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            try handler.perform([request])
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}
