//
//  NubeSettingsViewController.m
//  Owncloud iOs Client
//
//  Created by Israel Cardenas on 17/6/16.
//
//

#import "NubeSettingsViewController.h"

#import "ManageUsersDB.h"
#import "InstantUpload.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define kTermsUrl @"https://correo.juntadeandalucia.es/ayuda/index.html#/term_consigna"


@interface NubeSettingsViewController () <InstantUploadDelegate>

@property (nonatomic, strong) NSMutableArray *listUsers;

@end

@implementation NubeSettingsViewController

@synthesize desc1Label, desc2Label;
@synthesize logoutButton;
@synthesize passcodeLabel, switchPasscode;
@synthesize helpButton, supportButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"settings", nil);
    
    [InstantUpload instantUploadManager].delegate = self;
    
    if (IS_IPHONE_6P) {
        // iPhone 6 Plus
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:25]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:20]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:20]];
    } else if (IS_IPHONE_6) {
        // iPhone 6
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:25]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:20]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:20]];
    } else if (IS_IPHONE) {
        // iPhone 4 y 5
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:32]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
    } else {
        // iPad
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:25]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:17];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:20]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:20]];
    }

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // Relaunch the uploads that failed before
    [app performSelector:@selector(relaunchUploadsFailedNoForced) withObject:nil afterDelay:5.0];
    
    self.user = app.activeUser;
    
    self.listUsers = [ManageUsersDB getAllUsers];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Evitamos la rotacion en esta pantalla concreta
- (BOOL)shouldAutorotate {
    return NO;
}


#pragma mark - Setting Actions




@end
