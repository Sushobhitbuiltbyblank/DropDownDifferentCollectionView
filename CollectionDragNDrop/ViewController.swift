//
//  ViewController.swift
//  CollectionDragNDrop
//
//  Created by Sushobhit.Jain on 18/07/20.
//  Copyright © 2020 Sushobhit.Jain. All rights reserved.
//

import UIKit
import MobileCoreServices
class ViewController: UIViewController {
    
    @IBOutlet weak var upperCollectionV: UICollectionView!
    
    @IBOutlet weak var lowerCollectionV: UICollectionView!
    
    // hardcode datasource
    var upperDataSource = ["1","2","3","4","5","6","7","8","9"]
    var lowerDataSource = ["1","2","3","4","5"]
    
    var sourceIndex = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    func setUpUI()
    {
        // setup upper collection view
        let upperCollectionLayout = UICollectionViewFlowLayout()
        upperCollectionLayout.scrollDirection = .vertical
        self.upperCollectionV.collectionViewLayout = upperCollectionLayout
        upperCollectionV.dragDelegate = self
        upperCollectionV.dragInteractionEnabled = true
        upperCollectionV.dropDelegate = self
        
        // setup lower collection view
        let lowerCollectionLayout = UICollectionViewFlowLayout()
        lowerCollectionLayout.scrollDirection = .vertical
        self.lowerCollectionV.collectionViewLayout = lowerCollectionLayout
        lowerCollectionV.dragDelegate = self
        lowerCollectionV.dragInteractionEnabled = true
        lowerCollectionV.dropDelegate = self
    }
    
    func dragItem(for indexPath:IndexPath, collectionView:UICollectionView) -> [UIDragItem]
    {
        let itemProvider = NSItemProvider()
        self.sourceIndex = indexPath.row
        let val = collectionView == upperCollectionV ? upperDataSource[indexPath.row] : lowerDataSource[indexPath.row]
        itemProvider.registerDataRepresentation(forTypeIdentifier:kUTTypePlainText as String, visibility: .all) { completion in
            let data = val.data(using: .utf8)
            completion(data,nil)
            DispatchQueue.main.async {
                let _ = collectionView == self.upperCollectionV ? self.upperDataSource.remove(at: indexPath.row) : self.lowerDataSource.remove(at: indexPath.row)
                collectionView.reloadData()
            }
            return nil
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func copyDragItem(with coordinator:UICollectionViewDropCoordinator , collectionView:UICollectionView) {
        switch coordinator.proposal.operation {
        case .copy:
            let items = coordinator.items
            for item in items {
                let _ = item.dragItem.itemProvider.loadObject(ofClass: String.self) { (item, error) in
                    if let newItem = item {
                        var row = 0
                        if collectionView == self.lowerCollectionV {
                            row = self.lowerDataSource.count < self.sourceIndex ? self.lowerDataSource.count : self.sourceIndex
                            self.lowerDataSource.insert(newItem, at: row)
                        } else{
                            row = self.upperDataSource.count < self.sourceIndex ? self.upperDataSource.count : self.sourceIndex
                            self.upperDataSource.insert(newItem, at: row)
                        }
                        DispatchQueue.main.async {
                            collectionView.insertItems(at: [IndexPath(item: row , section: 0)])
                        }
                    }
                }
            }
        default: return
            
        }
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width/4, height: collectionView.frame.height/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == upperCollectionV ? upperDataSource.count : lowerDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == upperCollectionV
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UperCollectionVCell", for: indexPath) as! UperCollectionVCell
            cell.lableName.text = upperDataSource[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LowerCollectionVCell", for: indexPath) as! LowerCollectionVCell
            cell.lableName.text = lowerDataSource[indexPath.row]
            return cell
        }
    }
}

extension ViewController : UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return self.dragItem(for: indexPath,collectionView: collectionView)
    }
}

extension ViewController : UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        self.copyDragItem(with: coordinator, collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String])
    }
}

