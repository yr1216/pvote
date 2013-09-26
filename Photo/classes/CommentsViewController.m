//
//  CommentsViewController.m
//  Photo
//
//  Created by wangsh on 13-9-26.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "CommentsViewController.h"
#import <arcstreamsdk/STreamQuery.h>
#import <arcstreamsdk/STreamObject.h>
#import "ImageCache.h"
#import "MBProgressHUD.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
@interface CommentsViewController ()
{
    NSString *leftImageId;
    NSString *rightImageId;
    UITextView *contentsView;
    NSArray *allKeys;
    NSMutableArray *userNameArray;
    NSMutableArray *contentsArray;
}
@end

@implementation CommentsViewController
@synthesize oneImageView;
@synthesize twoImageView;
@synthesize rowObject;
@synthesize headImageView;
@synthesize nameLable;
@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    leftImageId = [rowObject getValue:@"file1"];
    rightImageId = [rowObject getValue:@"file2"];
    userNameArray = [[NSMutableArray alloc]init];
    contentsArray = [[NSMutableArray alloc]init];
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.tag =TABLEVIEWTAG;
    myTableView.separatorStyle=YES;//UITableView每个cell之间的默认分割线隐藏掉sel
    [self.view addSubview:myTableView];

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"读取中...";
    [self.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(loadComments) onTarget:self withObject:nil animated:YES];
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
    toolBar.backgroundColor= [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
    toolBar.tag = TOOLBARTAG;
    [self.view addSubview:toolBar];
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    
    contentsView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 250, 40)];
    contentsView.delegate = self;
    contentsView.font = [UIFont systemFontOfSize:18.0f];
    UIBarButtonItem * contentsItem = [[UIBarButtonItem alloc] initWithCustomView:contentsView];
    
    UIButton * senderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    senderButton.frame = CGRectMake(250, 0, 50, 40);
    [senderButton setTitle:@"发送" forState:UIControlStateNormal];
    [senderButton addTarget:self action:@selector(senderClicker) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * senderItem = [[UIBarButtonItem alloc] initWithCustomView:senderButton];
    
    [array addObject:contentsItem];
    [array addObject:senderItem];
    toolBar.items = array;
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}
- (void)loadComments{
    STreamObject *test = [[STreamObject alloc] init];
    [test setObjectId:[rowObject objectId]];
    [test loadAll:[rowObject objectId]];
    allKeys = [test getAllKeys];
    if ([allKeys count]!=0 ) {
        for (NSString *key in allKeys){
            
            NSMutableDictionary *comme = [test getValue:key];
            NSEnumerator *con = [comme keyEnumerator];
            NSString *dicKey = [con nextObject];
            if (dicKey){
                NSString *contents  = [comme objectForKey:dicKey];
                NSLog(@"%@", contents);
                [contentsArray addObject:contents];
                [userNameArray addObject:dicKey];
            }
            NSLog(@"dicKey%@",dicKey);
            
        }

    }
       [myTableView reloadData];
    
}

//创建cell上控件
-(void)createUIControls:(UITableViewCell *)cell withCellRowAtIndextPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        self.oneImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 30, 150, 150)];
        [self.oneImageView setImage:[UIImage imageNamed:@"headImage.jpg"] ];
        [cell addSubview:self.oneImageView];
        
        self.twoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(165, 30, 150, 150)];
        [self.twoImageView setImage:[UIImage imageNamed:@"headImage.jpg"] ];
        [cell addSubview:self.twoImageView];
        
    }else{
        [self getCellHeight:indexPath.row];
        headImageView =  [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 40, 40)];
        [headImageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        [cell addSubview:headImageView];
        
        nameLable = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 100, 30)];
        [cell addSubview:nameLable];
        
        contentView =[[UITextView alloc]initWithFrame:CGRectMake(60, 30, 260, [self getCellHeight:indexPath.row])];
        contentView.delegate = self;
        contentView.font = [UIFont systemFontOfSize:15];
        contentView.backgroundColor = [UIColor clearColor];
        [cell addSubview:contentView];
       
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [allKeys count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
        backgrdView.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:242.0/255.0 blue:230.0/255.0 alpha:1.0];
        cell.backgroundView = backgrdView;
        
        [self createUIControls:cell withCellRowAtIndextPath:indexPath];
    }
    ImageCache *cache = [ImageCache sharedObject];
    ImageDataFile *dataFile = [cache getImages:[rowObject objectId]];
    self.oneImageView.image = [UIImage imageWithData:[dataFile file1]];
    self.twoImageView.image = [UIImage imageWithData:[dataFile file2]];
    if (indexPath.row !=0) {
        nameLable.text = [userNameArray objectAtIndex:indexPath.row-1];
        contentView.text = [contentsArray objectAtIndex:indexPath.row-1];
        NSMutableDictionary *userMetaData = [cache getUserMetadata:[userNameArray objectAtIndex:indexPath.row-1]];
        NSString *pImageId = [userMetaData objectForKey:@"profileImageId"];
        if ([cache getImage:pImageId]){
            headImageView.image = [UIImage imageWithData:[cache getImage:pImageId]];
        }else{
            [headImageView setImage:[UIImage imageNamed:@"headImage.jpg"]];
        }
    }
    return cell;
}
-(CGFloat)getCellHeight:(NSInteger)row
{
    // 列寬
    CGFloat contentWidth =self.view.frame.size.width-85;
    CGFloat height = 0.0;
    // 设置字体
    UIFont *font = [UIFont systemFontOfSize:15];
    
    if (contentsArray.count != 0) {
      
        // 显示的内容
        NSString *content = [contentsArray objectAtIndex:row-1];
        
        // 计算出显示完內容需要的最小尺寸
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 3000)];
        
        
        if (size.height<30) {
            height = 60;
        }else
        {
            height = size.height+60;//40
        }
    }
    
    // 返回需要的高度
    return height;
    
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 200;
    }else{
        return  [self getCellHeight:indexPath.row];
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(void)senderClicker{
    
    ImageCache *cache = [ImageCache sharedObject];
    NSDate *now = [[NSDate alloc] init];
    long millionsSecs = [now timeIntervalSince1970];
    NSString *longValue = [NSString stringWithFormat:@"%lu", millionsSecs];
    STreamObject *comment = [[STreamObject alloc] init];
    [comment setObjectId:[rowObject objectId]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:contentsView.text forKey:[cache getLoginUserName]];
    [comment addStaff:longValue withObject:dic];
    [comment update];
    contentsView.text = @"";
    [contentsView resignFirstResponder];
}


-(void) autoMovekeyBoard: (float) h{
    
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-40.0), 320.0f, 40.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, 320.0f,(float)(480.0-h-40.0));
}

#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
   
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:keyboardRect.size.height];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    [self autoMovekeyBoard:0];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
