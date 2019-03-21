//
//  FaceDetector.m
//  faceVisionOC
//
//  Created by DoubleL on 2019/3/20.
//  Copyright © 2019 DoubleL. All rights reserved.
//

#import "FaceDetector.h"
#import <Vision/Vision.h>
@implementation FaceDetector

- (void)highlightFaces:(UIImage *)sourceImage resultBlock:(void (^)(UIImage * _Nonnull))resultBlock{
    __block UIImage *resultImage = sourceImage;
    VNDetectFaceLandmarksRequest *dectFaceRequest = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        if (error) {
            NSLog(@"dectFaceRequest error");
        }else{
            NSArray<VNFaceObservation *>* requestResult = request.results;
            if (requestResult.count >= 0) {
                for (VNFaceObservation *faceObservation in requestResult) {
                    VNFaceLandmarks2D *landmarks = faceObservation.landmarks;
                    if (landmarks) {
                        CGRect boundingRect = faceObservation.boundingBox;
                        NSMutableArray<VNFaceLandmarkRegion2D *> *landmarkRegions = [NSMutableArray array];
                        if (landmarks.faceContour) {
                            [landmarkRegions addObject:landmarks.faceContour];
                        }
                        if (landmarks.leftEye) {
                            [landmarkRegions addObject:landmarks.leftEye];
                        }
                        if (landmarks.rightEye) {
                            [landmarkRegions addObject:landmarks.rightEye];
                        }
                        if (landmarks.nose) {
                            [landmarkRegions addObject:landmarks.nose];
                        }
                        if (landmarks.noseCrest) {
                            [landmarkRegions addObject:landmarks.noseCrest];
                        }
                        if (landmarks.medianLine) {
                            [landmarkRegions addObject:landmarks.medianLine];
                        }
                        if (landmarks.outerLips) {
                            [landmarkRegions addObject:landmarks.outerLips];
                        }
                        if (landmarks.innerLips) {
                            [landmarkRegions addObject:landmarks.innerLips];
                        }
                        resultImage = [self drawImage:resultImage boundingRect:boundingRect faceLandMarkRegions:landmarkRegions];
                    }else{
                        continue;
                    }
                }
            }
        }
        resultBlock(resultImage);
    }];
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:sourceImage.CGImage options:@{}];
    [handler performRequests: [NSArray arrayWithObjects:dectFaceRequest, nil] error:nil];
}

- (UIImage *)drawImage:(UIImage *)source boundingRect:(CGRect)boundingRect faceLandMarkRegions:(NSMutableArray<VNFaceLandmarkRegion2D *> *)faceLandMarkRegions{
    UIGraphicsBeginImageContextWithOptions(source.size, false, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    
    CGFloat rectWidth = source.size.width * boundingRect.size.width;
    CGFloat rectHeight = source.size.height * boundingRect.size.height;
    
    //draw image
    CGContextDrawImage(context, CGRectMake(0, 0, source.size.width, source.size.height), source.CGImage);
    
    //draw bound rect
    UIColor *fillColor = [UIColor greenColor];
    [fillColor setFill];
    CGContextAddRect(context, CGRectMake(boundingRect.origin.x * source.size.width, boundingRect.origin.y * source.size.height, rectWidth, rectHeight));
    CGContextDrawPath(context, kCGPathStroke);
    
    //draw overlay
    fillColor = [UIColor redColor];
    [fillColor setStroke];
    CGContextSetLineWidth(context, 2.0);
    for (VNFaceLandmarkRegion2D *faceLandMarkRegion in faceLandMarkRegions) {
#define kEnoughSize 1000
        CGPoint points[kEnoughSize];
        int count = 0;
        for (int i = 0; i < faceLandMarkRegion.pointCount; i++) {
            CGPoint point = faceLandMarkRegion.normalizedPoints[i];
            point = CGPointMake(boundingRect.origin.x * source.size.width + point.x * rectWidth, boundingRect.origin.y * source.size.height + point.y * rectHeight);
            points[count++] = point;
        }
        CGContextAddLines(context, points, count);
        printf("count is %d\n",count);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
