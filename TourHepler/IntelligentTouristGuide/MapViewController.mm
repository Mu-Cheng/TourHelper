//
//  MapViewController.m
//  IntelligentTouristGuide
//
//  Created by MuChen on 16/7/14.
//  Copyright © 2016年 MuChen. All rights reserved.
//

#import "MapViewController.h"
#import "MyBMKPointAnnotation.h"
#import "DetailViewController.h"
#import "MapUpView.h"
#import "DataSingleton.h"
#import "Location.h"
#import "HttpTool.h"
//#import "BMKGeometry.h"
#define screenHeight ([UIScreen mainScreen].bounds.size.height)
#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define kUpViewHeight (100)
#define kInputTFWeight (15.0/16.0*screenWidth)
#define kInputTFHeight (40)
#define kViewLeftAndRightMargins (5)

@interface MapViewController ()

@property (nonatomic) BOOL isPoi;
@property (nonatomic) BOOL isUpViewPop;
@property (nonatomic,strong) Location* curlocation;

@end

@implementation MapViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPoi = NO;
        _isUpViewPop = NO;
        
        if (_inputTF==Nil) {
            _inputTF = [[UITextField alloc]init];
            _inputTF.frame = CGRectMake(0, 64, screenWidth, kInputTFHeight);
            _inputTF.backgroundColor = [UIColor whiteColor];
//            _inputTF.layer.masksToBounds = YES;
//            _inputTF.layer.cornerRadius = 6.0;
//            _inputTF.layer.borderWidth = 0;
            _inputTF.placeholder = @"点击搜索";
            _inputTF.returnKeyType = UIReturnKeySearch;
            _inputTF.clearButtonMode = UITextFieldViewModeWhileEditing;
            UIImageView *inputView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kInputTFHeight-17, kInputTFHeight-17)];
            [inputView setImage:[UIImage imageNamed:@"旅游助手－搜索.png"]];
            _inputTF.leftView=inputView;
            _inputTF.leftViewMode = UITextFieldViewModeAlways;
            //        //        _locationBtn.titleLabel.textColor = [UIColor blackColor];
            //        [_locationBtn setTitle:@"景点" forState:UIControlStateNormal];
            //        [_locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //
            //        [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationBar.titleLabel.text = self.titleText;
    [self.navigationBar.leftBtn setImage:[UIImage imageNamed:@"旅游助手－返回.png"] forState:UIControlStateNormal];
    [self.navigationBar.rightBtn setHidden:YES];
    
    
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, 414, screenHeight-64)];
    _mapView.delegate = self;
    //[mapView setMapType:BMKMapTypeSatellite];
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.showMapScaleBar = YES;//显示比例尺
    _mapView.zoomLevel=19;//地图显示的级别
    BMKLocationViewDisplayParam* myBMKLocationViewDisplayParam = [[BMKLocationViewDisplayParam alloc]init];
    myBMKLocationViewDisplayParam.isAccuracyCircleShow = NO;
    myBMKLocationViewDisplayParam.locationViewImgName = @"旅游助手－地图大钉子.png";
    [_mapView updateLocationViewWithParam:myBMKLocationViewDisplayParam];
    
//    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(10, 64+10, screenWidth-10*2, 35)];
//    _searchBar.showsCancelButton = YES;
    //    searchBar.prompt = @"搜索";
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    _mapView.showsUserLocation = YES;//显示定位图层
    
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    
    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    //编码服务的初始化(就是获取经纬度,或者获取地理位置服务)
    _geoCodeSearch.delegate = self;//设置代理为self
    
//    [_mapView updateLocationData:_locService.userLocation];
//    CLLocationCoordinate2D tem;
//    tem.latitude = 103.924245;
//    tem.longitude = 33.273342;
//    [_mapView setCenterCoordinate:tem animated:YES];
    
    //普通态
    //以下_mapView为BMKMapView对象
    
//    [mapView updateLocationData:_locService];
    [self insertLocationAnnotation];
    
    [self.view addSubview:_mapView];
    
    
    [self.view addSubview:_inputTF];
    _inputTF.delegate = self;
    
}

#pragma mark - 搜索相关按钮点击事件

- (void)locationBtnClick:(UIButton *)btn
{
    _inputTF.text = @"";
    [_inputTF resignFirstResponder];
    [_mapView removeAnnotations:_mapView.annotations];
    [self insertLocationAnnotation];
    [_mySearchBar removeFromSuperview];
    [_translucentBtn removeFromSuperview];
}

- (void)wcBtnClick:(UIButton *)btn
{
    [_inputTF resignFirstResponder];
    [_mapView removeAnnotations:_mapView.annotations];
    //初始化检索对象
    _searcher =[[BMKPoiSearch alloc]init];
    _searcher.delegate = self;
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 0;
    option.pageCapacity = 50;
    option.radius = 100000;
    
    option.location = _locService.userLocation.location.coordinate;
    option.keyword = @"厕所";
    BOOL flag = [_searcher poiSearchNearBy:option];
    //    [option release];
    if(flag)
    {
        NSLog(@"厕所检索发送成功");
    }
    else
    {
        NSLog(@"厕所检索发送失败");
    }

    _inputTF.text = @"";
    [_inputTF resignFirstResponder];
    [_mySearchBar removeFromSuperview];
    [_translucentBtn removeFromSuperview];
}

- (void)foodBtnClick:(UIButton *)btn
{
    [_inputTF resignFirstResponder];
    [_mapView removeAnnotations:_mapView.annotations];
    //初始化检索对象
    _searcher =[[BMKPoiSearch alloc]init];
    _searcher.delegate = self;
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 0;
    option.pageCapacity = 50;
    option.radius = 100000;
    
    option.location = _locService.userLocation.location.coordinate;
    option.keyword = @"美食";
    BOOL flag = [_searcher poiSearchNearBy:option];
    //    [option release];
    if(flag)
    {
        NSLog(@"美食检索发送成功");
    }
    else
    {
        NSLog(@"美食检索发送失败");
    }
    
    _inputTF.text = @"";
    [_inputTF resignFirstResponder];
    [_mySearchBar removeFromSuperview];
    [_translucentBtn removeFromSuperview];
}

- (void)translucentBtnClick:(UIButton *)btn{
    _inputTF.text = @"";
    [_inputTF resignFirstResponder];
    [_mySearchBar removeFromSuperview];
    [_translucentBtn removeFromSuperview];
}


#pragma  mark- 控制TF

- ( BOOL )textFieldShouldClear:( UITextField*)textField{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    _translucentBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kInputTFHeight+64, screenWidth, screenHeight-kInputTFHeight)];
    _translucentBtn.backgroundColor = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    _translucentBtn.alpha = 0.4;
    
    [_translucentBtn addTarget:self action:@selector(translucentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_translucentBtn];
//    [textField resignFirstResponder];
    _mySearchBar = [[MySearchBar alloc]init];
    
    [self.view addSubview:_mySearchBar];
    _mySearchBar.delegate = self;
    return YES;
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [_mapView removeAnnotations:_mapView.annotations];
    if (![textField.text isEqualToString:@""]) {
        //初始化检索对象
        _searcher =[[BMKPoiSearch alloc]init];
        _searcher.delegate = self;
        //发起检索
        BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
        option.pageIndex = 0;
        option.pageCapacity = 50;
        option.radius = 100000;
        
        option.location = _locService.userLocation.location.coordinate;
        option.keyword = textField.text;
        BOOL flag = [_searcher poiSearchNearBy:option];
        //    [option release];
        if(flag)
        {
            NSLog(@"%@检索发送成功",textField.text);
        }
        else
        {
            NSLog(@"%@检索发送失败",textField.text);
        }
    }
    textField.text = @"";
    [textField resignFirstResponder];
    [_mySearchBar removeFromSuperview];
    [_translucentBtn removeFromSuperview];
    return YES;
}



#pragma mark- 导航栏左buttom

- (void)leftBtnDidClick:(UIButton *)leftBtn{
    NSLog(@"MAP leftBtnDidClick");
//    NSLog(@"点击goToBtn");
//    DetailViewController *deVC = [[DetailViewController alloc]init];
//    deVC.titleText = @"卧龙海";
//    deVC.detailImg = @"卧龙海.jpeg";
//    deVC.detailText = @"卧龙海海拔2215米，深22米。小巧玲珑的卧龙海是蓝色湖泊典型的代表，极浓重的蓝色醉人心田。湖面水波不兴，宁静祥和，像一块光滑平整、晶莹剔透的蓝宝石。透过波平如镜的水面，一条乳白色钙华长堤横卧湖心，宛若一条蛟龙潜游海底。";
//    
//    [self.navigationController pushViewController:deVC animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark- Poi搜索

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
//        NSLog(@"结果为：%@",poiResultList.poiInfoList);
        CLLocationCoordinate2D coorCenter;
        BOOL ok = NO;
        NSMutableArray* mutArr = [[NSMutableArray alloc]init];
        for (BMKPoiInfo* obj in poiResultList.poiInfoList) {
//            NSLog(@"obj.name = %@ obj.address = %@ obj.city = %@ obj.phone = %@ obj.postcode = %@ obj.pt.latitude = %@ obj.pt.longitude = %d ",obj.name,obj.address,obj.city,obj.city,obj.phone,obj.postcode,obj.epoitype,obj.pt.latitude,obj.pt.longitude);
            if (ok==NO) {
                ok = YES;
                coorCenter = obj.pt;
            }
            CLLocationCoordinate2D coordinate = obj.pt;
            //设置地图标注
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            annotation.coordinate = coordinate;
            annotation.title = obj.name;
            annotation.subtitle = obj.phone;
            [mutArr addObject:annotation];
        }
        [_mapView addAnnotations:mutArr];
        
        BMKMapStatus *temp = [[BMKMapStatus alloc]init];
        temp.targetGeoPt = coorCenter;
        temp.fLevel = 19;
        
        [_mapView setMapStatus:temp withAnimation:YES withAnimationTime:1000];
        
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
}

-(void)viewWillAppear:(BOOL)animated{
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [_mapView viewWillAppear];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
//    [self passLocationValue];
    [_mapView updateLocationData:userLocation];
//    [_mapView updateLocationData:userLocation];
    
    if(!_isPoi){
        _isPoi = YES;
//        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//        annotation.coordinate = coordinate;
//        annotation.title = obj.name;
//        annotation.subtitle = obj.phone;
//        BMKPointAnnotation *myLocationAnnotation = [[BMKPointAnnotation alloc]init];
//        myLocationAnnotation.coordinate = userLocation.location.coordinate;
//        myLocationAnnotation.title = userLocation.title;
//        myLocationAnnotation.subtitle = userLocation.subtitle;
//        
//        [_mapView addAnnotation:myLocationAnnotation];
        _mapView.centerCoordinate = userLocation.location.coordinate;
//        //初始化检索对象
//        _searcher =[[BMKPoiSearch alloc]init];
//        _searcher.delegate = self;
//        //发起检索
//        BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
//        option.pageIndex = 0;
//        option.pageCapacity = 50;
//        option.radius = 100000;
//    
//        option.location = userLocation.location.coordinate;
//        option.keyword = @"旅游景点";
//        BOOL flag = [_searcher poiSearchNearBy:option];
//        //    [option release];
//        if(flag)
//        {
//            NSLog(@"周边检索发送成功");
//        }
//        else
//        {
//            NSLog(@"周边检索发送失败");
//        }
    }
    
//    [_locService stopUserLocationService];//取消定位
}

#pragma mark 定义每个标注样式

//上标注

- (void) insertLocationAnnotation{
    DataSingleton * dataSL = [DataSingleton shareInstance];
    NSMutableArray* mutArr = [[NSMutableArray alloc]init];
    CLLocationCoordinate2D coorCenter;
    BOOL ok = NO;
    for (Location *obj in dataSL.allDetail) {
        if (ok == NO) {
            ok = YES;
            coorCenter = obj.coor;
        }
        CLLocationCoordinate2D coordinate = obj.coor;
        //设置地图标注
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = coordinate;
        annotation.title = obj.locationName;
        annotation.subtitle = obj.locationText;
        [mutArr addObject:annotation];
    }
    [_mapView addAnnotations:mutArr];
    
    /**
     *	设置地图状态
     *	@param	[in]	mapStatus	地图状态信息
     *	@param	[in]	bAnimation	是否需要动画效果，true:需要做动画
     */
//    - (void)setMapStatus:(BMKMapStatus*)mapStatus withAnimation:(BOOL)bAnimation;
    BMKMapStatus *temp = [[BMKMapStatus alloc]init];
    temp.targetGeoPt = coorCenter;
    temp.fLevel = 19;
    
    [_mapView setMapStatus:temp withAnimation:YES withAnimationTime:1000];
    
//    [_mapView setCenterCoordinate:coorCenter animated:YES];
    
//    _mapView.zoomLevel=19;
    
    
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.animatesDrop = YES;
        newAnnotationView.annotation = annotation;
//        MyBMKPointAnnotation *tt = (MyBMKPointAnnotation *)annotation;
        
        //判断类别，需要添加不同类别，来赋予不同的标注图片
//        if (tt.profNumber == 100000) {
//            newAnnotationView.image = [UIImage imageNamed:@"ic_map_mode_category_merchants_normal.png"];
//        }else if (tt.profNumber == 100001){
//            
//        }
        newAnnotationView.image = [UIImage imageNamed:@"旅游助手－地图钉子.png"];
        
        //设定popView的高度，根据是否含有缩略图
        double popViewH = 60;
        if (annotation.subtitle == nil) {
            popViewH = 38;
        }
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        UIView *popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth-100, popViewH)];
        popView.backgroundColor = [UIColor whiteColor];
        [popView.layer setMasksToBounds:YES];
        [popView.layer setCornerRadius:3.0];
        popView.alpha = 0.9;
        
        //自定义气泡的内容，添加子控件在popView上
        UILabel *driverName = [[UILabel alloc]initWithFrame:CGRectMake(8, 4, popView.frame.size.width-50-8, 30)];
        driverName.text = annotation.title;
        driverName.numberOfLines = 0;
        driverName.backgroundColor = [UIColor clearColor];
        driverName.font = [UIFont systemFontOfSize:15];
        driverName.textColor = [UIColor blackColor];
        driverName.textAlignment = NSTextAlignmentLeft;
        [popView addSubview:driverName];
        
        UILabel *carName = [[UILabel alloc]initWithFrame:CGRectMake(8, 30, 180, 30)];
        [carName setLineBreakMode:NSLineBreakByWordWrapping];
//        carName.lineBreakMode = UILineBreakModeWordWrap;
        carName.text = annotation.subtitle;
        carName.backgroundColor = [UIColor clearColor];
        carName.font = [UIFont systemFontOfSize:11];
        carName.textColor = [UIColor lightGrayColor];
        carName.textAlignment = NSTextAlignmentLeft;
        [popView addSubview:carName];
        
        BOOL ok = NO;
        DataSingleton *dataSL = [DataSingleton shareInstance];
        for (Location *obj in dataSL.allDetail) {
            if ([obj.locationName isEqualToString:annotation.title]) {
                ok = YES;
                break;
            }
        }
        
        if (ok) {
            UIButton *goToBtn = [[UIButton alloc]initWithFrame:CGRectMake(popView.frame.size.width-50, 0, 50, 60)];
            [goToBtn setTitle:@"查看详情" forState:UIControlStateNormal];
            goToBtn.backgroundColor = [UIColor redColor];
            goToBtn.titleLabel.numberOfLines = 0;
            [goToBtn addTarget:self action:@selector(goToBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            [searchBn addTarget:self action:@selector(searchLine)];
            [popView addSubview:goToBtn];
        }
        
        BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc]initWithCustomView:popView];
        pView.frame = CGRectMake(0, 0, screenWidth-100, popViewH);
//        ((BMKPinAnnotationView*)newAnnotationView).paopaoView = nil;
        ((BMKPinAnnotationView*)newAnnotationView).paopaoView = pView;
        return newAnnotationView;
    }
    return nil;
}

- (void)goToBtnClick:(UIButton*)sender{
    if(_curlocation){
        DetailViewController *deVC = [[DetailViewController alloc]init];
        deVC.titleText = _curlocation.locationName;
        deVC.detailImg = _curlocation.locationImageName;
        deVC.detailText = _curlocation.locationText;
        [self presentViewController:deVC animated:YES completion:nil];
    }
}

///**
// *设定view的选中状态
// *该方法被BMKMapView调用
// *@param selected 如果view需要显示为选中状态，该值为YES
// *@param animated 如果需要动画效果，该值为YES,暂不支持
// */
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
//    
//}

//当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    NSLog(@"点击annotation view弹出的泡泡");
}


///**
// *地图区域即将改变时会调用此接口
// *@param mapview 地图View
// *@param animated 是否动画
// */
//- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
//    
//}


//当选中一个annotation views时，调用此接口
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
//    NSLog(@"选中一个annotation views:%f,%f",view.annotation.coordinate.latitude,view.annotation.coordinate.longitude);

    _curlocation = [[Location alloc]init];
    
    DataSingleton *dataSL = [DataSingleton shareInstance];
    for (Location *obj in dataSL.allDetail) {
        if ([view.annotation.title isEqualToString:obj.locationName]) {
            _curlocation = [[Location alloc]initWithlocationName:obj.locationName voice:obj.voice locationImageName:obj.locationImageName distance:obj.distance locationText:obj.locationText coor:obj.coor];
            break;
        }
    }
    
    MapUpView * mapUpView = [[MapUpView alloc]init];
    mapUpView.locationNameLabel.text = view.annotation.title;
    mapUpView.title = self.navigationBar.titleLabel.text;
    
    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(_locService.userLocation.location.coordinate.latitude,_locService.userLocation.location.coordinate.longitude));
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(view.annotation.coordinate.latitude,view.annotation.coordinate.longitude));
    CGFloat distance = BMKMetersBetweenMapPoints(point1,point2);
    [mapUpView getDataWithOwnLocation:CLLocationCoordinate2D(_locService.userLocation.location.coordinate)];
    [mapUpView getDataWithGoToLocation:view.annotation.coordinate];

    if (distance>1000.0) {
        distance/=1000.0;
        mapUpView.distanceLabel.text = [NSString stringWithFormat:@"%.4g",distance];
        mapUpView.distanceLabel.text = [mapUpView.distanceLabel.text stringByAppendingString:@"km"];
    }else{
        mapUpView.distanceLabel.text = [NSString stringWithFormat:@"%g",distance];
        mapUpView.distanceLabel.text = [mapUpView.distanceLabel.text stringByAppendingString:@"m"];
    }
    
    if (_isUpViewPop) {
        mapUpView.frame = CGRectMake(0, screenHeight-kUpViewHeight,screenWidth, kUpViewHeight);
        [self.view addSubview:mapUpView];
    }else{
        _isUpViewPop = YES;
    //1.执行动画
        [self.view addSubview:mapUpView];
//    CGRect *tem = mapUpView.frame;
        [UIView animateWithDuration:0.4 animations:^{
            mapUpView.frame = CGRectMake(0, screenHeight-kUpViewHeight,screenWidth, kUpViewHeight);
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        [self.view addSubview:mapUpView];
//        self.contentView.transform = CGAffineTransformMakeTranslation(0, -self.contentShift);
        }];
//    mapUpView.locationNameLabel.text = view.paopaoView.annotation.title;
//    [UIView animateWithDuration:1 animations:^{
//        //将view.frame 设置在屏幕上方
//        [self.view addSubview:mapUpView];
//    }];
        
        
    }
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(view.annotation.coordinate.latitude,view.annotation.coordinate.longitude) animated:YES];
}

#pragma mark -- BMKMapdelegate


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
