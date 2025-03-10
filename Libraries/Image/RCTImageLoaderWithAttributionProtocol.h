/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTUIKit.h> // TODO(macOS GH#774)

#import <React/RCTImageLoaderProtocol.h>
#import <React/RCTImageURLLoaderWithAttribution.h>
#import <React/RCTImageLoaderInstrumentableProtocol.h>

RCT_EXTERN BOOL RCTImageLoadingInstrumentationEnabled(void);
RCT_EXTERN BOOL RCTImageLoadingPerfInstrumentationEnabled(void);
RCT_EXTERN void RCTEnableImageLoadingInstrumentation(BOOL enabled);
RCT_EXTERN void RCTEnableImageLoadingPerfInstrumentation(BOOL enabled);

RCT_EXTERN BOOL RCTGetImageLoadingPerfInstrumentationForFabricEnabled();
RCT_EXTERN void RCTSetImageLoadingPerfInstrumentationForFabricEnabledBlock(BOOL (^getEnabled)());

@protocol RCTImageLoaderWithAttributionProtocol<RCTImageLoaderProtocol, RCTImageLoaderInstrumentableProtocol>

// TODO (T61325135): Remove C++ checks
#ifdef __cplusplus
/**
 * Same as the variant in RCTImageURLLoaderProtocol, but allows passing attribution
 * information that each image URL loader can process.
 */
- (RCTImageURLLoaderRequest *)loadImageWithURLRequest:(NSURLRequest *)imageURLRequest
                                                 size:(CGSize)size
                                                scale:(CGFloat)scale
                                              clipped:(BOOL)clipped
                                           resizeMode:(RCTResizeMode)resizeMode
                                             priority: (RCTImageLoaderPriority)priority
                                          attribution:(const facebook::react::ImageURLLoaderAttribution &)attribution
                                        progressBlock:(RCTImageLoaderProgressBlock)progressBlock
                                     partialLoadBlock:(RCTImageLoaderPartialLoadBlock)partialLoadBlock
                                      completionBlock:(RCTImageLoaderCompletionBlockWithMetadata)completionBlock;
#endif

/**
 * Image instrumentation - start tracking the on-screen visibility of the native image view.
 */
- (void)trackURLImageVisibilityForRequest:(RCTImageURLLoaderRequest *)loaderRequest imageView:(RCTUIView *)imageView; // TODO(macOS GH#774)

/**
 * Image instrumentation - notify that the request was cancelled.
 */
- (void)trackURLImageRequestDidDestroy:(RCTImageURLLoaderRequest *)loaderRequest;

/**
 * Image instrumentation - notify that the native image view was destroyed.
 */
- (void)trackURLImageDidDestroy:(RCTImageURLLoaderRequest *)loaderRequest;

@end
