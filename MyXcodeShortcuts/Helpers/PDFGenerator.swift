//
//  PDFGenerator.swift
//  MyXcodeFaves
//
//  Created by Brent Michalski on 3/25/24.
//

import SwiftUI
import PDFKit

class PDFGenerator {
    var categories: [Category]
    
    // MARK: - PDF Formatting
    fileprivate let margin: CGFloat = 20
    fileprivate let topMargin: CGFloat = 100
    fileprivate let bottomMargin: CGFloat = 60
    fileprivate let lineHeight: CGFloat = 20
    fileprivate let categoryLineHeight: CGFloat = 30
    // Breathing room between a column's edge and the text inside it, so key combos and
    // details don't look flush-cut against the column boundary or center divider.
    fileprivate let textInset: CGFloat = 6
    // PDF pages are always a fixed white/light-gray background (see renderCategories'
    // normalBackgroundColor/alternateBackgroundColor below), but these came from adaptive
    // SwiftUI Colors that track the device's current light/dark appearance - so generating
    // a PDF while in Dark Mode drew near-white text on a white page. Resolving against a
    // fixed light trait collection once, here, freezes them as plain static colors that
    // stay legible regardless of what appearance the device happens to be in when the
    // button is tapped.
    private static let lightAppearance = UITraitCollection(userInterfaceStyle: .light)
    let headerColor = UIColor(ThemeManager.appPDFHeaderColor).resolvedColor(with: lightAppearance)
    let textColor = UIColor(ThemeManager.appPrimaryTextColor).resolvedColor(with: lightAppearance)
    fileprivate let PDFSize = CGSize(width: 612, height: 792)
    
    fileprivate var pageNumber: Int = 1
    fileprivate var column: CGFloat = 0
    fileprivate var firstPage = true
    
    fileprivate var documentPath: URL? {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsUrl.appendingPathComponent("MyFavoriteShortcuts.pdf")
    }
    
    let statusManager: StatusManager
    
    var pdfDocument: PDFDocument = PDFDocument()
    
    init(categories: [Category], statusManager: StatusManager) {
        self.categories = categories
        self.statusManager = statusManager
    }
    
    func renderDocument() -> PDFDocument? {
        createPDF()
        
        if let url = documentPath {
            if let doc = PDFDocument(url: url) {
                pdfDocument = doc
            }
            return PDFDocument(url: url)
        }
        return nil
    }
    
    func createPDF() {
        guard let pdfPath = documentPath?.path else { return }
        UIGraphicsBeginPDFContextToFile(pdfPath, .zero, nil)
        newPage()
        renderCategories()
        UIGraphicsEndPDFContext()
    }
    
    func renderCategories() {
        let width = PDFSize.width * 0.5 - margin * 2
        var total = topMargin
        
        let categoryHeaderFont = UIFont.boldSystemFont(ofSize: 16)
        let categoryAttributes = [NSAttributedString.Key.font: categoryHeaderFont, NSAttributedString.Key.foregroundColor: headerColor]
        let bodyFont = UIFont.systemFont(ofSize: 11)
        let bodyAttributes = [NSAttributedString.Key.font: bodyFont, NSAttributedString.Key.foregroundColor: textColor]
        // The font's own line height is shorter than a row's `lineHeight`, so drawing text
        // flush at a row's top edge leaves empty space below it and makes it look like it's
        // sitting high on the row's gray background instead of centered in it.
        let bodyTextVerticalOffset = max(0, (lineHeight - bodyFont.lineHeight) / 2)
        // Same idea for the category header: it has its own slack below `categoryLineHeight`.
        // Push the header text down to the bottom of its slot instead of the top, so the
        // leftover space sits above the header (separating it from the previous section)
        // rather than below it (making it read as part of the previous section).
        let categoryHeaderVerticalOffset = max(0, categoryLineHeight - categoryHeaderFont.lineHeight)

        // Define background colors for alternating rows
        let normalBackgroundColor = UIColor(white: 1.0, alpha: 1.0) // White for normal rows
        let alternateBackgroundColor = UIColor(white: 0.95, alpha: 1.0) // Light gray for alternate rows
        
        for category in categories.sorted(by: { $0.order < $1.order }) {
            let shortcuts = category.shortcuts.sorted { $0.order < $1.order }.filter { $0.matchesStatus(statusManager.currentStatus.intValue) }
            
            if shortcuts.isEmpty { continue }
            
            var xValue = margin + column * (width + margin + (column > 0 ? 20 : 0))
            
            if total + categoryLineHeight > PDFSize.height - bottomMargin {
                if column == 1 {
                    newPage()
                    xValue = margin
                } else {
                    column += 1
                    xValue = margin + column * (width + margin) + (column > 0 ? 20 : 0)
                }
                total = topMargin
            }
            
            let categoryName = "\(category.name) (\(shortcuts.count))"
            categoryName.draw(at: CGPoint(x: xValue + textInset, y: total + categoryHeaderVerticalOffset), withAttributes: categoryAttributes)
            total += categoryLineHeight

            for (shortcutIndex, shortcut) in shortcuts.enumerated() {
                let keyCombo = shortcut.keyCombo.parseForControlCharacterMapping(returnType: statusManager.showSymbols ? .symbol : .long)
                let detailsWidth = (shortcut.details as NSString).size(withAttributes: bodyAttributes).width
                let detailsX = xValue + width - textInset - detailsWidth  // Right-align the details

                // Background color fill
                let backgroundColor = shortcutIndex % 2 == 0 ? normalBackgroundColor : alternateBackgroundColor
                let backgroundRect = CGRect(x: xValue, y: total, width: width, height: lineHeight)
                backgroundColor.setFill()
                UIRectFill(backgroundRect)

                // Draw key combo and details, vertically centered within the row
                keyCombo.draw(at: CGPoint(x: xValue + textInset, y: total + bodyTextVerticalOffset), withAttributes: bodyAttributes)
                let descriptionRect = CGRect(x: detailsX, y: total + bodyTextVerticalOffset, width: detailsWidth, height: lineHeight)
                shortcut.details.draw(with: descriptionRect, options: .usesLineFragmentOrigin, attributes: bodyAttributes, context: nil)
                
                total += lineHeight

                // Only break to a new column/page - and print a "(continued)" header - if
                // there are actually more shortcuts left to draw. Otherwise this triggers on
                // whichever row happens to land at the bottom of a column even when it was
                // the category's last item, printing a "(continued)" header for a section
                // that has nothing left to continue.
                let hasMoreShortcuts = shortcutIndex < shortcuts.count - 1
                if total > PDFSize.height - bottomMargin && hasMoreShortcuts {
                    if column == 1 {
                        newPage()
                        xValue = margin
                    } else {
                        column += 1
                        xValue = margin + column * (width + margin) + (column > 0 ? 20 : 0)
                    }
                    total = topMargin

                    let continuationText = "\(categoryName) (continued)"
                    continuationText.draw(at: CGPoint(x: xValue + textInset, y: total + categoryHeaderVerticalOffset), withAttributes: categoryAttributes)
                    total += categoryLineHeight
                }
            }
        }
    }

    fileprivate func newPage() {
        UIGraphicsBeginPDFPage()
        renderHeader()
        renderFooter()
        renderCenterLine()
        printPageNumber()
        self.column = 0
        firstPage = false
    }
    
    fileprivate func renderHeader() {
        guard let logo = UIImage(named: "AppIconTransparent") else { return }
        let rect = CGRect(x: 10, y: 10, width: 70, height: 70)
        logo.draw(in: rect)
        
        let text = statusManager.pdfTitle
        let attributes: [NSAttributedString.Key : NSObject]
        if firstPage {
            attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                          NSAttributedString.Key.foregroundColor: headerColor]
            firstPage = false
        } else {
            attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                          NSAttributedString.Key.foregroundColor: headerColor]
        }
        text.draw(at: CGPoint(x: 100, y: 50), withAttributes: attributes)
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setShadow(offset: CGSize(width: 2, height: 2), blur: 5.0)
        let line = UIBezierPath(rect: CGRect(x: 0, y: 0, width: PDFSize.width - 20, height: 3))
        let transform = CGAffineTransform(translationX: 10, y: 80)
        line.apply(transform)
        line.fill()
        context?.restoreGState()
    }
    
    fileprivate func renderFooter() {
        let leftText = "Inspired By: raywenderlich.com/Kodeco.com"
        let rightText = "©2026 Brent Michalski. All rights reserved"
        leftText.draw(at: CGPoint(x: margin, y: PDFSize.height - 20))
        rightText.draw(at: CGPoint(x: PDFSize.width - 250, y: PDFSize.height - 20))
    }
    
    fileprivate func renderCenterLine() {
        let line = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0.5, height: PDFSize.height - topMargin - bottomMargin + 20))
        let transform = CGAffineTransform(translationX: PDFSize.width/2 , y: topMargin)
        line.apply(transform)
        textColor.setFill()
        line.fill()
    }
    
    fileprivate func printPageNumber() {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                          NSAttributedString.Key.foregroundColor: textColor]
        let pageNumberString = "Page \(pageNumber)"
        pageNumberString.draw(at: CGPoint(x: PDFSize.width - 60, y: 60), withAttributes: attributes)
        pageNumber += 1
        
    }
}
