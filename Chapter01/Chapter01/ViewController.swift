//
//  ViewController.swift
//  Chapter01
//
//  Created by haams on 8/7/24.
//

import UIKit

class ViewController: UIViewController {

    // IBOutlet = Code -> Design
    @IBOutlet weak var diceImageViewOne: UIImageView!
    @IBOutlet weak var diceImageViewTwo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // who.what = value
        diceImageViewOne.alpha = 0.5
        diceImageViewTwo.alpha = 0.5
    }
    // IBAction = Design -> Code
    @IBAction func btnRollPressed(_ sender: Any) {
        let diceArray = [UIImage(imageLiteralResourceName: "DiceOne"), UIImage(imageLiteralResourceName: "DiceTwo")
        ,UIImage(imageLiteralResourceName: "DiceThree"), UIImage(imageLiteralResourceName: "DiceFour"),
                         UIImage(imageLiteralResourceName: "DiceFive"), UIImage(imageLiteralResourceName: "DiceSix")]
        diceImageViewOne.image = diceArray[Int.random(in: 0...5)] // 왼쪽 주사위
        
        diceImageViewTwo.image = diceArray.randomElement() // 오른쪽 주사위
      
    }
    
}

