//
//  ViewController.swift
//  QWPizza
//
//  Created by Тупицин Константин on 15.11.16.
//  Copyright © 2016 Qiwi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireActivityLogger

private enum Product: String {
    case Pizza = "pizza"
    case RedBull = "redbull"
}

class ViewController: UIViewController {

    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var pizzaCountLabel: UILabel!
    @IBOutlet weak var redBullCountLabel: UILabel!
    
    private var order: [Product.RawValue: Int] = [Product.Pizza.rawValue: 0, Product.RedBull.rawValue: 0] {
        didSet {
            pizzaCountLabel.text = String(order[Product.Pizza.rawValue]!)
            redBullCountLabel.text = String(order[Product.RedBull.rawValue]!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkOrder), name: NSNotification.Name("status"), object: Optional.none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commentField.resignFirstResponder()
        phoneField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addPizza(_ sender: Any) {
        order[Product.Pizza.rawValue] = order[Product.Pizza.rawValue]! + 1
    }

    @IBAction func addRedBull(_ sender: Any) {
        order[Product.RedBull.rawValue] = order[Product.RedBull.rawValue]! + 1
    }
    
    @IBAction func makeOrder(_ sender: Any) {
        Alamofire.request("http://localhost/order", method: .post, parameters: ["products": order, "comment": commentField.text!], encoding: JSONEncoding.default, headers: ["Authorization": phoneField.text!])
            .validate()
            .log()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = value as! [String: Any]
                    let checkoutURL = "https://w.qiwi.com/order/external/main.action?shop=\(json["shopId"])&transaction=\(json["billId"])&successUrl=qwpizza://success&failUrl=qwpizza://fail"
                    UIApplication.shared.open(URL(string: checkoutURL)!)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @IBAction func checkOrder(_ sender: Any) {
        Alamofire.request("http://localhost/status", method: .post, encoding: JSONEncoding.default, headers: ["Authorization": phoneField.text!])
            .validate()
            .log()
            .responseJSON {[weak self] response in
                switch response.result {
                case .success(let value):
                    self?.performSegue(withIdentifier: "status", sender: value)
                    break
                default:
                    self?.performSegue(withIdentifier: "status", sender: ["shopId": "123", "billId": "1235", "status": "waiting", "amount": "100500"])
                    break
                }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let json = sender as? [String: Any], let statusViewController = segue.destination as? StatusViewController {
            statusViewController.billId = json["billId"] as? String
            statusViewController.shopId = json["shopId"] as? String
            statusViewController.sum = json["amount"] as? String
            statusViewController.status = PaymentStatus(rawValue: json["status"] as! String)
            statusViewController.phone = phoneField.text!
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
