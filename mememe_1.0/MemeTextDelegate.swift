//
//  MemeTextDelegate.swift
//  mememe_1.0
//
//  Created by Bruno Pontes Lira on 05/08/21.
//

import Foundation
import UIKit

class MemeTextDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Clear textField containing default text
        if ((textField.text == defaultTopText) || (textField.text == defaultBottomText)){
            textField.text = ""
        }
    }
    
    //Close keyboard when user presses return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
