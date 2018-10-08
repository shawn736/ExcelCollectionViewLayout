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
      case excellent0 = "O(k)"
      case good = "O(logn)"
      case fair = "O(n)"
      case fair0 = "O(n+k)"
      case fair1 = "O(nk)"
      case bad = "O(nlogn)"
      case horrible = "O((nlogn)^2)"
      case horrible0 = "O(n^2)"
      case horrible1 = "O(2^n)"
      case horrible2 = "O(n!)"
      
    }
  
    let topFirstRow: [String] = ["Algorithm", "Time Complexity", "", "", "Space Complexity"]
    var topSecondRow: [String] = ["", "Best", "Average", "Worst", "Worst"]
    var allAlgorithmComplexityValues: [[String: [BigOuComplexityType]]] = [["Quicksort": [.bad, .bad, .horrible0, .good]],
                                                                          ["Mergesort": [.bad, .bad, .bad, .fair]],
                                                                          ["Timsort": [.fair, .bad, .bad, .fair ]],
                                                                          ["Heapsort": [.bad, .bad, .bad, .excellent]],
                                                                          ["Bubble Sort": [.fair, .horrible0, .horrible0, .excellent]],
                                                                          ["Insertion Sort": [.fair, .horrible0, .horrible0, .excellent]],
                                                                          ["Selection Sort": [.horrible0, .horrible0, .horrible0, .excellent]],
                                                                          ["Tree Sort": [.bad, .bad, .horrible0, .fair]],
                                                                          ["Shell Sort": [.bad, .horrible, .horrible, .excellent]],
                                                                          ["Bucket Sort": [.fair0, .fair0, .horrible0, .fair]],
                                                                          ["Radix Sort": [.fair1, .fair1, .fair1, .fair0]],
                                                                          ["Counting Sort": [.fair0, .fair0, .fair0, .excellent0]],
                                                                          ["Cubesort": [.fair, .bad, .bad, .fair]],
                                                                          ]
    var leftFirstColumn: [String] {
      return allAlgorithmComplexityValues.map{ $0.keys.first! }
    }
  
    var complexityValues: [[BigOuComplexityType]] {
      return allAlgorithmComplexityValues.map{ $0.values.first! }
    }
  
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
            let longestSortName = leftFirstColumn.max(by: { $1.count > $0.count })!
            let topLeftString = topFirstRow[0]
            let longestString = longestSortName.count > topLeftString.count ? longestSortName : topLeftString
            
            let size: CGSize = longestString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
            let width: CGFloat = size.width + 30
            return CGSize(width: width, height: 70)
        }
        
        var columnData: [String] = []
        for index in 0..<complexityValues.count {
            let type = complexityValues[index][columnIndex - 1]
            columnData.append(type.rawValue)
        }
        let longestValueName = String(describing:
            columnData.max(by: {
                String(describing: $1).count > String(describing: $0).count
            })!
        )
        let topString = topSecondRow[columnIndex - 1] //除了第一列以外的，确认宽高
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
        return allAlgorithmComplexityValues.count + 2 // 行数，前两行是标题，所以要+2
    }
    
    // Columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topSecondRow.count // 列数
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        let label = cell.viewWithTag(10) as! UILabel
        
        if indexPath.section == 0 {
            label.text = topFirstRow[indexPath.row]
            label.textColor = .black
        } else if indexPath.section == 1 {
            label.text = topSecondRow[indexPath.row]
            label.textColor = .black
        } else if indexPath.row == 0 {
            label.text = leftFirstColumn[indexPath.section - 2]
            label.textColor = .black
        } else {
            let type = complexityValues[indexPath.section - 2][indexPath.row - 1]
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

