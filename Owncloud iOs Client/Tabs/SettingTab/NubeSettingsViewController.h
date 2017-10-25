//
//  NubeSettingsViewController.h
//  Owncloud iOs Client
//
//  Created by Israel Cardenas on 17/6/16.
//
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "UserDto.h"
#import "KKPasscodeViewController.h"
#import "AccountCell.h"
#import "SyncFolderManager.h"


@interface NubeSettingsViewController : UIViewController <UIActionSheetDelegate, KKPasscodeViewControllerDelegate> {
    
}

// Propiedades para elementos del interfaz
@property (nonatomic, retain) IBOutlet UILabel *desc1Label;
@property (nonatomic, retain) IBOutlet UILabel *desc2Label;
@property (nonatomic, retain) IBOutlet UIButton *logoutButton;
@property (nonatomic, retain) IBOutlet UILabel *passcodeLabel;
@property (nonatomic, retain) IBOutlet UISwitch *switchPasscode;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;
@property (nonatomic, retain) IBOutlet UIButton *supportButton;

@property(nonatomic, strong)DetailViewController *detailViewController;
@property(nonatomic, strong)UserDto *user;

// App pin
@property (nonatomic,strong) KKPasscodeViewController* vc;

// Metodos de accion
- (IBAction)showHelp:(id)sender;
- (IBAction)showSupport:(id)sender;
- (IBAction)changeSwitchPasscode:(id)sender;
- (IBAction)showDisconnectActionSheet:(id)sender;


@end
