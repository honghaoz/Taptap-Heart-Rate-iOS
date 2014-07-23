//
//  TTHRMainScrollView.m
//  Taptap Heart Rate
//
//  Created by Zhang Honghao on 6/15/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "TTHRMainScrollView.h"

@implementation TTHRMainScrollView {
    CGPoint touchBeginPoint;
    BOOL isMoved;
    BOOL isMoving;
    BOOL lastMoveEnd;
    NSArray *contentOffsets;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isMoved = NO;
        isMoving = NO;
        lastMoveEnd = NO;
    }
    return self;
}

- (void)setScreenContentOffsets:(NSArray *)offsets {
    contentOffsets = offsets;
}

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    LogMethod;
    isMoved = NO;
    lastMoveEnd = YES;
    [super touchesBegan:touches withEvent:event];
    for (UITouch *touch in touches) {
        touchBeginPoint = [touch locationInView:self];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissKeyboard" object:self userInfo:@{@"TouchedScreen": [NSNumber numberWithInteger:[self getScreenFromTouchPoint:[touch locationInView:self]]]}];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    LogMethod;
    for (UITouch *touch in touches) {
        CGPoint currentPoint = [touch locationInView:self];
        if (touchBeginPoint.x - currentPoint.x > 70) {
            isMoved = YES;
            if (!isMoving && lastMoveEnd) {
                lastMoveEnd = NO;
                [self moveToScreen:Screen1];
            }
        }
        if (currentPoint.x - touchBeginPoint.x > 70) {
            isMoved = YES;
            if (!isMoving && lastMoveEnd) {
                lastMoveEnd = NO;
                [self moveToScreen:Screen0];
            }
        }
    }
//    if (!isMoved) {
        [super touchesMoved:touches withEvent:event];
//    }
    //    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    LogMethod;
    if (!isMoved) {
        for (UITouch *touch in touches) {
            CGPoint currentPoint = [touch locationInView:self];
            Screen touchedScreen = [self getScreenFromTouchPoint:currentPoint];
            if (touchedScreen == Screen0) {
                [self moveToScreen:Screen0];
            } else if (touchedScreen == Screen1) {
                [self moveToScreen:Screen1];
            }
        }
    }
    lastMoveEnd = YES;
//    if (isMoved == NO) {
        [super touchesEnded:touches withEvent:event];
//    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    LogMethod;
    [super touchesCancelled:touches withEvent:event];
}


#pragma mark - Helper methods

/**
 *  Get which screen is the point located
 *
 *  @param point point in the view
 *
 *  @return Screen number
 */
- (Screen)getScreenFromTouchPoint:(CGPoint)point {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (0 <= point.x && point.x < screenWidth) {
        return Screen0;
    } else if (point.x < screenWidth * 2) {
        return Screen1;
    } else {
        return Screen2;
    }
//
//    int touchIndex = -1;
//    int offsetsCount = [contentOffsets count];
//    for (int i = 0; i < offsetsCount - 1; i++) {
//        CGFloat priorStartPoint = [contentOffsets[i] floatValue];
//        CGFloat posteriorStartPoint = [contentOffsets[i + 1] floatValue];
//        CGFloat touchPoint = point.x;
//        if (priorStartPoint <= touchPoint && touchPoint < posteriorStartPoint) {
//            touchIndex = i;
//            break;
//        }
//    }
//    if (touchIndex == 0) {
//        return Screen1_;
//    } else if (touchIndex == 1) {
//        return Screen0;
//    } else {
//        return Screen1;
//    }
}

- (void)moveToScreen:(Screen)sc
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (isMoving == NO) {
        if ([self.screenDelegate scrollView:self shouldMoveToScreen:sc]) {
            isMoving = YES;
            if ([self.screenDelegate respondsToSelector:@selector(scrollView:willMoveToScreen:)]) {
                [self.screenDelegate scrollView:self willMoveToScreen:sc];
            }
            [UIView animateWithDuration:0.3
                animations:^{
                                 switch (sc) {
                                     case Screen0:{
                                         [self setContentOffset:CGPointMake(0, 0) animated:NO];
                                         break;
                                     }
                                     case Screen1:{
                                         [self setContentOffset:CGPointMake(self.contentSize.width - screenWidth, 0) animated:NO];
                                         break;
                                     }
                                     default:
                                         assert(NO);
                                         break;
                                 }
                }
                completion:^(BOOL finished) {
                                 isMoving = NO;
                                 if ([self.screenDelegate respondsToSelector:@selector(scrollView:didMoveToScreen:)]) {
                                     [self.screenDelegate scrollView:self didMoveToScreen:sc];
                                 }
                }];
        }
    }
}

@end
