#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKExceptionCatcher : NSObject

+ (BOOL)tryBlock:(void (^)(void))block error:(NSError * _Nullable * _Nullable)error
  NS_SWIFT_NAME(perform(_:));

@end

NS_ASSUME_NONNULL_END
