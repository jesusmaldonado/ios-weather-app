//
//  FirstViewController.swift
//  weather app
//
//  Created by Jesús Maldonado on 9/26/15.
//  Copyright © 2015 Jesus Maldonado. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController , UITextFieldDelegate {
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func makeRequest(city: String!) -> Void {
        let city = cityName.text!.capitalizedString
        let cityWithDashes = city.componentsSeparatedByString(" ").joinWithSeparator("-")
        let urlString = "http://www.weather-forecast.com/locations/" + cityWithDashes + "/forecasts/latest"
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            if let urlContent = data {
                let webContent = NSString(data: urlContent, encoding: NSUTF8StringEncoding)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let matches = self.matchesForRegexInText("<div data-magellan-destination=\"forecast-part-0\"></div></a><p class=\"summary\"><b>(.+)</p>", text: webContent! as String)
                    if matches.count == 0 {
                        self.errorMessageLabel.text = "Your search for \(self.cityName.text!) didn't match anything."
                        
                        return
                    }
                    let weatherStringWithHTML = matches[0]
                    let intermediateString = weatherStringWithHTML.stringByReplacingOccurrencesOfString("<div data-magellan-destination=\"forecast-part-0\"></div></a><p class=\"summary\"><b>", withString: "")
                    let secondIntermediateString = intermediateString.stringByReplacingOccurrencesOfString("</b><span class=\"read-more-small\"><span class=\"read-more-content\"> <span class=\"phrase\">", withString: "")
                    let finalString = secondIntermediateString.stringByReplacingOccurrencesOfString("</span></span></span></p>", withString: "")
                    self.webView.loadHTMLString(finalString, baseURL: nil)
                    self.errorMessageLabel.text = ""
                })
            } else {
                self.errorMessageLabel.text = "Your search for \(self.cityName.text!) didn't match anything."
              
            }
        }
        
        task.resume()
    }
    @IBOutlet var errorMessageLabel: UILabel!
    
    @IBAction func checkWeather(sender: AnyObject) {
        if !cityName.text!.isEmpty {
            makeRequest(cityName.text!)
        } else {
            errorMessageLabel.text = "Input a city to check the weather with!"
            self.webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML = \"\";")      }
        
    }

    @IBOutlet var cityName: UITextField!

    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityName.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.checkWeather(self)
        return true
    }

}

