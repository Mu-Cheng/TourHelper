//
//  HomeViewController.m
//  IntelligentTouristGuide
//
//  Created by Student04 on 16/7/13.
//  Copyright © 2016年 MuChen. All rights reserved.
//

#import "HomeViewController.h"
#import "Location.h"
#import "LocationInfoCell.h"
#import "MapViewController.h"
#import "DetailViewController.h"
#import "SetingViewController.h"
#import "DataSingleton.h"



@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,IFlySpeechSynthesizerDelegate>

@property (nonatomic ,strong) NSArray *dataArr;
@end

@interface HomeViewController ()

@property (nonatomic ,strong) UITableView *mainTableView;
//@property (nonatomic ,strong) MapViewController *mapViewController;
//@property (nonatomic ,strong) DetailViewController *deVC;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#pragma mark - 导航栏初始化
    [self loadDataFromWeb];
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationBar.titleLabel.text = @"九寨沟";
    [self.navigationBar.leftBtn setImage:[UIImage imageNamed:@"homeNabigationLeftIcon.ico"] forState:UIControlStateNormal];
    [self.navigationBar.rightBtn setImage:[UIImage imageNamed:@"homeNabigationRightIcon.ico"] forState:UIControlStateNormal];
    
    CGRect tableViewFrame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
    
    self.mainTableView = [[UITableView alloc]initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:self.mainTableView];
//    语音
//    //1.创建合成对象
//    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance]; _iFlySpeechSynthesizer.delegate =
//    self;
//    
//    //设置在线工作方式
//    [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_CLOUD]
//                                  forKey:[IFlySpeechConstant ENGINE_TYPE]];
//    //音量,取值范围 0~100
//    [_iFlySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]]; //发音人,默认为”xiaoyan”,可以设置的参数列表可参考“合成发音人列表” [_iFlySpeechSynthesizer setParameter:@" xiaoyan " forKey: [IFlySpeechConstant VOICE_NAME]]; //保存合成文件名,如不再需要,设置设置为nil或者为空表示取消,默认目录位于 library/cache下
//    [_iFlySpeechSynthesizer setParameter:@" tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
//    //3.启动合成会话
//    [_iFlySpeechSynthesizer startSpeaking: @"你好,我是科大讯飞的小燕"];
    
    
    
}

- (void) loadDataFromWeb{
    Location *Location1 = [[Location alloc]initWithlocationName:@"卧龙海" voice:@"" locationImageName:@"卧龙海.jpeg" distance:@"1.2KM" locationText:@"卧龙海海拔2215米，深22米。小巧玲珑的卧龙海是蓝色湖泊典型的代表，极浓重的蓝色醉人心田。湖面水波不兴，宁静祥和，像一块光滑平整、晶莹剔透的蓝宝石。透过波平如镜的水面，一条乳白色钙华长堤横卧湖心，宛若一条蛟龙潜游海底。"];
    Location *Location2 = [[Location alloc]initWithlocationName:@"箭竹海" voice:@""locationImageName:@"箭竹海.jpg" distance:@"1.3KM" locationText:@"箭竹(Arrow Bamboo)是大熊猫喜食的食物，箭竹海(Arrow Bamboo Lake)湖岸四周广有生长，是箭竹海最大的特点，因而得名。箭竹海湖面开阔而绵长，水色碧蓝。倒影历历，直叫人分不清究竟是山入水中还是水浸山上。"];
    Location *Location3 = [[Location alloc]initWithlocationName:@"芦苇海" voice:@""locationImageName:@"芦苇海.jpg" distance:@"1.4KM" locationText:@"“芦苇海”海拔2140米，全长2.2公里，是一个半沼泽湖泊。海中芦苇丛生，水鸟飞翔，清溪碧流，漾绿摇翠，蜿蜒空行，好一派泽国风光。“芦苇海”中，荡荡芦苇，一片青葱，微风徐来，绿浪起伏。飒飒之声，委婉抒情，使人心旷神怡。"];
    Location *Location4 = [[Location alloc]initWithlocationName:@"双龙海" voice:@""locationImageName:@"双龙海.jpg" distance:@"1.5KM" locationText:@"“双龙海”在火花海瀑布下的树丛中。海中有两条带状的生物钙华礁堤隐隐潜伏于海底，活像两条蛟龙藏于海中，蠕蠕欲动。还有一个黑龙与白龙打斗的传说。那条白龙本是双龙海的守护神，黑龙是天将，黑龙因触犯天条，被玉帝贬下界，在双龙海与白龙夺龙王大权……"];
    DataSingleton* dataSL = [DataSingleton shareInstance];
    dataSL.allDetail = @[Location1,Location2,Location3,Location4];
    self.dataArr = @[Location1,Location2,Location3,Location4];
}

//结束代理
- (void) onCompleted:(IFlySpeechError *) error{}
//合成开始
- (void) onSpeakBegin{}
//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg{} //合成播放进度
- (void) onSpeakProgress:(int) progress{}


//控制行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.dataArr.count;
}
//控制每一行样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    NSLog(@"path");
    static NSString *cellIdentifier = @"LocationInfoCell";
    LocationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"LocationInfoCell" owner:nil options:nil].lastObject;
        
        [cell setImageViewClickBlock:^(UIButton *btn,NSString *locationName,NSString* img,NSString* locationText) {
            DetailViewController *deVC = [[DetailViewController alloc]init];
//          self.deVC = [[DetailViewController alloc]init];
            deVC.titleText = locationName;
            deVC.detailImg = img;
            deVC.detailText = locationText;
            [self.navigationController pushViewController:deVC animated:YES];
        }];
        
//        cell = [[NSBundle mainBundle] loadNibNamed:@"LocationInfoCell" owner:nil options:nil].lastObject;
        Location *currentLocation =self.dataArr[indexPath.row];
//        CellFrameInfo *currentFrameInfo = [[CellFrameInfo alloc]initWithStudent:currentStudent];
        [cell setCellData:currentLocation];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 189;
}
//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailViewController *detailViewController = [[DetailViewController alloc]init];
    [self.navigationController pushViewController:detailViewController animated:YES ];
    
}

- (void)leftBtnDidClick:(UIButton *)leftBtn{
    NSLog(@"HOME leftBtnDidClick");
    
    MapViewController *mapViewController;
    mapViewController = [[MapViewController alloc]init];
    mapViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    mapViewController.titleText = self.navigationBar.titleLabel.text;
    [self presentViewController:mapViewController animated:YES completion:nil];

}

- (void)rightBtnDidClick:(UIButton *)rightBtn{
    SetingViewController *setingVC = [[SetingViewController alloc]init];
    [self.navigationController pushViewController:setingVC animated:YES];
//    [self.navigationController pushViewController:setingVC animated:YES ];
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
