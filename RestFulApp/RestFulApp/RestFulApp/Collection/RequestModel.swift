//
//  RequestModel.swift
//  RestFulApp
//
//  Created by haams on 10/10/24.
//

import Foundation
import UIKit

struct RequestModel {
    let type: String
    let title: String
    let optionImage: UIImageView
}

struct ApiModel {
    let type: String
    let title: String
    let url: String? = ""
}
