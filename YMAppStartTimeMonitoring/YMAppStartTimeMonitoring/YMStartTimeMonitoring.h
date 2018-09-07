//
//  YMStartTimeMonitoring.h
//  YMAppStartTimeMonitoring
//
//  Created by yuanwei on 2018/9/6.
//  Copyright © 2018年 ym. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMStartTimeMonitoring : NSObject

+ (instancetype)sharedMonitoring;

- (void)start;

- (void)showInfoWithDescribe:(NSString *)describe;

- (void)stop;

@end

