//
//  ImageProcessor.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import CoreImage
import RandomKit
import UIImageSwiftExtensions
import Vivid

private struct Color {
    
    var b: UInt8
    var g: UInt8
    var r: UInt8
    var a: UInt8
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(color: UIColor) {
        var bF: CGFloat = 0
        var gF: CGFloat = 0
        var rF: CGFloat = 0
        var aF: CGFloat = 0
        color.getRed(&rF, green: &gF, blue: &bF, alpha: &aF)
        let mult: (CGFloat) -> UInt8 = { UInt8(CGFloat($0) * 255.0) }
        self.init(r: mult(rF), g: mult(gF), b: mult(bF), a: mult(aF))
    }
    
    mutating func tint(_ color: Color) {
        let tnt: (UInt8, UInt8) -> UInt8 = {
            let tintFactor = CGFloat($0.1) / 255.0
            let result = CGFloat($0.0) + CGFloat(255 - $0.0) * tintFactor
            return UInt8(result)
        }
        b = tnt(b, color.b)
        g = tnt(g, color.g)
        r = tnt(r, color.r)
        a = tnt(a, color.a)
    }
    
}

private struct ContextInfo {
    let original: CGImage
    let context: CGContext
    let coreImageContext: CIContext
    let width: Int
    let height: Int
    let bytesPerRow: Int
    let data: UnsafeMutableBufferPointer<Color>
    let colorsPerRow: Int
    let consumedRects: [CGRect]
}

enum Effect {
    
    case sprinkle
    case copy
    case copyTint
    case placeImage
    case faceMash
    case starfield
    
    private func randomRegion(_ start: Int? = nil, length: Int? = nil, info: ContextInfo) -> Range<UnsafeMutableBufferPointer<Color>.Index> {
        let len = length ?? (Int.positiveRandom() % (info.data.count / 2))
        let y = Int.positiveRandom() % (info.height / 2)
        let x = Int.positiveRandom() % (info.width / 2)
        let s = start ?? (y * info.colorsPerRow) + x
        let end = min(s + len, info.data.count)
        return s..<end
    }
    
    private func applySprinkle(_ info: ContextInfo) {
        let i = Int.random(within: 0...(info.data.count - 1))
        var c = info.data[i]
        c.r = Bool.random() ? UInt8(Int.random(within: 0...255)) : c.r
        c.g = Bool.random() ? UInt8(Int.random(within: 0...255)) : c.g
        c.b = Bool.random() ? UInt8(Int.random(within: 0...255)) : c.b
        info.data[i] = c
    }
    
    private func applyCopy(_ info: ContextInfo, tint: Bool = false) {
        
        let minHeight = 5 * info.colorsPerRow
        let length = Int.random(within: minHeight ... (info.data.count / 2) - 1)
        let range1 = randomRegion(length: length, info: info)
        let range2 = randomRegion(range1.upperBound, length: length, info: info)
        
        var src = range1.lowerBound
        
        let tintColor = Color(color: UIColor.neonColors.random!)
        
        for dest in range2.lowerBound ..< range2.upperBound {
            var color = info.data[src]
            if tint {
                color.tint(tintColor)
            }
            info.data[dest] = color
            src += 1
        }
    }
    
    private func applyPlaceImage(_ info: ContextInfo, image img: UIImage? = ImageDownloader.sharedInstance.getRandomImage()) -> CGRect? {
       
        guard var image = img else {
            return nil
        }
        
        let divisor = CGFloat.random(within: 1.5 ... 3.0)
        
        let bounds = CGSize(width: CGFloat(info.width) / divisor, height: CGFloat(info.height) / divisor)
        image = image.resizedImageWithContentMode(.scaleAspectFit, bounds: bounds, interpolationQuality: .default)
        
        let size = image.size
        
        UIGraphicsPushContext(info.context)
        info.context.saveGState()
        info.context.translateBy(x: 0, y: CGFloat(info.height));
        info.context.scaleBy(x: 1.0, y: -1.0);
        
        func genPoint() -> CGPoint {
            return CGPoint(x: Int.random(within: 0...(info.width - Int(size.width))), y: Int.random(within: 0...(info.height - Int(size.height))))
        }
        
        var origin = genPoint()
        
        var tries = 0
        
        while info.consumedRects.map({ $0.contains(CGPoint(x: origin.x + (size.width / 2), y: origin.y + (size.height / 2))) }).reduce(false, { $0 || $1 }) {
            if tries > 25 {
                break
            }
            origin = genPoint()
            tries += 1
        }
        
        let rect = CGRect(origin: origin, size: size)
        
        image.draw(at: origin)
        
        info.context.restoreGState();
        UIGraphicsPopContext()
        
        return rect
    }
    
    private func applyFaceMash(_ info: ContextInfo) -> CGRect? {
        
        let options = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: info.coreImageContext, options: options)
        let ciImage = CIImage(cgImage: info.original)
        
        guard let features = detector?.features(in: ciImage).flatMap({ $0 as? CIFaceFeature }), let feature = features.shuffled().first else {
            return nil
        }
        
        let pi2 = CGFloat.pi / 2
        let trans = CGAffineTransform(rotationAngle: CGFloat.random(within: -pi2...pi2))
        let cropped = ciImage.cropping(to: feature.bounds).applying(trans)
        
        guard let facePart = info.coreImageContext.createCGImage(cropped, from: cropped.extent) else {
            return nil
        }
        
        let ui = UIImage(cgImage: facePart)
        
        return applyPlaceImage(info, image: ui)
    }
    
    private func applyStarField(_ info: ContextInfo) {
        
        let gen = YUCIStarfieldGenerator()
        
        let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: info.width, height: info.height))
        gen.inputExtent = CIVector(cgRect: bounds)
        
        let darken = CIFilter(name: "CIColorMatrix")
        
        darken?.setDefaults()
        darken?.setValue(gen.outputImage, forKey: kCIInputImageKey)
        darken?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0.25), forKey: "inputAVector")
        
        guard var output = darken?.outputImage, let currentState = info.context.makeImage() else {
            return
        }
        
        let currentCIImage = CIImage(cgImage: currentState)
        
        output = CIFilter(name: "CIScreenBlendMode", withInputParameters: [kCIInputImageKey: output, kCIInputBackgroundImageKey: currentCIImage])?.outputImage ?? output
        
        let cgOutput = info.coreImageContext.createCGImage(output, from: output.extent)
        info.context.draw(cgOutput!, in: bounds)
    }
    
    fileprivate func apply(_ context: CGContext, original: CGImage, coreImageContext: CIContext, consumedRects: [CGRect]) -> CGRect? {
        
        let w = context.width
        let h = context.height
        let bpr = context.bytesPerRow
        let d = context.data
        let p = context.bitsPerPixel / 8
        let cpr = (bpr / p)
        
        let colorCount = cpr * h
        
        guard let startingAddress = d?.bindMemory(to: Color.self, capacity: colorCount) else {
            return nil
        }
        
        let info = ContextInfo(
            original: original,
            context: context,
            coreImageContext: coreImageContext,
            width: w,
            height: h,
            bytesPerRow: bpr,
            data: UnsafeMutableBufferPointer<Color>(start: startingAddress, count: colorCount),
            colorsPerRow: cpr,
            consumedRects: consumedRects
        )
        
        var rect: CGRect?
        
        switch self {
        case .sprinkle:
            applySprinkle(info)
        case .copy:
            applyCopy(info)
        case .copyTint:
            applyCopy(info, tint: true)
        case .placeImage:
            rect = applyPlaceImage(info)
        case .faceMash:
            rect = applyFaceMash(info)
        case .starfield:
            applyStarField(info)
        }
        
        return rect
        
    }
    
}

final class ImageProcessor {
    
    private let context: CGContext
    private let originalImage: CGImage!
    private let coreImageContext = CIContext()
    private var consumedRects: [CGRect] = []
    
    convenience init(image: UIImage) {
        self.init(image: image.cgImage)
    }
    
    init(image: CGImage!) {
        
        originalImage = image
        
        let ctx = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: image.bytesPerRow,
            space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: image.bitmapInfo.rawValue
        )
        
        guard ctx != nil else {
            fatalError("ya done goofed")
        }
        
        let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        
        ctx?.draw(image, in: rect)
        
        context = ctx!
        
    }
    
    func apply(_ effect: Effect) {
        if let rect = effect.apply(context, original: originalImage, coreImageContext: coreImageContext, consumedRects: consumedRects) {
            consumedRects.append(rect)
        }
    }
    
    var outputImage: UIImage? {
        guard let image = context.makeImage() else {
            return UIImage()
        }
        return UIImage(cgImage: image)
    }
    
}
