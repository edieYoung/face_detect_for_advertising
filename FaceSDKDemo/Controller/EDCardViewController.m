//
//  EDCardViewController.h
//  CardDemo
//
//  Created by Yang Yidi on 2018/3/29.
//  Copyright © 2018 Yang Yidi. All rights reserved.
//

#import "EDCardViewController.h"
#import "FCPPSDK.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FCExtension.h"
#import "AFNetWorking.h"

#import "EDFacesStat.h"

@interface FaceCell : UITableViewCell
@property (strong , nonatomic) UIImage *fullImage;
@property (strong , nonatomic) NSDictionary *faceInfo;


@end

@implementation FaceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.font = [UIFont systemFontOfSize:15];
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return self;
}

- (void)setFaceInfo:(NSDictionary *)faceInfo{
    _faceInfo = faceInfo;
    //分析数据
    NSDictionary *rect = faceInfo[@"face_rectangle"];
    //裁剪出人脸
    CGFloat x = [rect[@"left"] floatValue];
    CGFloat y = [rect[@"top"] floatValue];
    CGFloat w = [rect[@"width"] floatValue];
    CGFloat h = [rect[@"height"] floatValue];
    self.imageView.image = [self.fullImage cropWithRect:CGRectMake(x, y, w, h)];
    
    //获取属性
    NSDictionary *att = faceInfo[@"attributes"];
    NSMutableString *detailStr = [NSMutableString string];
    
    NSString *value = nil;
    value = att[@"gender"][@"value"];
    [detailStr appendFormat:@"性别: %@",value];
    
    value = att[@"age"][@"value"];
    [detailStr appendFormat:@"\n年龄: %@",value];
    
    value = [self largeKeyWith:att[@"smile"]];
    NSString *score = att[@"smile"][@"value"];
    
    if ([value isEqualToString:@"value"]) {
        value = [NSString stringWithFormat:@"\n微笑分数: %.2f,是否微笑: 是",score.floatValue];
    }else{
        value = [NSString stringWithFormat:@"\n微笑分数: %.2f,是否微笑: 否",score.floatValue];
    }
    [detailStr appendFormat:@"\n%@",value];
    NSDictionary *emotionDic = att[@"emotion"];
    value = [self largeKeyWith:emotionDic];
    [detailStr appendFormat:@"\n表情: %@",value];
    
    value = att[@"ethnicity"][@"value"];
    [detailStr appendFormat:@"\n人种: %@",value];
    
    NSDictionary *temp = att[@"eyestatus"][@"left_eye_status"];
    NSDictionary *eyeDic = @{@"occlusion" : @"眼睛被遮挡",
                             @"no_glass_eye_open" : @"不戴眼镜且睁眼",
                             @"normal_glass_eye_close" : @"佩戴普通眼镜且闭眼",
                             @"normal_glass_eye_open" : @"佩戴普通眼镜且睁眼",
                             @"dark_glasses" : @"佩戴墨镜",
                             @"no_glass_eye_close" : @"不戴眼镜且闭眼"};
    value = [self largeKeyWith:temp];
    [detailStr appendFormat:@"\n左眼状态: %@",eyeDic[value]];
    
    temp = att[@"eyestatus"][@"right_eye_status"];
    value = [self largeKeyWith:temp];
    [detailStr appendFormat:@"\n右眼状态: %@",eyeDic[value]];
    
    temp = att[@"headpose"];
    [detailStr appendFormat:@"\n抬头角度: %@",temp[@"pitch_angle"]];
    [detailStr appendFormat:@"\n平面旋转角度: %@",temp[@"roll_angle"]];
    [detailStr appendFormat:@"\n左右摇头角度: %@",temp[@"yaw_angle"]];
    
    value = [self largeKeyWith:att[@"facequality"]];
    score = att[@"facequality"][@"value"];
    if ([value isEqualToString:@"value"]) {
        value = [NSString stringWithFormat:@"人脸质量分数: %.2f, 可以用做人脸比对",score.floatValue];
    }else{
        value = [NSString stringWithFormat:@"人脸质量分数: %.2f, 不建议用做人脸比对",score.floatValue];
    }
    [detailStr appendFormat:@"\n%@",value];
    
    self.detailTextLabel.text = detailStr;
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

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 5, 50, 50);
    self.detailTextLabel.frame = CGRectMake(60, 5, self.bounds.size.width - 55 - 5, self.bounds.size.height - 10);
}

@end


@interface EDCardViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
//face detect
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) BOOL isStart;
@property (nonatomic, assign) BOOL isAbort;
@property (nonatomic, strong) AVPlayer *myPlayer;

@property (strong , nonatomic) NSDictionary *faceInfo;
@property (strong , nonatomic) EDFacesStat *faceStat;
@property (strong , nonatomic) NSString *adRec;
@end

@implementation EDCardViewController


- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width/3, self.view.bounds.size.height/3)];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"评价广告" style:UIBarButtonItemStylePlain target:self action:@selector(changeImage)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width-10*2, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -15, 0, 0);
    self.tableView.scrollEnabled = true;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height *0.5)];
    
    //edie
    _isAbort = false;
    //1.从mainBundle获取test.mp4的具体路径
    NSString * path = [[NSBundle mainBundle] pathForResource:self.adName ofType:@"mp4"];
    //2.文件的url
    NSURL * url = [NSURL fileURLWithPath:path];
    
    //3.根据url创建播放器(player本身不能显示视频)
    AVPlayer * player = [AVPlayer playerWithURL:url];
    
    //4.根据播放器创建一个视图播放的图层
    AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    //5.设置图层的大小
    layer.frame = CGRectMake(0, 10, bgView.bounds.size.width, bgView.bounds.size.height -10*2);
    
    //6.添加到控制器的view的图层上面
   [bgView.layer addSublayer:layer];
    //7.开始播放
    [player play];
    [self getPlayer:player];
    self.faceStat = [[EDFacesStat alloc] init];
    
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height *0.5)];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, bgView.bounds.size.width, bgView.bounds.size.height -10*2)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [footView addSubview:self.imageView];
    
    self.tableView.tableHeaderView = bgView;
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
    
    //打开人脸检测 人脸画面
    [self setupUI];
    
    
}

- (void)getPlayer:( AVPlayer *)player {
    _myPlayer = player;
}

- (void)setupUI{
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.captureDevice = device;
                NSLog(@"Device found");
                [self beginSession];
            }
        }
    }
    
    
    [self.view addSubview:self.maskView];
    //    [self.view addSubview:self.testImageView];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(start) userInfo:nil repeats:true];
}

- (void)beginSession{
    NSLog(@"beginSession");
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:&error];
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }else{
        NSLog(@"add input error");
    }
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:cameraQueue];
    //    output.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : [NSString stringWithFormat:@"%u",(unsigned int)kCVPixelFormatType_32BGRA]};
    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithUnsignedInteger:kCVPixelFormatType_32BGRA],
                            kCVPixelBufferPixelFormatTypeKey,
                            nil];
    //  @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInteger:kCVPixelFormatType_32BGRA]};
    [self.captureSession addOutput:output];
    
    if (error) {
        NSLog(@"error:%@",error.description);
    }
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = @"AVLayerVideoGravityResizeAspect";
    self.previewLayer.frame = CGRectMake(0,0,self.view.bounds.size.width/4, self.view.bounds.size.height/4);
    [self.view.layer addSublayer:self.previewLayer];
    [self.captureSession startRunning];
}

- (void)start{
    self.isStart = true;
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.isStart) {
        UIImage *resultImage = [self sampleBufferToImage:sampleBuffer];
        
        [self handleImage:resultImage];
        
        self.isStart = false;
    }
}

- (UIImage *)sampleBufferToImage:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    UIImage *result = [[UIImage alloc] initWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    CGImageRelease(videoImage);
    NSLog(@"to image sucess");
    return result;
    
}
- (void)methodOnePerformSelector{
    [self performSelector:@selector(delayMethod) withObject:nil/*可传任意类型参数*/ afterDelay:20.0];
}
- (void)delayMethod{
    NSLog(@"delayMethodEnd");
}


- (void)changeImage{
     [self.captureSession stopRunning];
    _isAbort = true;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"评价这则广告" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    
    
    NSString *okmessage = [NSString stringWithFormat:@"数据上传成功！已为您成功匹配一则广告，即将播放"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功" message:okmessage preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
        
        [self recmandAd:self.adRec];
        NSLog(@"result11 = %@",self.adRec);
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    UIAlertController *erroralert = [UIAlertController alertControllerWithTitle:@"失败" message:@"评价失败，请重新提交！" preferredStyle: UIAlertControllerStyleAlert];
    [erroralert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //点击按钮的响应事件；
    }]];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"已知晓" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _adScore = @"0";
        if(_faceInfo){
        [weakSelf writeToTxt:[_faceStat faceInfo:_faceInfo withAdName:_adName withAdScore:_adScore]];
            [NSThread sleepForTimeInterval:10.00f];
            if(self.adRec){
                [self presentViewController:alert animated:true completion:nil];
            }else{
                [self presentViewController:erroralert animated:true completion:nil];
            }
        }else{
            [self presentViewController:erroralert animated:true completion:nil];
        }
        
    }];
    [alertVC addAction:alertAction];
    
    UIAlertAction *knowAction = [UIAlertAction actionWithTitle:@"已了解" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _adScore = @"1";
        if(_faceInfo){
            [weakSelf writeToTxt:[_faceStat faceInfo:_faceInfo withAdName:_adName withAdScore:_adScore]];
             [NSThread sleepForTimeInterval:10.00f];
            if(self.adRec){
                [self presentViewController:alert animated:true completion:nil];
            }else{
                [self presentViewController:erroralert animated:true completion:nil];
            }
        }else{
            [self presentViewController:erroralert animated:true completion:nil];
        }
    }];
    [alertVC addAction:knowAction];
    
    
    UIAlertAction *likeAction = [UIAlertAction actionWithTitle:@"喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _adScore = @"2";
        if(_faceInfo){
            [weakSelf writeToTxt:[_faceStat faceInfo:_faceInfo withAdName:_adName withAdScore:_adScore]];
             [NSThread sleepForTimeInterval:10.00f];//延迟等待请求完成
            if(self.adRec){
                [self presentViewController:alert animated:true completion:nil];
            }else{
                [self presentViewController:erroralert animated:true completion:nil];
            }
        }else{
            [self presentViewController:erroralert animated:true completion:nil];
        }
    }];
    [alertVC addAction:likeAction];
    
    
    UIAlertAction *preferAction = [UIAlertAction actionWithTitle:@"非常喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _adScore = @"3";
        if(_faceInfo){
            [weakSelf writeToTxt:[_faceStat faceInfo:_faceInfo withAdName:_adName withAdScore:_adScore]];
            [NSThread sleepForTimeInterval:10.00f];//延迟等待请求完成
            if(self.adRec){
                [self presentViewController:alert animated:true completion:nil];
            }else{
                [self presentViewController:erroralert animated:true completion:nil];
            }
        }else{
            [self presentViewController:erroralert animated:true completion:nil];
        }
    }];
    [alertVC addAction:preferAction];
    
    
    UIAlertAction *trustAction = [UIAlertAction actionWithTitle:@"非常相信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _adScore = @"4";
        if(_faceInfo){
            [weakSelf writeToTxt:[_faceStat faceInfo:_faceInfo withAdName:_adName withAdScore:_adScore]];
            [NSThread sleepForTimeInterval:10.00f];//延迟等待请求完成
            if(self.adRec){
                [self presentViewController:alert animated:true completion:nil];
            }else{
                [self presentViewController:erroralert animated:true completion:nil];
            }
        }else{
            [self presentViewController:erroralert animated:true completion:nil];
        }
    }];
    [alertVC addAction:trustAction];
    
    
    UIAlertAction *buyAction = [UIAlertAction actionWithTitle:@"会购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _adScore = @"5";
        if(_faceInfo){
           [weakSelf writeToTxt:[_faceStat faceInfo:_faceInfo withAdName:_adName withAdScore:_adScore]];
            
            [NSThread sleepForTimeInterval:10.00f];//延迟等待请求完成
            if(self.adRec){
                [self presentViewController:alert animated:true completion:nil];
            }else{
                [self presentViewController:erroralert animated:true completion:nil];
            }
        }else{
            [self presentViewController:erroralert animated:true completion:nil];
        }
    }];
    [alertVC addAction:buyAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}






- (void)handleImage:(UIImage *)image{
    //清除人脸框
    [self.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //检测人脸
    FCPPFaceDetect *faceDetect = [[FCPPFaceDetect alloc] initWithImage:image];
    self.imageView.image = faceDetect.image;
    self.image = faceDetect.image;
    
    __weak typeof(self) weakSelf = self;
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //需要获取的属性
    NSArray *att = @[@"gender",@"age",@"headpose",@"smiling",@"blur",@"eyestatus",@"emotion",@"facequality",@"ethnicity"];
    [faceDetect detectFaceWithReturnLandmark:YES attributes:att completion:^(id info, NSError *error) {
        //[MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.tableView.contentOffset = CGPointMake(0, -64);
        [weakSelf.dataArray removeAllObjects];
        
        if (info) {
            NSArray *array = info[@"faces"];
            if (array.count) {
                UIImage *image = faceDetect.image;
                
                //绘制关键点和矩形框
                [weakSelf handleImage:image withInfo:array];
                
                //显示每个人脸的详细信息
                [weakSelf.dataArray addObjectsFromArray:array];
                //显示json
                [weakSelf showResult:info];
                //写入txt文件
                //[weakSelf writeToTxt:info];
                
                
            }else{
                [weakSelf showContent:@"没有检测到人脸"];
            }
        }else{
            [weakSelf showError:error];
        }
        [weakSelf.tableView reloadData];
        
    }];
}


- (void)writeToTxt:(NSString *)result{
    if (result) {
        //[result writeToFile:[self dataFilePath] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        [self uploadRecord:result];
    }
}


-(NSString *)dataFilePath{
    NSLog(@"文件路径...");
    //NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory=[paths objectAtIndex:0];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"result" ofType:@"txt"];
    NSLog(@"%@",path);
    return path;
}


-(void)uploadRecord:(NSString *)record{
    //NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.10/info.php?value=%@",record]];
   
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.5.144/info.php?value=%@",record]];
   
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        NSLog(@"result = %@",result);
        self.adRec = result?result:NULL;
    }];
    
    
    [task resume];
   
    
}


- (void)handleImage:(UIImage *)image withInfo:(NSArray *)array{
    
    CGFloat scaleH = self.imageView.bounds.size.width / image.size.width;
    CGFloat scaleV = self.imageView.bounds.size.height / image.size.height;
    CGFloat scale = scaleH < scaleV ? scaleH : scaleV;
    CGFloat offsetX = image.size.width*(scaleH - scale)*0.5;
    CGFloat offsetY = image.size.height*(scaleV - scale)*0.5;
    
    //绘制矩形框
    for (NSDictionary *dic in array) {
        NSDictionary *rect = dic[@"face_rectangle"];
        CGFloat angle = [dic[@"attributes"][@"headpose"][@"roll_angle"] floatValue];
        
        CGFloat x = [rect[@"left"] floatValue];
        CGFloat y = [rect[@"top"] floatValue];
        CGFloat w = [rect[@"width"] floatValue];
        CGFloat h = [rect[@"height"] floatValue];
        
        UIView *rectView = [[UIView alloc] initWithFrame:CGRectMake(x*scale+offsetX, y*scale+offsetY, w*scale, h*scale)];
        rectView.transform = CGAffineTransformMakeRotation(angle/360.0 *2*M_PI);
        rectView.layer.borderColor = [UIColor greenColor].CGColor;
        rectView.layer.borderWidth = 1;
        
        [self.imageView addSubview:rectView];
    }
    
    //绘制关键点
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointZero];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSDictionary *dic in array) {
        NSArray *dicArr = [dic[@"landmark"] allValues];
        for (NSDictionary *p in dicArr) {
            CGFloat x = [p[@"x"] floatValue];
            CGFloat y = [p[@"y"] floatValue];
            
            [[UIColor blueColor] set];
            CGContextAddArc(context, x, y, 1/scale, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathFill);
        }
    }
    
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = temp;
}

- (void)recmandAd:(NSString *)recAd{
    [self.myPlayer pause];
    EDCardViewController *detectVC = [[EDCardViewController alloc] init];
    detectVC.adName = recAd;
    [self.navigationController pushViewController:detectVC animated:YES];
}


#pragma mark- tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"faceCellId";
    FaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[FaceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.fullImage = self.image;
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.faceInfo = dic;
    _faceInfo = dic;
    if(!_isAbort){
    //设随机的视频激励因子
    NSNumber *intensity = [[NSNumber alloc] initWithInt:arc4random() % 100];
    //intensity = [[NSNumber alloc] initWithDouble:pow(M_E, [intensity doubleValue])];
    //一条记录
    [self.faceStat weightedFaceInfo:_faceInfo withIntensity:intensity];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 242;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.captureSession stopRunning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.captureSession stopRunning];
    [self.myPlayer pause];
}

#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
