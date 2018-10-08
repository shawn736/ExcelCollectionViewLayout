//
//  ExcelCollectionViewLayout.swift
//  ExcelCollectionViewLayout
//
//  Created by Rafael Rocha on 10/2/17.
//

import UIKit

@objc public protocol ExcelCollectionViewLayoutDelegate {
    /**
     Calculate items' size at a particular column here.
     
     - parameters:
     - collectionViewLayout: The current ExcelCollectionViewLayout placed in UICollectionView.
     - columnIndex: The index of column which its items' size will be calculated.
     
     - returns:
     A CGSize representation for items at a particular column index.
     */
    @objc func collectionViewLayout(_ collectionViewLayout: ExcelCollectionViewLayout, sizeForItemAtColumn columnIndex: Int) -> CGSize
}

/*
 https://www.jianshu.com/p/45ff718090a8
 UICollectionViewLayout：对collectionView的布局和行为进行描述
 UICollectionViewLayoutAttributes：每一个cell对应一个该对象，这个对象决定了cell的摆设位置（frame）
 调用顺序：
 1）-(void)prepareLayout  设置layout的结构和初始需要的参数等。
 2)  -(CGSize) collectionViewContentSize 确定collectionView的所有内容的尺寸。
 3）-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect初始的layout的外观将由该方法返回的UICollectionViewLayoutAttributes来决定。
 4)在需要更新layout时，需要给当前layout发送
 1)-invalidateLayout， 该消息会立即返回，并且预约在下一个loop的时候刷新当前layout
 2)-prepareLayout，
 3)依次再调用-collectionViewContentSize和-layoutAttributesForElementsInRect来生成更新后的布局。
 
 */

public class ExcelCollectionViewLayout: UICollectionViewLayout {
    
    public weak var delegate: ExcelCollectionViewLayoutDelegate?
    private var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    private var itemsSize = [CGSize]()
    private var contentSize: CGSize = .zero
    private var numberOfColumns: Int {
        guard collectionView != nil else { fatalError("collectionView must not be nil. See the README for more details.") }
        return collectionView!.numberOfItems(inSection: 0)
    }
    
    // prepare准备方法被自动调用，以保证layout实例的正确
    override public func prepare() {
        guard let collectionView = collectionView else { fatalError("collectionView must not be nil. See the README for more details.") }
        guard collectionView.numberOfSections != 0 else { return }
        
        if itemAttributes.count != collectionView.numberOfSections {
            generateItemAttributes(collectionView: collectionView)
            return
        }
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                if section != 0 && item != 0  && section != 1{ // 不需要粘性的内容
                    continue
                }
                
                let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section))!
                if section == 0 { // 顶部（第一行）粘性
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                
                if section == 1 { // 顶部（第二行）粘性
                    var frame = attributes.frame
                    frame.origin.y = frame.size.height + collectionView.contentOffset.y
                    attributes.frame = frame
                }
                
                if item == 0 { // 左侧（第一列）粘性
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame
                }
            }
        }
    }
    // 内容视图的滑动大小
    override public var collectionViewContentSize: CGSize {
        return contentSize
    }
    // 返回对应于indexPath的位置的cell的布局属性
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }
    // 返回的是rect中的所有元素的布局属性
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in itemAttributes {
            let filteredArray = section.filter { obj -> Bool in
                return rect.intersects(obj.frame)
            }
            
            attributes.append(contentsOf: filteredArray)
        }
        
        return attributes
    }
    // 返回true，每次滑动时都能调用prepare。当边界发生变化时，是否应该刷新布局。
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Helpers
    
    private func generateItemAttributes(collectionView: UICollectionView) {
        if itemsSize.count != numberOfColumns {
            calculateItemSizes()
        }
        
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        
        itemAttributes = []
        
        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            
            for index in 0..<numberOfColumns {
                let itemSize = itemsSize[index]
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                
                if section == 0 && index == 0 || section == 1 && index == 0 {
                    attributes.zIndex = 1024 // 设置(sec0row0)的第一项，使其能在第一列和第一行之上
                } else if section == 0 || index == 0  {
                    attributes.zIndex = 1023 // 设置第一列和第一行在其余未设置的item之上
                } else if section == 1 {
                    attributes.zIndex = 1022 //设置第二行在其余未设置的item之上
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame // 顶部（第一行）粘性，保持y值不变
                }
                
                if section == 1 {
                    var frame = attributes.frame
                    frame.origin.y = frame.size.height + collectionView.contentOffset.y
                    attributes.frame = frame // 顶部（第一行）粘性，保持y值不变
                }
                
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame // 左侧（第一列）粘性，保持x值不变
                }
                
                sectionAttributes.append(attributes)
                
                xOffset += itemSize.width
                column += 1
                
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            
            itemAttributes.append(sectionAttributes)
        }
        
        if let attributes = itemAttributes.last?.last { // 获取最后的一个item，计算content的全部高度
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }
    
    private func calculateItemSizes() {
        guard delegate != nil else {
            fatalError("delegate must be set in order to calculate items' size. See the README for more details.")
        }
        
        itemsSize = []
        
        for index in 0..<numberOfColumns {
            itemsSize.append(delegate!.collectionViewLayout(self, sizeForItemAtColumn: index))
        }
    }
}
