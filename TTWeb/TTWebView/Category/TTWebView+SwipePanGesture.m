//
//  TTWebView+SwipePanGesture.m
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/26.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTWebView+SwipePanGesture.h"

@implementation TTWebView (SwipePanGesture)

#pragma mark - logic of push and pop snap shot views
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    //    NSLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        NSLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    if (!request.URL.scheme) {
        return;
    }
    if (!request.URL.host) {
        return;
    }
    UIView* currentSnapShotView = [self snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{
       @"request":request,
       @"snapShotView":currentSnapShotView
       }
     ];
}


-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (!self.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    self.currentSnapShotView = [self snapshotViewAfterScreenUpdates:YES];
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    
    [self addSubview:self.prevSnapShotView];
    [self addSubview:self.swipingBackgoundView];
    [self addSubview:self.currentSnapShotView];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    prevSnapshotViewCenter.x -= (self.frame.size.width - distance)*60/self.frame.size.width;
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (self.frame.size.width - distance)/self.frame.size.width;
}

-(void)endPopSnapShotView{
    if (!self.isSwipingBack) {
        return;
    }
    //prevent the user touch for now
    self.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= self.frame.size.width) {
        // pop success
        [self goBack];
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(self.frame.size.width*3/2, self.frame.size.height/2);
            self.prevSnapShotView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            [self.snapShotsArray removeLastObject];
            self.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            self.prevSnapShotView.center = CGPointMake(self.frame.size.width/2-60, self.frame.size.height/2);
            self.prevSnapShotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            self.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

@end
