#!/usr/bin/env swift

// <bitbar.title>Currency Tracker for Korean</bitbar.title>
// <bitbar.version>v1.0</bitbar.version>
// <bitbar.author>Lyuha</bitbar.author>
// <bitbar.author.github>@lyuha</bitbar.author.github>
// <bitbar.desc>track currencies getted from Hana bank</bitbar.desc>
// <bitbar.image>http://www.hosted-somewhere/pluginimage</bitbar.image>
// <bitbar.dependencies>swift</bitbar.dependencies>
// <bitbar.abouturl>http://url-to-about.com/</bitbar.abouturl>

import Foundation

// determine output format ￦1200
// default output format 1200원
let wonSign: Bool = false

// filter currency
//
let currencyFilter = [
    "USD": 1,
    "JPY": 100,
    "EUR": 1,
]


func doRequest() {
    // Use Hana Bank
    let URLParameters = [
        "targetMethod": "doTextDownload",
        "excelFileName": "현재환율.txt"
    ]
    let baseURL = "http://fx.keb.co.kr/FER1101C.web"
    // http://fx.keb.co.kr/FER1101C.web?targetMethod=doTextDownload&excelFileName=현재환율.txt
    var targetURL: String = baseURL

    if !URLParameters.isEmpty {
        var params: [String] = []
        for (key, value) in URLParameters {
            if let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                params.append(escapedKey + "=" + escapedValue)
            }
        }
        targetURL += "?" + params.joinWithSeparator("&")
    }

    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

    let url = NSURL(string: targetURL)!

    let task = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        if (error == nil) {
            // Success
            let rawData = NSString(data: data!, encoding: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)))
            if rawData!.containsString("<html") {
                print("FUCKING")
            } else {
                let table = rawData!.componentsSeparatedByString("\r\n").filter({ (element) -> Bool in element != "" })
                let _ = table[1].substringWithRange(table[1].startIndex.advancedBy(6)..<table[1].endIndex) // day
                let _ = table[2].substringWithRange(table[2].startIndex.advancedBy(7)..<table[2].endIndex) //time
                let _ = table[4].componentsSeparatedByString("\t").map({ (element) in element.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())}) // columnName
                let currentCurrencies = table[5..<table.count].map({ (element) in element.componentsSeparatedByString("\t").map({ (e) in e.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())}) })
                currentCurrencies.filter({ (element) in
                    currencyFilter.indexForKey(element[0].componentsSeparatedByString(" ")[1]) != nil
                }).forEach({ (element) in
                    var output = ""
                    let currency = element[0].componentsSeparatedByString(" ")
                    output += currency[1] + " "
                    if currency.count == 3 {
                        output += currency[2]
                    } else {
                        output += "1"
                    }
                    output += " : "
                    if wonSign {
                        output += "￦ " + element[9]
                    } else {
                        output += element[9] + " 원"
                    }
                    print(output)
                })
            }
        }
        else {
            // Failure
            print("URL Session Task Failed: %@", error!.localizedDescription);
        }
    })
    task.resume()
}

doRequest()
sleep(2)
