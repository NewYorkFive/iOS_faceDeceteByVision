//
//  FaceDetector.h
//  faceVisionOC
//
//  Created by DoubleL on 2019/3/20.
//  Copyright © 2019 DoubleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FaceDetector : NSObject
- (void)highlightFaces:(UIImage *)sourceImage resultBlock:(void(^)(UIImage *resultImage))block;
@end

NS_ASSUME_NONNULL_END
