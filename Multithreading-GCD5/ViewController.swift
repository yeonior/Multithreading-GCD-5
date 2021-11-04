//
//  ViewController.swift
//  Multithreading-GCD5
//
//  Created by ruslan on 04.11.2021.
//

import UIKit

// practicing with dispatch groups

final class ViewController: UIViewController {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet var imageViewCollection: [UIImageView]!
    
    private var images = [UIImage]()
    private let imageURLs: [URL] = [
        URL(string: "https://images.unsplash.com/photo-1635967453256-fd9e2d19f386?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1365&q=80")!,
        URL(string: "https://images.unsplash.com/photo-1635967198465-853200fd84d0?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1287&q=80")!,
        URL(string: "https://images.unsplash.com/photo-1635965450325-db9599123c9b?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1287&q=80")!,
        URL(string: "https://images.unsplash.com/photo-1635945404768-1c28da9fed7b?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2670&q=80")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadButton.layer.cornerRadius = 15
    }
    
    // async loading an image and pushing it to the main queue
    private func asyncLoadImage(imageURL: URL,
                                runQueue: DispatchQueue,
                                completionQueue: DispatchQueue = DispatchQueue.main,
                                completion: @escaping (UIImage?, Error?) -> Void) {
        runQueue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                completionQueue.async {
                    completion(UIImage(data: data), nil)
                }
            } catch let error {
                completionQueue.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // async executing in group with notifying
    private func asyncGroup() {
        let group = DispatchGroup()
        
        for i in 0...3 {
            group.enter()
            asyncLoadImage(imageURL: imageURLs[i], runQueue: .global()) { image, error in
                defer {
                    group.leave()
                }
                guard let image = image else { return }
                self.images.append(image)
            }
        }
        
        group.notify(queue: .main) {
            if self.imageViewCollection.count == self.images.count {
                for i in 0...3 {
                    self.imageViewCollection[i].image = self.images[i]
                }
            }
        }
    }
    
    @IBAction func downloadButtonAction(_ sender: UIButton) {
        for i in 0...3 {
            imageViewCollection[i].image = nil
        }
        images.removeAll()
        asyncGroup()
    }
}

