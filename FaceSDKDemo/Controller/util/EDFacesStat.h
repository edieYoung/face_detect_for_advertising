//
//  EDFacesStat.h
//  FaceSDKDemo
//
//  Created by edie.young on 2018/3/31.
//  
//

#import <Foundation/Foundation.h>

@interface EDFacesStat : NSObject
@property (strong , nonatomic) NSDictionary *faceInfo;
@property (strong , nonatomic) NSMutableDictionary *weightedFaceInfo;
@property (nonatomic) BOOL *remove;
- (NSString *)faceInfo: (NSDictionary *)faceInfo withAdName:(NSString *)adName withAdScore:(NSString *)preference;
- (void)weightedFaceInfo: (NSDictionary *)faceInfo withIntensity:(NSNumber *)intensity;

- (NSNumber *)weightedMean: (NSArray *)faceDataList withIntensity:(NSArray *)intensityList;


@end
