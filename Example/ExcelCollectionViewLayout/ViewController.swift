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
    let salary: Int = 2000
    let topLeftString: String = "My Salary Control"
    let topLabels: [String] = ["Salary", "Bills", "Shopping", "Parties", "Total"]
    var months: [String] = []
    var monthlyValues: [[Int]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let collectionLayout = collectionView.collectionViewLayout as? ExcelCollectionViewLayout {
            collectionLayout.delegate = self
        }
        
        prepareData()
    }
    
    // MARK: - ExcelCollectionViewLayoutDelegate
    // 每一列的 宽高
    func collectionViewLayout(_ collectionViewLayout: ExcelCollectionViewLayout, sizeForItemAtColumn columnIndex: Int) -> CGSize {
        if columnIndex == 0 { //第一列，根据最长的字符串，确定第一列的宽高
            let biggestMonth = months.max(by: { $1.count > $0.count })!
            let biggestString = biggestMonth.count > topLeftString.count ? biggestMonth : topLeftString
            
            let size: CGSize = biggestString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
            let width: CGFloat = size.width + 30
            return CGSize(width: width, height: 70)
        }
        
        var columnData: [String] = []
        for index in 0..<monthlyValues.count {
            let valueFormatted = formatCurrency(monthlyValues[index][columnIndex - 1])
            columnData.append(valueFormatted)
        }
        let biggestValue = String(describing:
            columnData.max(by: {
                String(describing: $1).count > String(describing: $0).count
            })!
        )
        let topString = topLabels[columnIndex - 1] //除了第一列以外的，确认宽高
        let biggestString = biggestValue.count > topString.count ? biggestValue : topString
        
        let size: CGSize = biggestString.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
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
        return months.count + 1 // 行数，第一行是标题，所以要+1
    }
    
    // Columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topLabels.count + 1 // 列数，第一列是标题，所以要+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        let label = cell.viewWithTag(10) as! UILabel
        
        if indexPath.section == 0 && indexPath.row == 0 {
            label.text = topLeftString
        } else if indexPath.section == 0 {
            label.text = topLabels[indexPath.row - 1]
            label.textColor = .black
        } else if indexPath.row == 0 {
            label.text = months[indexPath.section - 1]
            label.textColor = .black
        } else {
            let value = monthlyValues[indexPath.section - 1][indexPath.row - 1]
            label.text = formatCurrency(value)
            label.textColor = value < 0 ? .red : .black
        }
        
        if indexPath.section == 0 || indexPath.row == 0 {
            label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        } else {
            label.font = UIFont.systemFont(ofSize: label.font.pointSize)
        }
        
        cell.backgroundColor = indexPath.section % 2 == 0 ? .white : UIColor(white: 0.95, alpha: 1)
        
        return cell
    }
    
    // MARK: - Data
    
    func prepareData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-yyyy"
        
        months.append(formatter.string(from: Date()))
        for diff in 1...12 {
            let diffDate = Calendar.current.date(byAdding: .month, value: -diff, to: Date())!
            months.append(formatter.string(from: diffDate))
        }
        
        for month in 0..<months.count {
            for index in 0..<topLabels.count {
                var value = salary
                if index == topLabels.count - 1 {
                    value = total(for: month)
                } else if index != 0 {
                    value = Int(arc4random_uniform(2000))
                }
                
                if monthlyValues.count == month {
                    monthlyValues.append([value])
                } else {
                    monthlyValues[month].append(value)
                }
            }
        }
    }
    
    func total(for month: Int) -> Int {
        let data = monthlyValues[month]
        
        var total = data[0]
        for index in 1..<data.count - 1 {
            total -= data[index]
        }
        return total
    }
    
    func formatCurrency(_ value: Int) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: number)!
    }
}

