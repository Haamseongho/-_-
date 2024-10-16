//
//  CollectionModel.swift
//  RestFulApp
//
//  Created by haams on 10/10/24.
//

import Foundation
import UIKit

struct CollectionModel {
    let openImage: UIImageView
    let title: String
    let requestCount: Int
    let optionImage: UIImageView
    let borderView: UIView
    
    var subItems: [RequestModel]
    var isExpanded: Bool // 추가: 각 셀의 열림/닫힘 상태를 추적
}
