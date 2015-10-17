
#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCall.h>

@class CallMonitor;

@protocol CallMonitorDelegate <NSObject>
@optional
-(void)callMonitor:(CallMonitor*)callMonitor didBeginDialingCall:(CTCall*)call;
-(void)callMonitor:(CallMonitor*)callMonitor didConnectCall:(CTCall*)call;
-(void)callMonitor:(CallMonitor*)callMonitor didDisconnectCall:(CTCall *)call withTotalCallTime:(double)seconds;
@end

@interface CallMonitor : NSObject

-(BOOL)call:(NSString*)phoneNumber;

@property (nonatomic, weak) id<CallMonitorDelegate> delegate;

@end
