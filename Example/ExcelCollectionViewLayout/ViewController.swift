//
//  ViewController.swift
//  ExcelCollectionViewLayout
//
//  Created by Rafael Rocha on 10/02/2017.
//  Copyright (c) 2017 Rafael Rocha. All rights reserved.
//

import UIKit
import ExcelCollectionViewLayout

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ExcelCollectionViewLayoutDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Data
    enum BigOuComplexityType: String {
      case excellent = "O(1)"
      case good = "O(logn)"
      case fair = "O(n)"
      case bad = "O(nlogn)"
      case horrible0 = "O(n^2)"
      case horrible1 = "O(2^n)"
      case horrible2 = "O(n!)"
    }
    let topLeftString: String = "Array Sorting"
    let topFirstLabels: [String] = ["Time Complexity", " ", " ", "Space Complexity"]
    let topSecondLabels: [String] = [" ","Best", "Average", "Worst", "Worst"]
    let leftFirstColumnLabels: [String] = [ "Quicksort", "Mergesort", "Timsort"]  //  [" ", "Quicksort", "Mergesort", "Timsort", "Heapsort", "Bubble Sort", "Insertion Sort", "Selection Sort", "Tree Sort", "Shell Sort", "Bucket Sort", "Radix Sort", "Counting Sort", "Cubesort"]
    var everyAlgorithmComplexityValues: [[BigOuComplexityType]] = [[.bad, .bad, .horrible0, .good],
                                                                   [.bad, .bad, .bad, .fair],
                                                                   [.fair, .bad, .bad, .fair ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let collectionLayout = collectionView.collectionViewLayout as? ExcelCollectionViewLayout {
            collectionLayout.delegate = self
        }
        
    }
    
    // MARK: - ExcelCollectionViewLayoutDelegate
    // 每一列的 宽高
    func collectionViewLayout(_ collectionViewLayout: ExcelCollectionViewLayout, sizeForItemAtColumn columnIndex: Int) -> CGSize {
        if columnIndex == 0 { //第一列，根据最长的字符串，确定第一列的宽高
            let longestSortName = leftFirstColumnLabels.max(by: { $1.count > $0.count })!
            let longestString = longestSortName.count > topLeftString.count ? longestSortName : topLeftString
            
            let size: CGSize = longestString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
            let width: CGFloat = size.width + 30
            return CGSize(width: width, height: 70)
        }
        
        var columnData: [String] = []
        for index in 0..<everyAlgorithmComplexityValues.count {
            let type = everyAlgorithmComplexityValues[index][columnIndex - 1]
            columnData.append(type.rawValue)
        }
        let longestValueName = String(describing:
            columnData.max(by: {
                String(describing: $1).count > String(describing: $0).count
            })!
        )
        let topString = topSecondLabels[columnIndex - 1] //除了第一列以外的，确认宽高
        let longestString = longestValueName.count > topString.count ? longestValueName : topString
        
        let size: CGSize = longestString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
        let width: CGFloat = size.width + 30
        return CGSize(width: width, height: 70)
    }

    // MARK: - Collection view
    /* 布局如下：
      sec0/row0  sec0/row1 sec0/row2 ... sec0/rowN
      sec1/row0  sec1/row1 sec1/row2 ... sec1/rowN
      ...
      secN/row0  secN/row1 secN/row2 ... secN/rowN
   */
    // Rows
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return everyAlgorithmComplexityValues.count + 2 // 行数，前两行是标题，所以要+2
    }
    
    // Columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topSecondLabels.count // 列数
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        let label = cell.viewWithTag(10) as! UILabel
        
        if indexPath.section == 0 && indexPath.row == 0 {
            label.text = topLeftString
        } else if indexPath.section == 0 {
            label.text = topFirstLabels[indexPath.row - 1]
            label.textColor = .black
        } else if indexPath.section == 1 {
            label.text = topSecondLabels[indexPath.row]
            label.textColor = .black
        } else if indexPath.row == 0 {
            label.text = leftFirstColumnLabels[indexPath.section - 2]
            label.textColor = .black
        } else {
            let type = everyAlgorithmComplexityValues[indexPath.section - 2][indexPath.row - 1]
            label.text = type.rawValue
            label.textColor = (type == .good) ? .green :  .red
        }
        
        if indexPath.section == 0 || indexPath.row == 0 {
            label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        } else {
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
        }
        
        cell.backgroundColor = indexPath.section % 2 == 0 ? .white : UIColor(white: 0.95, alpha: 1)
        
        return cell
    }
  
}

