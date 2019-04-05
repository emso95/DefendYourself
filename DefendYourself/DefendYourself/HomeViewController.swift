//
//  HomeViewController.swift
//  DefendYourself
//
//  Created by Emir Can Marangoz on 5.04.2019.
//  Copyright © 2019 Emir Can Marangoz. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBAction func onPlayButton(_ sender: Any) {
        performSegue(withIdentifier: "homeToSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
