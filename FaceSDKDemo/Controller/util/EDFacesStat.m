//
//  EDFacesStat.m
//  FaceSDKDemo
//
//  Created by edie.young on 2018/3/31.
//  
//

#import "EDFacesStat.h"
#import "UIImage+FCExtension.h"
#import "EDDataBase.h"


@implementation EDFacesStat

- (instancetype)init{//重写init方法
    if(self = [super init])
    {
    NSMutableArray *initArray = [[NSMutableArray alloc] init];
    self.weightedFaceInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:initArray,@"gender",initArray,@"age",initArray,@"age",
                             initArray,@"smile",
                             initArray,@"smilescore",
                             initArray,@"emotion",
                             initArray,@"race",
                             initArray,@"lefteye",
                             initArray,@"leftglass",
                             initArray,@"leftsunglass",
                             initArray,@"righteye",
                             initArray,@"rightglass",
                             initArray,@"rightsunglass",
                             initArray,@"pitchangle",
                             initArray,@"rollangle",
                             initArray,@"yawangle",
                             initArray,@"inensity",
                             nil];
    }
    return self;
}




- (NSString *)faceInfo: (NSDictionary *)faceInfo withAdName:(NSString *)adName withAdScore:(NSString *)preference{
    
    //softmax intensity
    NSArray *intensityPos = [self softmax: _weightedFaceInfo[@"intensity"]];
    NSMutableDictionary *weightedRecord = [[NSMutableDictionary alloc] init];
    NSMutableString *valueStr = [NSMutableString string];
    NSNumber *answer;
    //求各特征的加权平均
    answer = [self weightedMean:_weightedFaceInfo[@"gender"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"gender"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"age"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"age"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"smilescore"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"smilescore"];
    [valueStr appendFormat:@"%@,",answer];
    answer = [self weightedMean:_weightedFaceInfo[@"smile"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"smile"];
    [valueStr appendFormat:@"%@,",answer];
    
    NSDictionary *att = faceInfo[@"attributes"];
    NSString *value = nil;
    NSDictionary *emotionDic = att[@"emotion"];
    value = [self largeKeyWith:emotionDic];
    [valueStr appendFormat:@"'%@',",value];
    
    value = att[@"ethnicity"][@"value"];
    [valueStr appendFormat:@"'%@',",value];
    
    answer = [self weightedMean:_weightedFaceInfo[@"lefteye"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"lefteye"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"leftglass"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"leftglass"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"leftsunglass"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"leftsunglass"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"righteye"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"righteye"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"rightglass"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"rightglass"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"rigthsunglass"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"rigthsunglass"];
    [valueStr appendFormat:@"%@,",answer];
    
    answer = [self weightedMean:_weightedFaceInfo[@"pitchangle"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"pitchangle"];
    [valueStr appendFormat:@"%@,",answer];
    answer = [self weightedMean:_weightedFaceInfo[@"rollangle"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"rollangle"];
    [valueStr appendFormat:@"%@,",answer];
    answer = [self weightedMean:_weightedFaceInfo[@"yawangle"] withIntensity:intensityPos];
    [weightedRecord setValue:answer forKey:@"yawangle"];
    [valueStr appendFormat:@"%@,",answer];
    [valueStr appendFormat:@"'%@',",adName];
    [valueStr appendFormat:@"%@",preference];
    
    return valueStr;
    
}


- (void)weightedFaceInfo: (NSDictionary *)faceInfo withIntensity:(NSNumber *)intensity {

    _faceInfo = faceInfo;
    //获取属性
    NSDictionary *att = faceInfo[@"attributes"];
    //NSMutableArray *temp = [[NSMutableArray alloc] init];
    NSString *value = nil;
    value = att[@"gender"][@"value"];
    if([value isEqual:@"Female"]){
        NSMutableArray *tempGender =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"gender"]];
        NSNumber *gender = [[NSNumber alloc] initWithInt:1];
        [tempGender addObject:gender];
        [self.weightedFaceInfo setValue:tempGender forKey:@"gender"];
    }else if([value isEqual:@"Male"]){
        NSMutableArray *tempGender =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"gender"]];
        NSNumber *gender = [[NSNumber alloc] initWithInt:0];
        [tempGender addObject:gender];
        [self.weightedFaceInfo setValue:tempGender forKey:@"gender"];
    }

    value = att[@"age"][@"value"];
    
    NSMutableArray *tempAge =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"age"]];
    [tempAge addObject:[[NSNumber alloc] initWithFloat:value.floatValue]];
    [self.weightedFaceInfo setValue:tempAge forKey:@"age"];
    
    
    value = [self largeKeyWith:att[@"smile"]];
    NSString *score = att[@"smile"][@"value"];
    
    
    if ([value isEqualToString:@"value"]) {
        
        NSMutableArray *tempSmile =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"smile"]];
        [tempSmile addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempSmile forKey:@"smile"];
        
        
        NSMutableArray *tempSmileScore =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"smilescore"]];
        [tempSmileScore addObject:[[NSNumber alloc] initWithFloat:score.floatValue]];
        [self.weightedFaceInfo setValue:tempSmileScore forKey:@"smilescore"];
        
        
    }else{
        NSMutableArray *tempSmile =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"smile"]];
        [tempSmile addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempSmile forKey:@"smile"];
        
        NSMutableArray *tempSmileScore =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"smilescore"]];
        [tempSmileScore addObject:[[NSNumber alloc] initWithFloat:score.floatValue]];
        [self.weightedFaceInfo setValue:tempSmileScore forKey:@"smilescore"];
    }
    
    NSDictionary *emotionDic = att[@"emotion"];
    value = [self largeKeyWith:emotionDic];
    
    NSMutableArray *tempEmotion =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"emotion"]];
    [tempEmotion addObject:value];
    [self.weightedFaceInfo setValue:tempEmotion forKey:@"emotion"];
    
    
    value = att[@"ethnicity"][@"value"];
    
    NSMutableArray *tempRace =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"race"]];
    [tempRace addObject:value];
    [self.weightedFaceInfo setValue:tempRace forKey:@"race"];
    
    
    NSDictionary *tempdic = att[@"eyestatus"][@"left_eye_status"];
    value = [self largeKeyWith:tempdic];
    
    if([value isEqual:@"occlusion"]){
        //(-1,-1,-1)
        NSMutableArray *tempLeftEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"lefteye"]];
        [tempLeftEye addObject:[[NSNumber alloc] initWithInt:-1]];
        [self.weightedFaceInfo setValue:tempLeftEye forKey:@"lefteye"];
        NSMutableArray *tempLeftGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftglass"]];
        [tempLeftGlass addObject:[[NSNumber alloc] initWithInt:-1]];
        [self.weightedFaceInfo setValue:tempLeftGlass forKey:@"leftglass"];
        NSMutableArray *tempLeftSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftsunglass"]];
        [tempLeftSunGlass addObject:[[NSNumber alloc] initWithInt:-1]];
        [self.weightedFaceInfo setValue:tempLeftSunGlass forKey:@"leftsunglass"];
        
    }else if([value isEqual:@"no_glass_eye_open"]){
        //(1,0,0)
        NSMutableArray *tempLeftEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"lefteye"]];
        [tempLeftEye addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempLeftEye forKey:@"lefteye"];
        NSMutableArray *tempLeftGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftglass"]];
        [tempLeftGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftGlass forKey:@"leftglass"];
        NSMutableArray *tempLeftSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftsunglass"]];
        [tempLeftSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftSunGlass forKey:@"leftsunglass"];
        
    }else if([value isEqual:@"normal_glass_eye_close"]){
        //(0,1,0)
        NSMutableArray *tempLeftEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"lefteye"]];
        [tempLeftEye addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftEye forKey:@"lefteye"];
        NSMutableArray *tempLeftGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftglass"]];
        [tempLeftGlass addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempLeftGlass forKey:@"leftglass"];
        NSMutableArray *tempLeftSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftsunglass"]];
        [tempLeftSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftSunGlass forKey:@"leftsunglass"];
    }else if([value isEqual:@"normal_glass_eye_open"]){
        //(1,1,0)
        NSMutableArray *tempLeftEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"lefteye"]];
        [tempLeftEye addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempLeftEye forKey:@"lefteye"];
        NSMutableArray *tempLeftGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftglass"]];
        [tempLeftGlass addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempLeftGlass forKey:@"leftglass"];
        NSMutableArray *tempLeftSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftsunglass"]];
        [tempLeftSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftSunGlass forKey:@"leftsunglass"];
    }else if([value isEqual:@"dark_glasses"]){
    
        //(0,0,1)
        NSMutableArray *tempLeftEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"lefteye"]];
        [tempLeftEye addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftEye forKey:@"lefteye"];
        NSMutableArray *tempLeftGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftglass"]];
        [tempLeftGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftGlass forKey:@"leftglass"];
        NSMutableArray *tempLeftSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftsunglass"]];
        [tempLeftSunGlass addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempLeftSunGlass forKey:@"leftsunglass"];
    }else if([value isEqual:@"no_glass_eye_close"]){
        //(0,0,0)
        NSMutableArray *tempLeftEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"lefteye"]];
        [tempLeftEye addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftEye forKey:@"lefteye"];
        NSMutableArray *tempLeftGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftglass"]];
        [tempLeftGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftGlass forKey:@"leftglass"];
        NSMutableArray *tempLeftSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"leftsunglass"]];
        [tempLeftSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempLeftSunGlass forKey:@"leftsunglass"];
    }
    
    tempdic = att[@"eyestatus"][@"right_eye_status"];
    value = [self largeKeyWith:tempdic];
    if([value isEqual:@"occlusion"]){
        //(-1,-1,-1)
        NSMutableArray *tempRightEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"righteye"]];
        [tempRightEye addObject:[[NSNumber alloc] initWithInt:-1]];
        [self.weightedFaceInfo setValue:tempRightEye forKey:@"righteye"];
        NSMutableArray *tempRightGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightglass"]];
        [tempRightGlass addObject:[[NSNumber alloc] initWithInt:-1]];
        [self.weightedFaceInfo setValue:tempRightGlass forKey:@"rightglass"];
        NSMutableArray *tempRightSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightsunglass"]];
        [tempRightSunGlass addObject:[[NSNumber alloc] initWithInt:-1]];
        [self.weightedFaceInfo setValue:tempRightSunGlass forKey:@"rightsunglass"];
        
    }else if([value isEqual:@"no_glass_eye_open"]){
        //(1,0,0)
        NSMutableArray *tempRightEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"righteye"]];
        [tempRightEye addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempRightEye forKey:@"righteye"];
        NSMutableArray *tempRightGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightglass"]];
        [tempRightGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightGlass forKey:@"rightglass"];
        NSMutableArray *tempRightSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightsunglass"]];
        [tempRightSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightSunGlass forKey:@"rightsunglass"];
        
    }else if([value isEqual:@"normal_glass_eye_close"]){
        //(0,1,0)
        NSMutableArray *tempRightEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"righteye"]];
        [tempRightEye addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightEye forKey:@"righteye"];
        NSMutableArray *tempRightGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightglass"]];
        [tempRightGlass addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempRightGlass forKey:@"rightglass"];
        NSMutableArray *tempRightSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightsunglass"]];
        [tempRightSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightSunGlass forKey:@"rightsunglass"];
    }else if([value isEqual:@"normal_glass_eye_open"]){
        //(1,1,0)
        NSMutableArray *tempRightEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"righteye"]];
        [tempRightEye addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempRightEye forKey:@"righteye"];
        NSMutableArray *tempRightGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightglass"]];
        [tempRightGlass addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempRightGlass forKey:@"rightglass"];
        NSMutableArray *tempRightSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightsunglass"]];
        [tempRightSunGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightSunGlass forKey:@"rightsunglass"];
    }else if([value isEqual:@"dark_glasses"]){
        //(0,0,1)
        NSMutableArray *tempRightEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"righteye"]];
        [tempRightEye addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightEye forKey:@"righteye"];
        NSMutableArray *tempRightGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightglass"]];
        [tempRightGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightGlass forKey:@"rightglass"];
        NSMutableArray *tempRightSunGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightsunglass"]];
        [tempRightSunGlass addObject:[[NSNumber alloc] initWithInt:1]];
        [self.weightedFaceInfo setValue:tempRightSunGlass forKey:@"rightsunglass"];
    }else if([value isEqual:@"no_glass_eye_close"]){
        
        //(0,0,0)
        NSMutableArray *tempRightEye =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"righteye"]];
        [tempRightEye addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightEye forKey:@"righteye"];
        NSMutableArray *tempRightGlass =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rightglass"]];
        [tempRightGlass addObject:[[NSNumber alloc] initWithInt:0]];
        [self.weightedFaceInfo setValue:tempRightGlass forKey:@"rightglass"];
        
        
    }
   
    
    tempdic = att[@"headpose"];
   
    
    NSMutableArray *tempPitch =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"pitchangle"]];
    [tempPitch addObject:tempdic[@"pitch_angle"]];
    [self.weightedFaceInfo setValue:tempPitch forKey:@"pitchangle"];
   
    
    NSMutableArray *tempRoll =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"rollangle"]];
    [tempRoll addObject:tempdic[@"roll_angle"]];
    [self.weightedFaceInfo setValue:tempRoll forKey:@"rollangle"];
    
    NSMutableArray *tempYaw =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"yawangle"]];
    [tempYaw addObject:tempdic[@"yaw_angle"]];
    [self.weightedFaceInfo setValue:tempYaw forKey:@"yawangle"];
  
    
    NSMutableArray *tempIntensity =[[NSMutableArray alloc] initWithArray:self.weightedFaceInfo[@"intensity"]];
    [tempIntensity addObject:intensity];
    [self.weightedFaceInfo setValue:tempIntensity forKey:@"intensity"];
    
    
}

//取出value值最大的对应的key
- (NSString *)largeKeyWith:(NSDictionary *)dic{
    __block NSString *largeKey = nil;
    __block CGFloat maxValue = 0;
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj floatValue] > maxValue) {
            maxValue = [obj floatValue];
            largeKey = key;
        }
    }];
    return largeKey;
}


//softmax
- (NSArray *)softmax:(NSArray *)intensity{
    double sum=0;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSUInteger i = 0;
    NSUInteger length = [intensity count];
    for(i=0; i<length;i++){
        sum+=[intensity[i] doubleValue];
        
    }
    for(i=0; i<length;i++){
        float ans = [intensity[i] doubleValue]/sum;
        [newArray addObject:[[NSNumber alloc] initWithFloat:ans]];
    }

    
    return newArray;
}

//weight
- (NSNumber *)weightedMean:(NSArray *)faceDataList withIntensity:(NSArray *)intensityList{
    float ans = 0;
    NSUInteger size = [intensityList count];
    for(NSUInteger i = 0;i<size;i++){
        float a = [faceDataList[i] floatValue]*[intensityList[i] floatValue];
        ans += a;
        }
    NSNumber *answer = [[NSNumber alloc] initWithFloat:ans];
    return answer;
}



@end




