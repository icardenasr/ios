//
//  NubeLoginViewController.m
//  Owncloud iOs Client
//
//  Created by Israel Cardenas on 14/6/16.
//
//

#import "NubeLoginViewController.h"

#import "constants.h"
#import "UtilsDtos.h"
#import "UtilsUrls.h"
#import "OCCommunication.h"
#import "OCErrorMsg.h"
#import "UtilsFramework.h"
#import "UtilsCookies.h"
#import "ManageUsersDB.h"
#import "ManageFilesDB.h"
#import "ManageCookiesStorageDB.h"

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

#define k_http_prefix @"http://"
#define k_https_prefix @"https://"
#define k_remove_to_suffix @"/index.php"
#define k_remove_to_contains_path @"/index.php/apps/"

// Constantes para las URLs del servicio
#define kOwncloudUrl @"http://10.240.240.18/owncloud/"
#define kTermsUrl @"https://correo.juntadeandalucia.es/ayuda/index.html#/term_nube"


@interface NubeLoginViewController ()

@end

@implementation NubeLoginViewController

@synthesize scrollview;
@synthesize appNameLabel;
@synthesize userTextField, passwordTextField;
@synthesize aiview;
@synthesize connectButton, termsButton;
@synthesize user, password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        urlEditable = YES;
        userNameEditable = YES;
        isSSLAccepted = YES;
        isErrorOnCredentials = NO;
        isError500 = NO;
        isCheckingTheServerRightNow = NO;
        isConnectionToServer = NO;
        isNeedToCheckAgain = YES;
        hasInvalidAuth = NO;
        isHttpsSecure = NO;
        isLoginRightNow = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Inicialmente el indicador de actividad esta oculto
    [self.aiview stopAnimating];
    
    if (IS_IPHONE_6P) {
        // iPhone 6 Plus
        self.appNameLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:46];
        self.userTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.passwordTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.connectButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:32]];
        [self.termsButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:22]];
    } else if (IS_IPHONE_6) {
        // iPhone 6
        self.appNameLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:46];
        self.userTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.passwordTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.connectButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:32]];
        [self.termsButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:22]];
    } else if (IS_IPHONE) {
        // iPhone 4 y 5
        self.appNameLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:42];
        self.userTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.passwordTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.connectButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:30]];
        [self.termsButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:18]];
    } else {
        // iPad
        self.appNameLabel.font = [UIFont fontWithName:@"NewsGotT-Regu" size:76];
        self.userTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        self.passwordTextField.font = [UIFont fontWithName:@"NewsGotT-Regu" size:20];
        [self.connectButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:34]];
        [self.termsButton.titleLabel setFont:[UIFont fontWithName:@"NewsGotT-Regu" size:22]];
    }
    
    // Registro de las notificaciones de mostrar y ocultar el teclado
    [self registerForKeyboardNotifications];
    
    // Delegate de los EditText
    [self.userTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
    
    // Cierre del teclado al pulsar sobre la vista general
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Configuracion de delegados de Owncloud
    ((CheckAccessToServer *)[CheckAccessToServer sharedManager]).delegate = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Metodo para ocultar el teclado
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

// Dejamos que esta pantalla unicamente admita rotacion en iPad - En iPhone esta pantalla no rota
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) {
        return YES;
    } else {
        return YES;
    }
}

// Only for ios 6
- (BOOL)shouldAutorotate {
    if (IS_IPAD) {
        return YES;
    } else {
        return YES;
    }
}

// Metodo que registra la pantalla actual para escuchar las notificaciones de mostrar y ocultar el teclado
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Metodo que se ejecuta cuando el teclado es mostrado
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollview.contentInset = contentInsets;
    scrollview.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, userTextField.frame.origin) || !CGRectContainsPoint(aRect, passwordTextField.frame.origin)) {
        if (IS_IPAD) {
            //CGPoint scrollPoint = CGPointMake(0.0, userTextField.frame.origin.y-kbSize.height);
            CGPoint scrollPoint = CGPointMake(0.0, 200.0);
            [scrollview setContentOffset:scrollPoint animated:YES];
        } else {
            CGPoint scrollPoint = CGPointMake(0.0, 200.0);
            [scrollview setContentOffset:scrollPoint animated:YES];
        }
    }
}

// Metodo que se ejecuta cuando el teclado es ocultado
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollview.contentInset = contentInsets;
    scrollview.scrollIndicatorInsets = contentInsets;
}

// Metodo que elimina los espacios en blanco de los extremos de una cadena de texto
- (NSString*)trimString:(NSString *)inputString {
    NSRange range = [inputString rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    NSString *result = [inputString stringByReplacingCharactersInRange:range withString:@""];
    return result;
}

// Metodo que permite deshabilitar los controles de la pantalla
- (void)disableControls {
    [self.connectButton setUserInteractionEnabled:NO];
    [self.termsButton setUserInteractionEnabled:NO];
    [self.userTextField setUserInteractionEnabled:NO];
    [self.passwordTextField setUserInteractionEnabled:NO];
}

// Metodo que permite habilitar los controles de la pantalla
- (void)enableControls {
    [self.connectButton setUserInteractionEnabled:YES];
    [self.termsButton setUserInteractionEnabled:YES];
    [self.userTextField setUserInteractionEnabled:YES];
    [self.passwordTextField setUserInteractionEnabled:YES];
}

// Metodo de accion para comenzar la conexion con el servidor
- (IBAction)connectWithServer:(id)sender {
    [self dismissKeyboard];
    
    // Deshabilitamos los controles temporalmente
    [self disableControls];
    // Mostramos el indicador de actividad
    [self.aiview startAnimating];
    
    // Validacion de parametros
    user = [self trimString:userTextField.text];
    password = passwordTextField.text;
    if ([user isEqualToString:@""]) {
        // Mostramos el error
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Usuario vacío"
                                                       message: @"Introduzca su usuario (sin @juntadeandalucia.es) y contraseña del Correo Corporativo"
                                                      delegate: self
                                             cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                             otherButtonTitles:nil,nil];
        [alert show];
        // Ocultamos el indicador de actividad
        [self.aiview stopAnimating];
        // Habilitamos los controles
        [self enableControls];
    } else if ([password isEqualToString:@""]) {
        // Mostramos el error
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Contraseña vacía"
                                                       message: @"Introduzca su usuario (sin @juntadeandalucia.es) y contraseña del Correo Corporativo"
                                                      delegate: self
                                             cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                             otherButtonTitles:nil,nil];
        [alert show];
        // Ocultamos el indicador de actividad
        [self.aiview stopAnimating];
        // Habilitamos los controles
        [self enableControls];
    } else {
        // Se han introducido ambos valores
        isUserTextUp = YES;
        isPasswordTextUp = YES;
        // Detectamos si el usuario termina en "juntadeandalucia.es" para quitarlo
        NSString *domainSuffixLow = @"@juntadeandalucia.es";
        NSString *domainSuffixUp = @"@JUNTADEANDALUCIA.ES";
        if ( [user hasSuffix:domainSuffixLow] ||
            [user hasSuffix:domainSuffixUp] ) {
            user = [user substringToIndex:(user.length-domainSuffixLow.length)];
        }
        
        // Chequeamos que se llega al servidor
        isCheckingTheServerRightNow = YES;
        isLoginRightNow = YES;
        [[CheckAccessToServer sharedManager] isConnectionToTheServerByUrl:kOwncloudUrl];
    }
}

// Metodo de accion para mostrar los terminos de uso
- (IBAction)showTerms:(id)sender {
    [self dismissKeyboard];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTermsUrl]];
}


#pragma mark - UITextField Delegate Methods

// Metodo que se ejecuta cuando se pulsa ENTER en cualquiera de los TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userTextField) {
        [textField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
    } else if (textField == passwordTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}


#pragma mark - CheckAccessToServer Delegate Methods

// Metodo que actualiza la variable global _connectString utilizada en muchos sitios
- (void) updateConnectString{
    NSString *connectURL =[NSString stringWithFormat:@"%@%@", kOwncloudUrl, k_url_webdav_server];
    _connectString=connectURL;
}

// Metodo que chequea la seguridad del protocolo de conexion al servidor
- (void) checkTheSecurityOfTheRedirectedURL: (NSHTTPURLResponse *)response {
    DLog(@"checkTheSecurityOfTheRedirectedURL");
    //Check the security of the redirection
    NSURL *redirectionURL = response.URL;
    NSString *redirectionURLString = [redirectionURL absoluteString];
    
    if (isHttps) {
        if ([redirectionURLString hasPrefix:k_https_prefix]) {
            isHttpsSecure = YES;
        } else {
            isHttpsSecure = NO;
        }
    }
}

// Metodo que es llamado cuando la aplicacion sabe si el servidor esta conectado o no
-(void)connectionToTheServer:(BOOL)isConnection {
    DLog(@"connectionToTheServer");
    hasInvalidAuth = NO;
    if (isConnection) {
        [self checkIfServerAutentificationIsNormalFromURL];
    } else {
        // Update the interface
        [self updateInterfaceWithConnectionToTheServer:isConnection];
    }
}

// Metodo que se utiliza para comprobar si la autenticacion del servidor es normal
- (void)checkIfServerAutentificationIsNormalFromURL {
    DLog(@"checkIfServerAutentificationIsNormalFromURL");
    
    //Update connect string
    [self updateConnectString];
    
    // Empty username and password to get a fail response to the server
    NSString *userFail = @"";
    NSString *passFail = @"";
    
    [[AppDelegate sharedOCCommunication] setCredentialsWithUser:userFail andPassword:passFail];
    [[AppDelegate sharedOCCommunication] setUserAgent:[UtilsUrls getUserAgent]];
    [[AppDelegate sharedOCCommunication] checkServer:_connectString onCommunication:[AppDelegate sharedOCCommunication] successRequest:^(NSHTTPURLResponse *response, NSString *redirectedServer) {
        
        BOOL isInvalid = NO;
        isLoginButtonEnabled = YES;
        
        // Update the interface depend of if isInvalid or not
        if (isInvalid) {
            hasInvalidAuth = YES;
            isLoginButtonEnabled = NO;
        } else {
            hasInvalidAuth = NO;
        }
        
        [self checkTheSecurityOfTheRedirectedURL:response];
        
        [self updateInterfaceWithConnectionToTheServer:YES];
    } failureRequest:^(NSHTTPURLResponse *response, NSError *error, NSString *redirectedServer) {
        
        BOOL isInvalid = NO;
        
            //Get header related with autentication type
            NSString *autenticationType = [[response allHeaderFields] valueForKey:@"Www-Authenticate"];
            
            if (autenticationType) {
                //Autentication type basic
                if ([autenticationType hasPrefix:@"Basic"]) {
                    isInvalid = NO;
                } else if ([autenticationType hasPrefix:@"Bearer"]) {
                    isInvalid = YES;
                } else {
                    //Unknown autentication type
                    isInvalid = YES;
                }
            } else {
                //The server not return a Www-Authenticate header
                isInvalid = YES;
            }
        
        //Update the interface depend of if isInvalid or not
        if (isInvalid) {
            hasInvalidAuth = YES;
        } else {
            hasInvalidAuth = NO;
        }
        
        [self checkTheSecurityOfTheRedirectedURL:response];
        
        [self updateInterfaceWithConnectionToTheServer:YES];
    }];
}

// Metodo que tiene en cuenta la conexion que se ha comprobado con el servidor
-(void)updateInterfaceWithConnectionToTheServer:(BOOL)isConnection {
    DLog(@"updateInterfaceWithConnectionToTheServer");
    
    if (isConnection) {
        isConnectionToServer = YES;
        isLoginButtonEnabled = YES;
    } else {
        isConnectionToServer = NO;
        isLoginButtonEnabled = NO;
    }
    
    if (isNeedToCheckAgain && !isConnectionToServer) {
        isNeedToCheckAgain = NO;
        isLoginButtonEnabled = NO;
        
        if (isConnection) {
            isConnectionToServer = YES;
            isLoginButtonEnabled = YES;
        } else {
            isConnectionToServer = NO;
            isLoginButtonEnabled = NO;
        }
    }
    
    if (isConnectionToServer) {
        // Hay conexion con el servidor - Continuamos
        [self goTryToDoLogin];
    } else {
        // No hay conexion con el servidor - Mostramos error
        if (isLoginRightNow) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Sin conexión"
                                                           message: @"No hay conexión con el servidor. Por favor, confirme que dispone de conexión y vuelva a probar otra vez"
                                                          delegate: self
                                                 cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                 otherButtonTitles:nil,nil];
            [alert show];
            // Ocultamos el indicador de actividad
            [self.aiview stopAnimating];
            // Habilitamos los controles
            [self enableControls];
            // Desactivamos el proceso de login
            isLoginRightNow = NO;
        }
    }
    
    isCheckingTheServerRightNow = NO;
    isNeedToCheckAgain = YES;
}

// Metodo que repite el chequeo de conexion sobre el servidor
-(void)repeatTheCheckToTheServer {
    DLog(@"repeatTheCheckToTheServer");
    [self isConnectionToTheServerByUrlInOtherThread];
}

// Metodo que vuelve a intentar comprobar la conexion con el servidor
-(void) isConnectionToTheServerByUrlInOtherThread {
    DLog(@"isConnectionToTheServerByUrlInOtherThread");
    isCheckingTheServerRightNow = YES;
    isConnectionToServer = NO;
    
    [[CheckAccessToServer sharedManager] isConnectionToTheServerByUrl:kOwncloudUrl];
}

// Metodo que
-(void) checkLogin {
    [self updateConnectString];
    
    [UtilsFramework deleteAllCookies];
    [UtilsCookies eraseURLCache];
    [UtilsCookies eraseCredentialsWithURL:self.connectString];
    
    [self performSelector:@selector(connectToServer) withObject:nil afterDelay:0.5];
}

// Metodo que realiza la peticion al servidor WebDAV para hacer el login y obtener la carpeta raiz
- (void) connectToServer {
    
    [[AppDelegate sharedOCCommunication] setCredentialsWithUser:user andPassword:password];
    [[AppDelegate sharedOCCommunication] setUserAgent:[UtilsUrls getUserAgent]];
    [[AppDelegate sharedOCCommunication] readFolder:_connectString withUserSessionToken:nil onCommunication:[AppDelegate sharedOCCommunication] successRequest:^(NSHTTPURLResponse *response, NSArray *items, NSString *redirectedServer, NSString *token){
        if (!redirectedServer){
            // Pass the items with OCFileDto to FileDto Array
            NSMutableArray *directoryList = [UtilsDtos passToFileDtoArrayThisOCFileDtoArray:items];
            [self createUserAndDataInTheSystemWithRequest:directoryList andCode:response.statusCode];
        }
    } failureRequest:^(NSHTTPURLResponse *response, NSError *error, NSString *token, NSString *redirectedServer) {
        
        DLog(@"error: %@", error);
        DLog(@"Operation error: %ld", (long)response.statusCode);
        
        // Desactivamos el login
        isLoginRightNow = NO;
        
        switch (response.statusCode) {
            case kOCErrorServerUnauthorized:
                // Unauthorized (bad username or password)
                [self errorLogin];
                break;
            case kOCErrorServerForbidden:
                // 403 Forbidden
                [self manageFailOfServerConnection];
                break;
            case kOCErrorServerPathNotFound:
                // 404 Not Found. When for example we try to access a path that now not exist
                [self manageFailOfServerConnection];;
                break;
            case kOCErrorServerTimeout:
                // 408 timeout
                [self manageFailOfServerConnection];
                break;
            default:
                [self manageFailOfServerConnection];
                break;
        }
    }];
}

// Metodo que se encarga de gestionar un error de usuario o password
-(void) errorLogin {
    DLog(@"Error login");
    isErrorOnCredentials = YES;
    // Mostramos el error
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Credenciales incorrectas"
                                                   message: @"Introduzca su usuario (sin @juntadeandalucia.es) y contraseña del Correo Corporativo"
                                                  delegate: self
                                         cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                         otherButtonTitles:nil,nil];
    [alert show];
    // Ocultamos el indicador de actividad
    [self.aiview stopAnimating];
    // Habilitamos los controles
    [self enableControls];
}

// Metodo que se encarga de gestionar un error general en la autenticacion y conexion con el servidor
- (void) manageFailOfServerConnection {
    // Mostramos el error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"not_possible_connect_to_server", nil)
                                                    message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
    [alert show];
    // Ocultamos el indicador de actividad
    [self.aiview stopAnimating];
    // Habilitamos los controles
    [self enableControls];
}

// Metodo que se llama cuando la aplicacion recibe los datos tras la autenticacion
-(void)createUserAndDataInTheSystemWithRequest:(NSArray *)items andCode:(NSInteger) requestCode {
    // Desactivamos el login
    isLoginRightNow = NO;
    
    if(requestCode >= 400) {
        // Avisamos del error
        isError500 = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Error del servidor"
                                                       message: @"El servidor ha respondido con un error desconocido. Por favor, inténtelo de nuevo más tarde"
                                                      delegate: self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil,nil];
        [alert show];
        // Ocultamos el indicador de actividad
        [self.aiview stopAnimating];
        // Habilitamos los controles
        [self enableControls];
    } else {
        UserDto *userDto = [[UserDto alloc] init];
        userDto.url = kOwncloudUrl;
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        NSString *userNameUTF8 = user;
        NSString *passwordUTF8 = password;
        
        userDto.username = userNameUTF8;
        userDto.password = passwordUTF8;
        userDto.ssl = isHttps;
        userDto.activeaccount = YES;
        userDto.urlRedirected = app.urlServerRedirected;
        
        [ManageUsersDB insertUser:userDto];
        
        app.activeUser=[ManageUsersDB getActiveUser];
        
        NSMutableArray *directoryList = [NSMutableArray arrayWithArray:items];
        
        //Change the filePath from the library to our db format
        for (FileDto *currentFile in directoryList) {
            currentFile.filePath = [UtilsUrls getFilePathOnDBByFilePathOnFileDto:currentFile.filePath andUser:app.activeUser];
        }
        
        DLog(@"The directory List have: %ld elements", (unsigned long)directoryList.count);
        
        DLog(@"Directoy list: %@", directoryList);
        
        [ManageFilesDB insertManyFiles:directoryList andFileId:0];
        
        // Generate the app interface
        [app generateAppInterfaceFromLoginScreen:YES];
    }
}

// Metodo que inicia el proceso de autenticacion tras comprobar la conexion con el servidor
-(void)goTryToDoLogin {
    DLog(@"goTryToDoLogin");
    DLog(@"user: %@ | pass: %@", user, password);
    
    isError500 = NO;
    
    [self checkLogin];
}

#pragma mark - Cookies support

// Metodo que restaura las cookies del usuario activo
- (void) restoreTheCookiesOfActiveUser {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //1- Clean the cookies storage
    [UtilsFramework deleteAllCookies];
    //2- We restore the previous cookies of the active user on the System cookies storage
    [UtilsCookies setOnSystemStorageCookiesByUser:app.activeUser];
    //3- We delete the cookies of the active user on the databse because it could change and it is not necessary keep them there
    [ManageCookiesStorageDB deleteCookiesByUser:app.activeUser];
}




@end
