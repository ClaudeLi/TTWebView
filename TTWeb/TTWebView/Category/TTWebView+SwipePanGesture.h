//
//  TTWebView+SwipePanGesture.h
//  Tiaooo
//
//  Created by ClaudeLi on 2017/5/26.
//  Copyright © 2017年 ClaudeLi. All rights reserved.
//

#import "TTWebView.h"

@interface TTWebView (SwipePanGesture)

-(void)startPopSnapshotView;

-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request;

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance;

-(void)endPopSnapShotView;

@end
