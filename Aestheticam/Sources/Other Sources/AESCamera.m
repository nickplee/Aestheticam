//
//  AESCamera.m
//  Aestheticam
//
//  Created by Nick Lee on 5/25/18.
//  Copyright © 2018 Nicholas Lee Designs, LLC. All rights reserved.
//

#import "AESCamera.h"
@import AVFoundation;

@interface AESCamera ()

@end

@implementation AESCamera

- (AVCaptureVideoOrientation)orientationForConnection
{
    return AVCaptureVideoOrientationPortrait;
}

@end
