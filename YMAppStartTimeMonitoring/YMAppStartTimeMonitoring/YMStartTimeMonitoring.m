//
//  YMStartTimeMonitoring.m
//  YMAppStartTimeMonitoring
//
//  Created by yuanwei on 2018/9/6.
//  Copyright © 2018年 ym. All rights reserved.
//

#import "YMStartTimeMonitoring.h"
#import "pthread.h"

typedef NS_ENUM(NSInteger, YMStartTimeMonitoringState) {
    YMStartTimeMonitoringStateInitial = 0,
    YMStartTimeMonitoringStateRuning = 1,
    YMStartTimeMonitoringStateStop = 2,
};

@interface YMStartTimeMonitoring (){
    pthread_mutex_t _mutex;
}

@property (nonatomic,assign) CFTimeInterval beginTimeInterval;
@property (nonatomic,assign) CFTimeInterval temporaryTimeInterval;
@property (nonatomic,assign) CFTimeInterval endTimeInterval;
@property (nonatomic,assign) YMStartTimeMonitoringState state;
@property (nonatomic,strong) NSMutableArray *describes;
@property (nonatomic,copy)   NSString *showInfo;

@end

@implementation YMStartTimeMonitoring

+ (instancetype)sharedMonitoring {
    static YMStartTimeMonitoring* startTimeMonitoring;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        startTimeMonitoring = [[YMStartTimeMonitoring alloc] init];
    });
    
    return startTimeMonitoring;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _describes = [NSMutableArray array];
        pthread_mutex_init(&_mutex, NULL);
    }
    
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutex);
}

- (void)start {
    self.state = YMStartTimeMonitoringStateRuning;
    self.beginTimeInterval = CACurrentMediaTime();
    self.temporaryTimeInterval = self.beginTimeInterval;
}

- (void)showInfoWithDescribe:(NSString *)describe {
    if (self.state != YMStartTimeMonitoringStateRuning) {
        return;
    }
    
    NSTimeInterval temporaryTimeInterval = CACurrentMediaTime();
    CFTimeInterval timeInterval = temporaryTimeInterval - self.temporaryTimeInterval;
    
    NSMutableString *info = [NSMutableString stringWithFormat:@"*%@", @(self.describes.count + 1)];
    if (describe) {
        [info appendFormat:@"%@", describe];
    }
    
    pthread_mutex_lock(&_mutex);
    [self.describes addObject:@{info : @(timeInterval)}];
    pthread_mutex_unlock(&_mutex);
    self.temporaryTimeInterval = temporaryTimeInterval;
}

- (void)stop{
    [[[UIAlertView alloc] initWithTitle:@"启动时间监测结果"
                                message:[[YMStartTimeMonitoring sharedMonitoring] showInfo]
                               delegate:nil
                      cancelButtonTitle:@"确定"
                      otherButtonTitles:nil] show];
    
    self.state = YMStartTimeMonitoringStateInitial;
    pthread_mutex_lock(&_mutex);
    [self.describes removeAllObjects];
    pthread_mutex_unlock(&_mutex);
    self.beginTimeInterval = 0;
    self.temporaryTimeInterval = 0;
    self.endTimeInterval = 0;
}

- (NSString *)showInfo {
    NSMutableString *str = [[NSMutableString alloc] init];
    pthread_mutex_lock(&_mutex);
    [self.describes enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *info = obj.allKeys.firstObject;
        NSNumber *time = obj.allValues.firstObject;
        [str appendFormat:@"%@: %.6f\n", info, time.doubleValue];
    }];
    pthread_mutex_unlock(&_mutex);
    
    return [str copy];
}

@end

