#import "ExceptionCatcher.h"

@implementation ExceptionCatcher

+ (BOOL)tryBlock:(void (NS_NOESCAPE ^)(void))block
           error:(NSError *_Nullable __autoreleasing *_Nullable)error {
  @try {
    block();
    return YES;
  } @catch (NSException *exception) {
    if (error) {
      NSString *reason = exception.reason ?: exception.name;
      *error = [NSError errorWithDomain:@"com.joyphysics.audio"
                                   code:1
                               userInfo:@{NSLocalizedDescriptionKey : reason}];
    }
    return NO;
  }
}

@end
