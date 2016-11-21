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
#import "ManageThumbnails.h"
#import "UtilsFramework.h"
#import "UtilsUrls.h"
#import "OCPortraitNavigationViewController.h"
#import "ManageAppSettingsDB.h"

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

#define kHelpUrl @"https://correo.juntadeandalucia.es/ayuda/index.html#/nube/app"
#define kSupportUrl @"https://correo.juntadeandalucia.es/ayuda/index.html#/soporte"


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
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:32]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
    } else if (IS_IPHONE_6) {
        // iPhone 6
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:32]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
    } else if (IS_IPHONE) {
        // iPhone 4 y 5
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:30]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:26]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:26]];
    } else {
        // iPad
        self.desc1Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.desc2Label.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.logoutButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:32]];
        self.passcodeLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.helpButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
        [self.supportButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:28]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // Relaunch the uploads that failed before
    [app performSelector:@selector(relaunchUploadsFailedNoForced) withObject:nil afterDelay:5.0];
    
    self.user = app.activeUser;
    
    self.listUsers = [ManageUsersDB getAllUsers];
    
    // Como debe estar el switch de codigo de acceso
    if(![ManageAppSettingsDB isPasscode]) {
        // No hay condigo configurado - Esta apagado
        [switchPasscode setOn:false];
    } else {
        // Hay codigo configurado - Esta encendido
        [switchPasscode setOn:true];
    }

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

// Metodo para ocultar el teclado
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - Setting Actions

// Metodo de accion para mostrar la ayuda
- (IBAction)showHelp:(id)sender {
    [self dismissKeyboard];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kHelpUrl]];
}

// Metodo de accion para mostrar el soporte
- (IBAction)showSupport:(id)sender {
    [self dismissKeyboard];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSupportUrl]];
}

// Metodo de accion para cambiar la activacion de una clave de acceso
-(IBAction)changeSwitchPasscode:(id)sender {
    
    // Create pass code view controller
    self.vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    self.vc.delegate = self;
    
    // Create the navigation bar of portrait
    OCPortraitNavigationViewController *oc = [[OCPortraitNavigationViewController alloc]initWithRootViewController:_vc];
    
    // Indicate the pass code view mode
    if(![ManageAppSettingsDB isPasscode]) {
        //Set mode
        self.vc.mode = KKPasscodeModeSet;
    } else {
        //Dissable mode
        self.vc.mode = KKPasscodeModeDisabled;
    }
    
    if (IS_IPHONE) {
        //is iphone
        [self presentViewController:oc animated:YES completion:nil];
    } else {
        //is ipad
        // Comentamos el que salga en una ventana para que salga a toda pantalla y se ejecute el metodo viewDidAppear
        /*AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        oc.modalPresentationStyle = UIModalPresentationFormSheet;
        [app.splitViewController presentViewController:oc animated:YES completion:nil];*/
        // Lo sacamos como en iPhone para que salga a toda pantalla
        [self presentViewController:oc animated:YES completion:nil];
    }
}

// Metodo de accion para mostrar la confirmacion de desconectar el usuario
-(IBAction)showDisconnectActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"¿Deseas salir?"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Salir"
                                                    otherButtonTitles:@"Cancelar", nil];
    [actionSheet showInView:self.view];
    actionSheet.tag = 100;
}


#pragma mark - Action Sheet

// Metodo que controla las acciones de las Action Sheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:
                // Salir
                [self disconnectUser];
                break;
            case 1:
                // Cancelar
                break;
        }
    }
}

#pragma mark - Utils

// Metodo que desconecta la sesion del usuario
- (void) disconnectUser {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [[ManageThumbnails sharedManager] deleteThumbnailCacheFolderOfUserId: APP_DELEGATE.activeUser.idUser];
    [ManageUsersDB removeUserAndDataByIdUser: APP_DELEGATE.activeUser.idUser];
    [UtilsFramework deleteAllCookies];
    DLog(@"ID to delete user: %ld", (long)app.activeUser.idUser);
    
    // Delete files os user in the system
    NSString *userFolder = [NSString stringWithFormat:@"/%ld", (long)app.activeUser.idUser];
    NSString *path= [[UtilsUrls getOwnCloudFilePath] stringByAppendingPathComponent:userFolder];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    [self performSelectorInBackground:@selector(cancelAllDownloads) withObject:nil];
    app.uploadArray=[[NSMutableArray alloc]init];
    [app updateRecents];
    [app restartAppAfterDeleteAllAccounts];
}

// Metodo que cancela todas las descargas en curso
- (void) cancelAllDownloads {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.downloadManager cancelDownloads];
    [[AppDelegate sharedSyncFolderManager] cancelAllDownloads];
}


@end
