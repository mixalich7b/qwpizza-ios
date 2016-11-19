//
//  Utils.swift
//  QWPizza
//
//  Created by Тупицин Константин on 19.11.16.
//  Copyright © 2016 Qiwi. All rights reserved.
//

import Foundation

func paymentUrlWith(shopId: String, billId: String) -> String {
    return "https://w.qiwi.com/order/external/main.action?shop=\(shopId)&transaction=\(billId)&successUrl=qwpizza://success&failUrl=qwpizza://fail"
}
