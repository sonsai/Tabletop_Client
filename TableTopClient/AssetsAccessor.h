//
//  AssetsAccessor.h
//
//
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol AssetsAccessorDelegate <NSObject>
@optional
- (void)assetDidLoadByURL:(ALAsset *)asset;
- (void)assetDidFailLoadWithError:(NSError *)error;
- (void)assetsDidLoadByURLs:(NSArray *)assets;

- (void)assetsGroupsDidLoad:(NSArray *)groups;
- (void)assetsDidLoadByGroup:(NSArray *)photoAssets_ Video:(NSArray *)videoAssets_;
@end

@interface AssetsAccessor : NSObject {
    BOOL isGettingMultipleAssets;
    int numURLs;
    NSMutableArray *assetsArray;
}

@property (nonatomic, retain) id<AssetsAccessorDelegate> delegate;
@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;

- (id)init;
- (id)initWithDelegate:(id<AssetsAccessorDelegate>)delegate;
- (void)getAssetByURL:(NSURL *)assetURL;
- (void)getAssetsByURLs:(NSArray *)assetURLs;
- (void)getAssetsGroupsWithTypes:(ALAssetsGroupType)groupTypes;
- (void)getAssetsFromGroup:(ALAssetsGroup *)group withFilter:(ALAssetsFilter *)filter;

@end
