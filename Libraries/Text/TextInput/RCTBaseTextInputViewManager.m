/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTBaseTextInputViewManager.h>

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTFont.h>
#import <React/RCTShadowView+Layout.h>
#import <React/RCTShadowView.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUIManagerObserverCoordinator.h>

#import <React/RCTBaseTextInputShadowView.h>
#import <React/RCTBaseTextInputView.h>
#if !TARGET_OS_OSX // TODO(macOS GH#774)
#import <React/RCTConvert+Text.h>
#endif // TODO(macOS GH#774)
#import <React/RCTUIKit.h> // TODO(macOS GH#774)

@interface RCTBaseTextInputViewManager () <RCTUIManagerObserver>

@end

@implementation RCTBaseTextInputViewManager
{
  NSHashTable<RCTBaseTextInputShadowView *> *_shadowViews;
}

RCT_EXPORT_MODULE()

#pragma mark - Unified <TextInput> properties

RCT_REMAP_NOT_OSX_VIEW_PROPERTY(autoCapitalize, backedTextInputView.autocapitalizationType, UITextAutocapitalizationType) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(autoCorrect, backedTextInputView.autocorrectionType, UITextAutocorrectionType) // TODO(macOS GH#774)
RCT_REMAP_OSX_VIEW_PROPERTY(autoCorrect, backedTextInputView.automaticTextReplacementEnabled, BOOL) // TODO(macOS GH#774)
RCT_REMAP_VIEW_PROPERTY(contextMenuHidden, backedTextInputView.contextMenuHidden, BOOL)
RCT_REMAP_VIEW_PROPERTY(editable, backedTextInputView.editable, BOOL)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(enablesReturnKeyAutomatically, backedTextInputView.enablesReturnKeyAutomatically, BOOL) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(keyboardAppearance, backedTextInputView.keyboardAppearance, UIKeyboardAppearance) // TODO(macOS GH#774)
RCT_REMAP_VIEW_PROPERTY(placeholder, backedTextInputView.placeholder, NSString)
RCT_REMAP_VIEW_PROPERTY(placeholderTextColor, backedTextInputView.placeholderColor, UIColor)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(returnKeyType, backedTextInputView.returnKeyType, UIReturnKeyType) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(selectionColor, backedTextInputView.tintColor, UIColor) // TODO(macOS GH#774)
RCT_REMAP_OSX_VIEW_PROPERTY(selectionColor, backedTextInputView.selectionColor, UIColor) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(spellCheck, backedTextInputView.spellCheckingType, UITextSpellCheckingType) // TODO(macOS GH#774)
RCT_REMAP_OSX_VIEW_PROPERTY(spellCheck, backedTextInputView.automaticSpellingCorrectionEnabled, BOOL) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(caretHidden, backedTextInputView.caretHidden, BOOL) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(clearButtonMode, backedTextInputView.clearButtonMode, UITextFieldViewMode) // TODO(macOS GH#774)
RCT_REMAP_VIEW_PROPERTY(scrollEnabled, backedTextInputView.scrollEnabled, BOOL)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(secureTextEntry, backedTextInputView.secureTextEntry, BOOL) // TODO(macOS GH#774)
RCT_EXPORT_VIEW_PROPERTY(autoFocus, BOOL)
RCT_EXPORT_VIEW_PROPERTY(blurOnSubmit, BOOL)
RCT_EXPORT_NOT_OSX_VIEW_PROPERTY(clearTextOnFocus, BOOL) // TODO(macOS GH#774)
RCT_REMAP_NOT_OSX_VIEW_PROPERTY(keyboardType, backedTextInputView.keyboardType, UIKeyboardType) // TODO(macOS GH#774)
RCT_EXPORT_NOT_OSX_VIEW_PROPERTY(showSoftInputOnFocus, BOOL) // TODO(macOS GH#774)
RCT_EXPORT_VIEW_PROPERTY(maxLength, NSNumber)
RCT_EXPORT_NOT_OSX_VIEW_PROPERTY(selectTextOnFocus, BOOL) // TODO(macOS GH#774)
RCT_EXPORT_VIEW_PROPERTY(selection, RCTTextSelection)
RCT_EXPORT_VIEW_PROPERTY(inputAccessoryViewID, NSString)
RCT_EXPORT_VIEW_PROPERTY(textContentType, NSString)
RCT_EXPORT_VIEW_PROPERTY(passwordRules, NSString)

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSelectionChange, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onTextInput, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onScroll, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(mostRecentEventCount, NSInteger)

RCT_EXPORT_SHADOW_PROPERTY(text, NSString)
RCT_EXPORT_SHADOW_PROPERTY(placeholder, NSString)
RCT_EXPORT_SHADOW_PROPERTY(onContentSizeChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(multiline, BOOL, RCTUIView) // TODO(macOS GH#774)
{
  // No op.
  // This View Manager doesn't use this prop but it must be exposed here via ViewConfig to enable Fabric component use it.
}

- (RCTShadowView *)shadowView
{
  RCTBaseTextInputShadowView *shadowView = [[RCTBaseTextInputShadowView alloc] initWithBridge:self.bridge];
#if !TARGET_OS_OSX // TODO(macOS GH#774)
  shadowView.textAttributes.fontSizeMultiplier = [[[self.bridge
                                                    moduleForName:@"AccessibilityManager"
                                                    lazilyLoadIfNecessary:YES] valueForKey:@"multiplier"] floatValue];
#endif // TODO(macOS GH#774)
  [_shadowViews addObject:shadowView];
  return shadowView;
}

- (void)setBridge:(RCTBridge *)bridge
{
  [super setBridge:bridge];

  _shadowViews = [NSHashTable weakObjectsHashTable];

  [bridge.uiManager.observerCoordinator addObserver:self];

#if !TARGET_OS_OSX // TODO(macOS GH#774)
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleDidUpdateMultiplierNotification)
                                               name:@"RCTAccessibilityManagerDidUpdateMultiplierNotification"
                                             object:[bridge moduleForName:@"AccessibilityManager"
                                                    lazilyLoadIfNecessary:YES]];
#endif // TODO(macOS GH#774)
}

RCT_EXPORT_METHOD(focus : (nonnull NSNumber *)viewTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTUIView *> *viewRegistry) { // TODO(macOS GH#774)
    RCTUIView *view = viewRegistry[viewTag]; // TODO(macOS GH#774)
    [view reactFocus];
  }];
}

RCT_EXPORT_METHOD(blur : (nonnull NSNumber *)viewTag)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTUIView *> *viewRegistry) { // TODO(macOS GH#774)
    RCTUIView *view = viewRegistry[viewTag]; // TODO(macOS GH#774)
    [view reactBlur];
  }];
}

RCT_EXPORT_METHOD(setTextAndSelection : (nonnull NSNumber *)viewTag
                 mostRecentEventCount : (NSInteger)mostRecentEventCount
                                value : (NSString *)value
                                start : (NSInteger)start
                                  end : (NSInteger)end)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTUIView *> *viewRegistry) { // TODO(macOS GH#774)
    RCTBaseTextInputView *view = (RCTBaseTextInputView *)viewRegistry[viewTag];
    NSInteger eventLag = view.nativeEventCount - mostRecentEventCount;
    if (eventLag != 0) {
      return;
    }
    RCTExecuteOnUIManagerQueue(^{
      RCTBaseTextInputShadowView *shadowView = (RCTBaseTextInputShadowView *)[self.bridge.uiManager shadowViewForReactTag:viewTag];
      [shadowView setText:value];
      [self.bridge.uiManager setNeedsLayout];
      RCTExecuteOnMainQueue(^{
        [view setSelectionStart:start selectionEnd:end];
      });
    });
  }];
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerWillPerformMounting:(__unused RCTUIManager *)uiManager
{
  for (RCTBaseTextInputShadowView *shadowView in _shadowViews) {
    [shadowView uiManagerWillPerformMounting];
  }
}

#pragma mark - Font Size Multiplier

- (void)handleDidUpdateMultiplierNotification
{
  CGFloat fontSizeMultiplier = [[[self.bridge moduleForName:@"AccessibilityManager"]
                                 valueForKey:@"multiplier"] floatValue];

  NSHashTable<RCTBaseTextInputShadowView *> *shadowViews = _shadowViews;
  RCTExecuteOnUIManagerQueue(^{
    for (RCTBaseTextInputShadowView *shadowView in shadowViews) {
      shadowView.textAttributes.fontSizeMultiplier = fontSizeMultiplier;
      [shadowView dirtyLayout];
    }

    [self.bridge.uiManager setNeedsLayout];
  });
}

@end
