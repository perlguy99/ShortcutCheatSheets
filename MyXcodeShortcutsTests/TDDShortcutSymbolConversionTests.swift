//
//  TDDShortcutSymbolConversionTests.swift
//  MyXcodeShortcutsTests
//
//  Created by Brent Michalski on 4/30/24.
//

import XCTest
import SwiftUI

@testable import ShortcutCheatsheets

class TDDShortcutSymbolConversionTests: XCTestCase {
    let testSeparator = "~"
    
    func testThatStringCanParse_Cmd_Properly() {
        let sut = "cmd x"
        
        let expectedLongString = "Command~X"
        let expectedShortString = "Cmd~X"
        let expectedSymbolString = "\u{2318}~X"
        let expectedDefaultString = "\u{2318} X"
        
        let segments = sut.split(separator: " ")
        let defaultMapping      = sut.parseForControlCharacterMapping()
        let actualLongMapping   = sut.parseForControlCharacterMapping(separator: "~", returnType: .long)
        let actualShortMapping  = sut.parseForControlCharacterMapping(separator: "~", returnType: .short)
        let actualSymbolMapping = sut.parseForControlCharacterMapping(separator: "~", returnType: .symbol)
        
        XCTAssertEqual(segments.count, 2)
        
        XCTAssertEqual(expectedDefaultString, defaultMapping)
        XCTAssertEqual(expectedLongString, actualLongMapping)
        XCTAssertEqual(expectedShortString, actualShortMapping)
        XCTAssertEqual(expectedSymbolString, actualSymbolMapping)
    }

    
    func testThatStringCanParse_Ctrl_Properly() {
        let sut = "ctrl x"
        
        let expectedLongString = "Control~X"
        let expectedShortString = "Ctrl~X"
        let expectedSymbolString = "\u{2303}~X"
        let expectedDefaultString = "\u{2303} X"
        
        let segments = sut.split(separator: " ")
        let defaultMapping      = sut.parseForControlCharacterMapping()
        let actualLongMapping   = sut.parseForControlCharacterMapping(separator: "~", returnType: .long)
        let actualShortMapping  = sut.parseForControlCharacterMapping(separator: "~", returnType: .short)
        let actualSymbolMapping = sut.parseForControlCharacterMapping(separator: "~", returnType: .symbol)
        
        XCTAssertEqual(segments.count, 2)
        
        XCTAssertEqual(expectedDefaultString, defaultMapping)
        XCTAssertEqual(expectedLongString, actualLongMapping)
        XCTAssertEqual(expectedShortString, actualShortMapping)
        XCTAssertEqual(expectedSymbolString, actualSymbolMapping)
    }

    
    func testThatStringCanParse_CmdCtrl_Properly() {
        let sut = "cmd ctrl x"
        
        let expectedLongString = "Command~Control~X"
        let expectedShortString = "Cmd~Ctrl~X"
        let expectedSymbolString = "\u{2318}~\u{2303}~X"
        let expectedDefaultString = "\u{2318} \u{2303} X"
        
        let segments = sut.split(separator: " ")
        let defaultMapping      = sut.parseForControlCharacterMapping()
        let actualLongMapping   = sut.parseForControlCharacterMapping(separator: "~", returnType: .long)
        let actualShortMapping  = sut.parseForControlCharacterMapping(separator: "~", returnType: .short)
        let actualSymbolMapping = sut.parseForControlCharacterMapping(separator: "~", returnType: .symbol)
        
        XCTAssertEqual(segments.count, 3)
        
        XCTAssertEqual(expectedDefaultString, defaultMapping)
        XCTAssertEqual(expectedLongString, actualLongMapping)
        XCTAssertEqual(expectedShortString, actualShortMapping)
        XCTAssertEqual(expectedSymbolString, actualSymbolMapping)
    }

    func testThatStringCanParse_CtrlCmd_Properly() {
        let sut = "ctrl cmd x"
        
        let expectedLongString = "Control~Command~X"
        let expectedShortString = "Ctrl~Cmd~X"
        let expectedSymbolString = "\u{2303}~\u{2318}~X"
        let expectedDefaultString = "\u{2303} \u{2318} X"
        
        let segments = sut.split(separator: " ")
        let defaultMapping      = sut.parseForControlCharacterMapping()
        let actualLongMapping   = sut.parseForControlCharacterMapping(separator: "~", returnType: .long)
        let actualShortMapping  = sut.parseForControlCharacterMapping(separator: "~", returnType: .short)
        let actualSymbolMapping = sut.parseForControlCharacterMapping(separator: "~", returnType: .symbol)
        
        XCTAssertEqual(segments.count, 3)
        
        XCTAssertEqual(expectedDefaultString, defaultMapping)
        XCTAssertEqual(expectedLongString, actualLongMapping)
        XCTAssertEqual(expectedShortString, actualShortMapping)
        XCTAssertEqual(expectedSymbolString, actualSymbolMapping)
    }

    func testThatStringCanParse_Everything_Properly() {
        let sut = "cmd ctrl shift opt return uparrow downarrow rightarrow leftarrow tab x"
        
        let expectedLongString = "Command~Control~Shift~Option~Return~UpArrow~DownArrow~RightArrow~LeftArrow~Tab~X"
        let expectedShortString = "Cmd~Ctrl~Shft~Opt~Rtn~UArr~DArr~RArr~LArr~Tab~X"
        let expectedSymbolString = "\u{2318}~\u{2303}~\u{21E7}~\u{2325}~\u{23CE}~\u{2191}~\u{2193}~\u{2192}~\u{2190}~\u{21E5}~X"
        let expectedDefaultString = "\u{2318} \u{2303} \u{21E7} \u{2325} \u{23CE} \u{2191} \u{2193} \u{2192} \u{2190} \u{21E5} X"
        
        let segments = sut.split(separator: " ")
        let defaultMapping      = sut.parseForControlCharacterMapping()
        let actualLongMapping   = sut.parseForControlCharacterMapping(separator: "~", returnType: .long)
        let actualShortMapping  = sut.parseForControlCharacterMapping(separator: "~", returnType: .short)
        let actualSymbolMapping = sut.parseForControlCharacterMapping(separator: "~", returnType: .symbol)
        
        XCTAssertEqual(segments.count, 11)
        
        XCTAssertEqual(expectedDefaultString, defaultMapping)
        XCTAssertEqual(expectedLongString, actualLongMapping)
        XCTAssertEqual(expectedShortString, actualShortMapping)
        XCTAssertEqual(expectedSymbolString, actualSymbolMapping)
    }

    func testParseForControlCharacterMapping() {
        let testString = "cmd opt ctrl shift return"
        let expectedOutput = "\u{2318} \u{2325} \u{2303} \u{21E7} \u{23CE}"
        
        let result = testString.parseForControlCharacterMapping(returnType: .symbol)
        
        XCTAssertEqual(result, expectedOutput, "The control character parsing did not produce the expected symbols.")
    }
}
