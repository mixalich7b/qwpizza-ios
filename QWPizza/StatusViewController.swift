//
//  StatusViewController.swift
//  QWPizza
//
//  Created by Тупицин Константин on 16.11.16.
//  Copyright © 2016 Qiwi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireActivityLogger

enum PaymentStatus: String {
    case Waiting = "waiting"
    case Paid = "paid"
    case Rejected = "rejected"
    case Unpaid = "unpaid"
    case Expired = "expired"
}

class StatusViewController: UIViewController {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    public var status: PaymentStatus? {
        didSet {
            updateStatus()
        }
    }
    
    public var sum: String? {
        didSet {
            updateSum()
        }
    }
    
    public var billId: String?
    public var shopId: String?
    public var phone: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStatus()
        updateSum()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkOrder), name: NSNotification.Name("status"), object: Optional.none)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func pay(_ sender: Any) {
        UIApplication.shared.open(URL(string: paymentUrlWith(shopId: shopId!, billId: billId!))!)
    }
    
    func checkOrder(_ sender: Any) {
        Alamofire.request("https://qwpizza.herokuapp.com/status", method: .get, headers: ["Authorization": phone])
            .validate()
            .log()
            .responseJSON {[weak self] response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        self?.billId = json["billId"] as? String
                        self?.shopId = json["shopId"] as? String
                        self?.sum = json["amount"] as? String
                        self?.status = PaymentStatus(rawValue: json["status"] as! String)
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
        }
    }
    
    private func updateStatus() {
        guard let status = status else {
            return
        }
        switch status {
        case .Waiting:
            payButton?.isHidden = false
            statusImageView?.image = UIImage(named: "status_wait")
            break
        case .Paid:
            payButton?.isHidden = true
            statusImageView?.image = UIImage(named: "status_ok")
            break
        default:
            payButton?.isHidden = true
            statusImageView?.image = UIImage(named: "status_fail")
            break
            
        }
    }
    
    private func updateSum() {
        sumLabel?.text = "\(sum ?? "0") ₽"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
