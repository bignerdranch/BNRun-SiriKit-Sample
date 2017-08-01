//
//  BNRunUITests.swift
//  BNRunUITests
//
//  Created by hsoi on 8/29/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import XCTest

class BNRunUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    

    func testStartRunSiri() {
        XCUIDevice.shared.siriService.activate(voiceRecognitionText: "walk 500 miles in Big Nerd Run")
    }
}
