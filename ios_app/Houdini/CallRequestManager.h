
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CallMonitor.h"

@interface CallRequestInstance : NSObject<UIAlertViewDelegate, CallMonitorDelegate>
-(id)initWithSessionID:(NSString*)sessionId;
-(void)ask;
-(void)acceptWithUsername:(NSString*)username;
-(void)check;
-(void)finish;
@property (nonatomic, readonly) NSString* sessionId;
@property (nonatomic, readonly) NSString* phoneNumber;
@property (nonatomic, readonly) BOOL asked;
@end

@interface CallRequestManager : NSObject
+(void)handleCallRequest:(NSString*)sessionId;
+(void)checkForRequests;
+(void)removeCallRequest:(NSString*)sessionId;
@end
