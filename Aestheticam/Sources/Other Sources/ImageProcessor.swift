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
        let mult: CGFloat -> UInt8 = { UInt8(CGFloat($0) * 255.0) }
        self.init(r: mult(rF), g: mult(gF), b: mult(bF), a: mult(aF))
    }
    
    mutating func tint(color: Color) {
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
    
    case Sprinkle
    case Copy
    case CopyTint
    case PlaceImage
    case FaceMash
    case Starfield
    
    private func randomRegion(start: Int? = nil, length: Int? = nil, info: ContextInfo) -> Range<UnsafeMutableBufferPointer<Color>.Index> {
        let len = length ?? (Int.random() % (info.data.count / 2))
        let y = Int.random() % (info.height / 2)
        let x = Int.random() % (info.width / 2)
        let s = start ?? (y * info.colorsPerRow) + x
        let end = min(s + len, info.data.count)
        return s..<end
    }
    
    private func sprinkle(info: ContextInfo) {
        let i = Int.random(0...(info.data.count - 1))
        var c = info.data[i]
        c.r = Bool.random() ? UInt8(Int.random(0...255)) : c.r
        c.g = Bool.random() ? UInt8(Int.random(0...255)) : c.g
        c.b = Bool.random() ? UInt8(Int.random(0...255)) : c.b
        info.data[i] = c
    }
    
    private func copy(info: ContextInfo, tint: Bool = false) {
        
        let minHeight = 5 * info.colorsPerRow
        let length = Int.random(minHeight ... (info.data.count / 2) - 1)
        let range1 = randomRegion(length: length, info: info)
        let range2 = randomRegion(range1.endIndex, length: length, info: info)
        
        var src = range1.startIndex
        
        let tintColor = Color(color: UIColor.neonColors.random!)
        
        for dest in range2 {
            var color = info.data[src]
            if tint {
                color.tint(tintColor)
            }
            info.data[dest] = color
            src += 1
        }
    }
    
    private func placeImage(info: ContextInfo, image img: UIImage? = ImageDownloader.sharedInstance.getRandomImage()) -> CGRect? {
       
        guard var image = img else {
            return nil
        }
        
        let divisor = CGFloat.random(1.5 ... 3.0)
        
        let bounds = CGSize(width: CGFloat(info.width) / divisor, height: CGFloat(info.height) / divisor)
        image = image.resizedImageWithContentMode(.ScaleAspectFit, bounds: bounds, interpolationQuality: .Default)
        
        let size = image.size
        
        UIGraphicsPushContext(info.context)
        CGContextSaveGState(info.context)
        CGContextTranslateCTM(info.context, 0, CGFloat(info.height));
        CGContextScaleCTM(info.context, 1.0, -1.0);
        
        func genPoint() -> CGPoint {
            return CGPoint(x: Int.random(0...(info.width - Int(size.width))), y: Int.random(0...(info.height - Int(size.height))))
        }
        
        var origin = genPoint()
        
        var tries = 0
        
        while info.consumedRects.map({ CGRectContainsPoint($0, CGPoint(x: origin.x + (size.width / 2), y: origin.y + (size.height / 2))) }).reduce(false, combine: { $0 || $1 }) {
            if tries > 25 {
                break
            }
            origin = genPoint()
            tries += 1
        }
        
        let rect = CGRect(origin: origin, size: size)
        
        image.drawAtPoint(origin)
        
        CGContextRestoreGState(info.context);
        UIGraphicsPopContext()
        
        return rect
    }
    
    private func faceMash(info: ContextInfo) -> CGRect? {
        let options = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: info.coreImageContext, options: options)
        let ciImage = CIImage(CGImage: info.original)
        let features = detector.featuresInImage(ciImage).flatMap { $0 as? CIFaceFeature }
        
        guard let feature = features.shuffle().first else {
            return nil
        }
        
        let pi2 = CGFloat.NativeType(M_PI_2)
        
        let trans = CGAffineTransformMakeRotation(CGFloat.random(-pi2...pi2))
        let cropped = ciImage.imageByCroppingToRect(feature.bounds).imageByApplyingTransform(trans)
        let facePart = info.coreImageContext.createCGImage(cropped, fromRect: cropped.extent)
        let ui = UIImage(CGImage: facePart)
        
        return placeImage(info, image: ui)
    }
    
    private func starField(info: ContextInfo) {
        
        let gen = YUCIStarfieldGenerator()
        
        let bounds = CGRect(origin: CGPointZero, size: CGSize(width: info.width, height: info.height))
        gen.inputExtent = CIVector(CGRect: bounds)
        
        let darken = CIFilter(name: "CIColorMatrix")
        
        darken?.setDefaults()
        darken?.setValue(gen.outputImage, forKey: kCIInputImageKey)
        darken?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0.25), forKey: "inputAVector")
        
        guard var output = darken?.outputImage, let currentState = CGBitmapContextCreateImage(info.context) else {
            return
        }
        
        let currentCIImage = CIImage(CGImage: currentState)
        
        output = CIFilter(name: "CIScreenBlendMode", withInputParameters: [kCIInputImageKey: output, kCIInputBackgroundImageKey: currentCIImage])?.outputImage ?? output
        
        let cgOutput = info.coreImageContext.createCGImage(output, fromRect: output.extent)
        CGContextDrawImage(info.context, bounds, cgOutput)
    }
    
    private func apply(context: CGContext, original: CGImage, coreImageContext: CIContext, consumedRects: [CGRect]) -> CGRect? {
        
        let w = CGBitmapContextGetWidth(context)
        let h = CGBitmapContextGetHeight(context)
        let bpr = CGBitmapContextGetBytesPerRow(context)
        let d = CGBitmapContextGetData(context)
        let p = CGBitmapContextGetBitsPerPixel(context) / 8
        let cpr = (bpr / p)
        
        let info = ContextInfo(
            original: original,
            context: context,
            coreImageContext: coreImageContext,
            width: w,
            height: h,
            bytesPerRow: bpr,
            data: UnsafeMutableBufferPointer<Color>(start: UnsafeMutablePointer<Color>(d), count: cpr * h),
            colorsPerRow: cpr,
            consumedRects: consumedRects
        )
        
        var rect: CGRect?
        
        switch self {
        case .Sprinkle:
            sprinkle(info)
        case .Copy:
            copy(info)
        case .CopyTint:
            copy(info, tint: true)
        case .PlaceImage:
            rect = placeImage(info)
        case .FaceMash:
            rect = faceMash(info)
        case .Starfield:
            starField(info)
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
        self.init(image: image.CGImage)
    }
    
    init(image: CGImage!) {
        
        originalImage = image
        
        let ctx = CGBitmapContextCreate(
            nil,
            CGImageGetWidth(image),
            CGImageGetHeight(image),
            CGImageGetBitsPerComponent(image),
            CGImageGetBytesPerRow(image),
            CGImageGetColorSpace(image) ?? CGColorSpaceCreateDeviceRGB(),
            CGImageGetBitmapInfo(image).rawValue
        )
        
        guard ctx != nil else {
            fatalError("ya done goofed")
        }
        
        let rect = CGRect(x: 0, y: 0, width: CGImageGetWidth(image), height: CGImageGetHeight(image))
        
        CGContextDrawImage(ctx, rect, image)
        
        context = ctx!
        
    }
    
    func apply(effect: Effect) {
        if let rect = effect.apply(context, original: originalImage, coreImageContext: coreImageContext, consumedRects: consumedRects) {
            consumedRects.append(rect)
        }
    }
    
    var outputImage: UIImage? {
        guard let image = CGBitmapContextCreateImage(context) else {
            return UIImage()
        }
        return UIImage(CGImage: image)
    }
    
}