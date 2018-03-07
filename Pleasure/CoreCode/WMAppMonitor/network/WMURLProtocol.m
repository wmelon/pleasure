//
//  WMURLProtocol.m
//  Pleasure
//
//  Created by Sper on 2018/2/6.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMURLProtocol.h"
/// 设置标志防止循环请求
static NSString * const hasInitKey = @"WMMarkerProtocolKey";

@interface WMURLProtocol()<NSURLSessionDelegate,NSURLSessionDataDelegate>

///< The thread on which we should call the client.
@property (atomic, strong, readwrite) NSThread *  clientThread;

///< The NSURLSession task for that request; client thread only.
@property (atomic, strong, readwrite) NSURLSessionDataTask *  task;

///< The start time of the request; written by client thread only; read by any thread.
@property (atomic, assign, readwrite) NSTimeInterval  startTime;

///*! The run loop modes in which to call the client.
// *  \details The concurrency control here is complex.  It's set up on the client
// *  thread in -startLoading and then never modified.  It is, however, read by code
// *  running on other threads (specifically the main thread), so we deallocate it in
// *  -dealloc rather than in -stopLoading.  We can be sure that it's not read before
// *  it's set up because the main thread code that reads it can only be called after
// *  -startLoading has started the connection running.
// */
//
//@property (atomic, copy,   readwrite) NSArray *                         modes;
@end

@implementation WMURLProtocol

// 定义拦截请求的URL规则
+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    NSAssert(request, @"请求对象不能为空");
    if ([NSURLProtocol propertyForKey:hasInitKey inRequest:request]) {
        return NO;
    }
    return YES;
}
// 自定义网络请求 .对于需要修改请求头的请求在该方法中修改
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSAssert(request, @"请求对象不能为空");
    return request;
}
- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client{
    NSAssert(request, @"请求不能为空");
    NSAssert(client, @"请求客户端不能为空");
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}
// 对于拦截的请求，系统创建一个NSURLProtocol对象执行startLoading方法开始加载请求
- (void)startLoading{
    // you can't call -startLoading twice
    assert(self.clientThread == nil);
    assert(self.task == nil);
    
    NSMutableURLRequest *   recursiveRequest;
//    NSMutableArray *        calculatedModes;
//    NSString *              currentMode;
    
    recursiveRequest = [[self request] mutableCopy];
    assert(recursiveRequest != nil);
    
    //做下标记，防止递归调用
    [[self class] setProperty:@YES forKey:hasInitKey inRequest:recursiveRequest];
    
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.clientThread = [NSThread currentThread];
    
//    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
//    assert(self.task != nil);
//    [self.task resume];
    
#pragma warning -- 模拟请求  ，  这个地方有问题需要优化。。。。。。。。。
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:recursiveRequest];
    self.task = task;
    [task resume];
}
// 对于拦截的请求，NSURLProtocol对象在停止加载时调用该方法
- (void)stopLoading{
    NSLog(@"stopLoading    %@" , self.request);
//    assert(self.clientThread != nil);           // someone must have called -startLoading
    
    // Check that we're being stopped on the same thread that we were started
    // on.  Without this invariant things are going to go badly (for example,
    // run loop sources that got attached during -startLoading may not get
    // detached here).
    //
    // I originally had code here to bounce over to the client thread but that
    // actually gets complex when you consider run loop modes, so I've nixed it.
    // Rather, I rely on our client calling us on the right thread, which is what
    // the following assert is about.
    
//    assert([NSThread currentThread] == self.clientThread);
    
//    [self cancelPendingChallenge];
//    if (self.task != nil) {
//        [self.task cancel];
//        self.task = nil;
//        // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
//        // which specificallys traps and ignores the error.
//    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
}
#pragma mark -- NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest *    redirectRequest;
    
#pragma unused(session)
#pragma unused(task)
    assert(task == self.task);
    assert(response != nil);
    assert(newRequest != nil);
#pragma unused(completionHandler)
    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // The new request was copied from our old request, so it has our magic property.  We actually
    // have to remove that so that, when the client starts the new request, we see it.  If we
    // don't do this then we never see the new request and thus don't get a chance to change
    // its caching behaviour.
    //
    // We also cancel our current connection because the client is going to start a new request for
    // us anyway.
    
    assert([[self class] propertyForKey:hasInitKey inRequest:newRequest] != nil);
    
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:hasInitKey inRequest:redirectRequest];
    
    // Tell the client about the redirect.
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    // Stop our load.  The CFNetwork infrastructure will create a new NSURLProtocol instance to run
    // the load of the redirect.
    
    // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
    // which specificallys traps and ignores the error.
    
    [self.task cancel];
    
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
//    BOOL        result;
//    id<CustomHTTPProtocolDelegate> strongeDelegate;
//
//#pragma unused(session)
//#pragma unused(task)
//    assert(task == self.task);
//    assert(challenge != nil);
//    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
//
//    // Ask our delegate whether it wants this challenge.  We do this from this thread, not the main thread,
//    // to avoid the overload of bouncing to the main thread for challenges that aren't going to be customised
//    // anyway.
//
//    strongeDelegate = [[self class] delegate];
//
//    result = NO;
//    if ([strongeDelegate respondsToSelector:@selector(customHTTPProtocol:canAuthenticateAgainstProtectionSpace:)]) {
//        result = [strongeDelegate customHTTPProtocol:self canAuthenticateAgainstProtectionSpace:[challenge protectionSpace]];
//    }
//
//    // If the client wants the challenge, kick off that process.  If not, resolve it by doing the default thing.
//
//    if (result) {
//        [[self class] customHTTPProtocol:self logWithFormat:@"can authenticate %@", [[challenge protectionSpace] authenticationMethod]];
//
//        [self didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
//    } else {
//        [[self class] customHTTPProtocol:self logWithFormat:@"cannot authenticate %@", [[challenge protectionSpace] authenticationMethod]];
//
//        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
//    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode;
    
#pragma unused(session)
#pragma unused(dataTask)
    assert(dataTask == self.task);
    assert(response != nil);
    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // Pass the call on to our client.  The only tricky thing is that we have to decide on a
    // cache storage policy, which is based on the actual request we issued, not the request
    // we were given.
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.task.originalRequest, (NSHTTPURLResponse *) response);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = [((NSHTTPURLResponse *) response) statusCode];
    } else {
        assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
#pragma unused(session)
#pragma unused(dataTask)
    assert(dataTask == self.task);
    assert(data != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // Just pass the call on to our client.
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
#pragma unused(session)
#pragma unused(dataTask)
    assert(dataTask == self.task);
    assert(proposedResponse != nil);
    assert(completionHandler != nil);
//    assert([NSThread currentThread] == self.clientThread);
    
    // We implement this delegate callback purely for the purposes of logging.
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
// An NSURLSession delegate callback.  We pass this on to the client.
{
#pragma unused(session)
#pragma unused(task)
    assert( (self.task == nil) || (task == self.task) );        // can be nil in the 'cancel from -stopLoading' case
//    assert([NSThread currentThread] == self.clientThread);
    
    // Just log and then, in most cases, pass the call on to our client.
    
    if (error == nil) {
        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        // Do nothing.  This happens in two cases:
        //
        // o during a redirect, in which case the redirect code has already told the client about
        //   the failure
        //
        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
        //   want to know about the failure
    } else {
        [[self client] URLProtocol:self didFailWithError:error];
    }
    
    // We don't need to clean up the connection here; the system will call, or has already called,
    // -stopLoading to do that.
}

- (void)dealloc{

}

@end
