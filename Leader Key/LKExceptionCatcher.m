#import "LKExceptionCatcher.h"

@implementation LKExceptionCatcher

+ (BOOL)tryBlock:(void (^)(void))block error:(NSError * _Nullable * _Nullable)error {
  @try {
    block();
    return YES;
  } @catch (NSException *exception) {
    if (error) {
      NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
      if (exception.reason) {
        userInfo[NSLocalizedDescriptionKey] = exception.reason;
      }
      if (exception.name) {
        userInfo[@"NSExceptionName"] = exception.name;
      }
      if (exception.userInfo) {
        userInfo[@"NSExceptionUserInfo"] = exception.userInfo;
      }
      *error = [NSError errorWithDomain:@"LKExceptionCatcher" code:1 userInfo:userInfo];
    }
    return NO;
  }
}

@end
