//
//  ViewController.m
//  downloadProgressBar
//
//  Created by Ravi kumar Yaganti on 24/09/17.
//  Copyright © 2017 Ravi kumar Yaganti. All rights reserved.
//

#import "ViewController.h"
#import "CircleProgressBar.h"

@interface ViewController ()<NSURLSessionDelegate>
@property NSURLSession *session;
@property (nonatomic) CircleProgressBar *circleProgressBar;
@property (weak, nonatomic) UIAlertController *alertController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDownloadProgress];
    });
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:@"https://www.iso.org/files/live/sites/isoorg/files/archive/pdf/en/annual_report_2009.pdf"]];
    [downloadTask resume];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}
-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"downloading : %f",(double)totalBytesWritten/(double)totalBytesExpectedToWrite);
        [_circleProgressBar setProgress:((double)totalBytesWritten/(double)totalBytesExpectedToWrite) animated:YES];
//        _progressBar.progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        double value =(double)totalBytesWritten/(double)totalBytesExpectedToWrite;
        NSLog(@"%f",value);
    });
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)showDownloadProgress
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    _circleProgressBar = [[CircleProgressBar alloc] initWithFrame:CGRectMake(10, 10, 120, 120)];
    _circleProgressBar.center = view.center;
    [view addSubview:_circleProgressBar];
    [_circleProgressBar setHintViewSpacing:5.0f];
    [_circleProgressBar setHintViewBackgroundColor:[UIColor blackColor]];
    [_circleProgressBar setProgressBarProgressColor:[UIColor colorWithRed:0.2 green:0.7 blue:1.0 alpha:0.8]];
    [_circleProgressBar setProgressBarTrackColor:[UIColor greenColor]];

    [[UIApplication sharedApplication].keyWindow addSubview:view];
    view.center = [UIApplication sharedApplication].keyWindow.center;
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
//                                                                   message:@"Please wait\n\n\n"
//                                                            preferredStyle:UIAlertControllerStyleAlert];
    
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    spinner.center = CGPointMake(130.5, 65.5);
//    spinner.color = [UIColor blackColor];
//    [spinner startAnimating];
    [_circleProgressBar setBackgroundColor:[UIColor whiteColor]];
//    [alert.view addSubview:_circleProgressBar];
//    @try {
//        [alert.view setValue:_circleProgressBar forKey:@"contentViewController"];
//    }
//    @catch(NSException *exception) {
//        NSLog(@"Failed setting content view controller: %@", exception);
//    }
//
//    [self presentViewController:alert animated:NO completion:nil];
//
//    self.alertController = [UIAlertController alertControllerWithTitle: @"Loading"
//                                                               message: nil
//                                                        preferredStyle: UIAlertControllerStyleAlert];
//    [self.alertController addAction:[UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];
//    
//    _circleProgressBar = [[CircleProgressBar alloc] initWithFrame:CGRectMake(20, 10, 100, 100)];
////    UIViewController *customVC     = [[UIViewController alloc] init];
////    
////    
////    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
////    [spinner startAnimating];
////    [customVC.view addSubview:spinner];
////    
////    
////    [customVC.view addConstraint:[NSLayoutConstraint
////                                  constraintWithItem: spinner
////                                  attribute:NSLayoutAttributeCenterX
////                                  relatedBy:NSLayoutRelationEqual
////                                  toItem:customVC.view
////                                  attribute:NSLayoutAttributeCenterX
////                                  multiplier:1.0f
////                                  constant:0.0f]];
////    
////    
////    
////    [customVC.view addConstraint:[NSLayoutConstraint
////                                  constraintWithItem: spinner
////                                  attribute:NSLayoutAttributeCenterY
////                                  relatedBy:NSLayoutRelationEqual
////                                  toItem:customVC.view
////                                  attribute:NSLayoutAttributeCenterY
////                                  multiplier:1.0f
////                                  constant:0.0f]];
////    
//    
//    [self.alertController setValue:_circleProgressBar forKey:@"contentViewController"];
//    
//    
//    [self presentViewController: self.alertController
//                       animated: true
//                     completion: nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    //getting application's document directory path
    NSArray * tempArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [tempArray objectAtIndex:0];
    
    //adding a new folder to the documents directory path
    NSString *appDir = [docsDir stringByAppendingPathComponent:@"/Reader/"];
    
    //Checking for directory existence and creating if not already exists
    if(![fileManager fileExistsAtPath:appDir])
    {
        [fileManager createDirectoryAtPath:appDir withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    //retrieving the filename from the response and appending it again to the path
    //this path "appDir" will be used as the target path
    appDir =  [appDir stringByAppendingFormat:@"/%@",[[downloadTask response] suggestedFilename]];
    
    //checking for file existence and deleting if already present.
    if([fileManager fileExistsAtPath:appDir])
    {
        NSLog([fileManager removeItemAtPath:appDir error:&error]?@"deleted":@"not deleted");
    }
    
    //moving the file from temp location to app's own directory
    BOOL fileCopied = [fileManager moveItemAtPath:[location path] toPath:appDir error:&error];
    NSLog(fileCopied ? @"Yes" : @"No");
    
}



@end
