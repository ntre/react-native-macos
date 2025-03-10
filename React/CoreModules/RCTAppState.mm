/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTAppState.h"

#import <React/RCTUIKit.h> // TODO(macOS GH#774)
#import <FBReactNativeSpec/FBReactNativeSpec.h>
#import <React/RCTAssert.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcherProtocol.h>
#import <React/RCTUtils.h>

#import "CoreModulesPlugins.h"

static NSString *RCTCurrentAppState()
{
#if !TARGET_OS_OSX // TODO(macOS GH#774)
  static NSDictionary *states;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    states = @{@(UIApplicationStateActive) : @"active", @(UIApplicationStateBackground) : @"background"};
  });
  if (RCTRunningInAppExtension()) {
    return @"extension";
  }
  return states[@(RCTSharedApplication().applicationState)] ?: @"unknown";
#else // [TODO(macOS GH#774)
  
  if (RCTSharedApplication().isActive) {
    return @"active";
  } else if (RCTSharedApplication().isHidden) {
    return @"background";
  }
  return @"unknown";
  
#endif // ]TODO(macOS GH#774)
  
}

@interface RCTAppState () <NativeAppStateSpec>
@end

@implementation RCTAppState {
  NSString *_lastKnownState;
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (facebook::react::ModuleConstants<JS::NativeAppState::Constants>)constantsToExport
{
  return (facebook::react::ModuleConstants<JS::NativeAppState::Constants>)[self getConstants];
}

- (facebook::react::ModuleConstants<JS::NativeAppState::Constants>)getConstants
{
  __block facebook::react::ModuleConstants<JS::NativeAppState::Constants> constants;
  RCTUnsafeExecuteOnMainQueueSync(^{
    constants = facebook::react::typedConstants<JS::NativeAppState::Constants>({
        .initialAppState = RCTCurrentAppState(),
    });
  });

  return constants;
}

#pragma mark - Lifecycle

- (NSArray<NSString *> *)supportedEvents
{
  return @[ @"appStateDidChange", @"memoryWarning" ];
}

- (void)startObserving
{
  for (NSString *name in @[
         UIApplicationDidBecomeActiveNotification,
         UIApplicationDidEnterBackgroundNotification,
         UIApplicationDidFinishLaunchingNotification,
         UIApplicationWillResignActiveNotification,
         UIApplicationWillEnterForegroundNotification
       ]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppStateDidChange:)
                                                 name:name
                                               object:nil];
  }

#if !TARGET_OS_OSX // TODO(macOS GH#774)
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleMemoryWarning)
                                               name:UIApplicationDidReceiveMemoryWarningNotification
                                             object:nil];
#endif // TODO(macOS GH#774)
}

- (void)stopObserving
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - App Notification Methods

- (void)handleMemoryWarning
{
  if (self.bridge) {
    [self sendEventWithName:@"memoryWarning" body:nil];
  }
}

- (void)handleAppStateDidChange:(NSNotification *)notification
{
  NSString *newState;

  if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
    newState = @"inactive";
  } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
    newState = @"background";
  } else {
    newState = RCTCurrentAppState();
  }

  if (![newState isEqualToString:_lastKnownState]) {
    _lastKnownState = newState;
    if (self.bridge) {
      [self sendEventWithName:@"appStateDidChange" body:@{@"app_state" : _lastKnownState}];
    }
  }
}

#pragma mark - Public API

/**
 * Get the current background/foreground state of the app
 */
RCT_EXPORT_METHOD(getCurrentAppState : (RCTResponseSenderBlock)callback error : (__unused RCTResponseSenderBlock)error)
{
  callback(@[ @{@"app_state" : RCTCurrentAppState()} ]);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeAppStateSpecJSI>(params);
}

@end

Class RCTAppStateCls(void)
{
  return RCTAppState.class;
}
