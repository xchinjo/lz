program project28;

{$mode objfpc}{$H+}

uses
{$define ONLYUSEHTTPSOCKET}
{$IFDEF UNIX}
cthreads,
{$ENDIF}
  Classes, SysUtils, CustApp,
  mORMot,SynDBODBC,mORMotDB,mORMotSQLite3,SynSQLite3,
  SynCommons,SynDB,
  SynLog,
  SynCrtSock,
  mORMotHttpServer,
  RESTData,
  RESTServerClass, MobileClass, RESTModel;

type

  TRemoteSQLEngine = (rseOleDB, rseODBC, rseOracle, rseSQlite3, rseJet, rseMSSQL);







  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

var ORMServer: TNoteServer;
    aRestServer: TSQLRestServerDB;
    HTTPServer: TSQLHttpServer;
    aProps: TODBCConnectionProperties;     //  ln -s /usr/lib64/libodbc.so.2 /usr/lib64/libodbc.so.1
    aModel: TSQLModel;
    aHttpServer: TSQLHttpServer;


{ TMyApplication }

procedure TMyApplication.DoRun;
//var
//  ErrorMsg: String;
begin

  {
  // set logging abilities
  SQLite3Log.Family.Level := LOG_VERBOSE;
  //SQLite3Log.Family.EchoToConsole := LOG_VERBOSE;
  SQLite3Log.Family.PerThreadLog := ptIdentifiedInOnFile;
  }



  //aProps := TODBCConnectionProperties.Create('','Driver=PostgreSQL Unicode'+
  //    {$ifdef CPU64}'(x64)'+{$endif}';Database=postgres;'+
  //    'Server=localhost;Port=5433;UID=postgres;Pwd=postgresPassword','','');

  {
  aProps := TODBCConnectionProperties.Create('','Driver=MySQL'+
        ';Database=SAM;'+
        'Server=124.109.2.164;Port=3307;USER=insysc;Password=insysc1234567890*','','');
        }


   {$IFDEF UNIX}
   // for linux
   aProps := TODBCConnectionProperties.Create('','Driver=MySQL'+
   //aProps := TODBCConnectionProperties.Create('','MySQL'+
         ';Database=SAM;'+
         'Server=rootcode.info;Port=3306;USER=jono;Password=P@ssw0rd123','','');
   {$ELSE}
    // for win

//   aProps := TODBCConnectionProperties.Create('','Driver=MySQL ODBC 3.51 Driver'+
   aProps := TODBCConnectionProperties.Create('','Driver=MySQL ODBC 5.3 Unicode Driver'+
   //aProps := TODBCConnectionProperties.Create('','MySQL'+
         ';Database=SAM;'+
         'Server=rootcode.info;Port=3306;USER=abcsoft;Password=1Qaz2Wsx3Qwe','','');
   {$ENDIF}

    {


     }


  //aProps.ThreadingMode := tmMainConnection; // as expected for FB embedded

  {
  try
    // get the shared data model
    aModel := DataModel;
    // use PostgreSQL database for all tables
    VirtualTableExternalRegisterAll(aModel,aProps);
    try
      // create the main mORMot server
      aRestServer := TSQLRestServerDB.Create(aModel,':memory:',false); // authentication=false
      try
        // optionally execute all PostgreSQL requests in a single thread
        aRestServer.AcquireExecutionMode[execORMGet] := amBackgroundORMSharedThread;
        aRestServer.AcquireExecutionMode[execORMWrite] := amBackgroundORMSharedThread;
        // create tables or fields if missing
        aRestServer.CreateMissingTables;
        // serve aRestServer data over HTTP
        aHttpServer := TSQLHttpServer.Create(SERVER_PORT,[aRestServer]);
        //aHttpServer := TSQLHttpServer.Create(SERVER_PORT,[aRestServer],'+',useHttpApiRegisteringURI);
        try
          aHttpServer.AccessControlAllowOrigin := '*'; // allow cross-site AJAX queries
          writeln('Background server is running.'#10);
          write('Press [Enter] to close the server.');
          readln;
        finally
          aHttpServer.Free;
        end;
      finally
        aRestServer.Free;
      end;
    finally
      aModel.Free;
    end;
  finally
    aProps.Free;
  end;
  }




  try

    with TSQLLog.Family do begin
        Level := LOG_VERBOSE;
        EchoToConsole := LOG_VERBOSE; // log all events to the console
        PerThreadLog := ptIdentifiedInOnFile;
        NoFile:=true;
    end;
      // manual switch to console mode
     //AllocConsole;
     TextColor(ccLightGray); // needed to noti


    // get the shared data model
    aModel := DataModel;
    // use PostgreSQL database for all tables
    //VirtualTableExternalRegisterAll(aModel,aProps);
    //VirtualTableExternalRegister(aModel, TPerson, aProps, 'sam.Person');
    //VirtualTableExternalRegisterAll(aModel, aProps, false);
    VirtualTableExternalRegisterAll(aModel,aProps,[regMapAutoKeywordFields]); //[regMapAutoKeywordFields]



    try
      // create the main mORMot server
//      aRestServer := TSQLRestServerDB.Create(aModel,':memory:',false); // authentication=false
      //aRestServer := TSQLRestServerDB.Create(aModel,SQLITE_MEMORY_DATABASE_NAME,false); // authentication=false
      //aMobile := TMobileClass.Create(aProps);
      aRestServer := TSQLRestServerDB.Create(aModel,SQLITE_MEMORY_DATABASE_NAME,false); //TSQLRestServerDB



      try
       //aModel.Props[TPerson].ExternalDB.MapField('ID','IdPerson');
       aModel.Props[TSQLINVM_PROD].ExternalDB.MapField('ID','PRDRUN');
        // optionally execute all PostgreSQL requests in a single thread
        //aRestServer.AcquireExecutionMode[execORMGet] := amBackgroundORMSharedThread;
        //aRestServer.AcquireExecutionMode[execORMWrite] := amBackgroundORMSharedThread;
        // create tables or fields if missing
        aRestServer.CreateMissingTables;


        // serve aRestServer data over HTTP
        //aHttpServer := TSQLHttpServer.Create(SERVER_PORT,[aRestServer]);
         aHttpServer := TSQLHttpServer.Create('8880',[aRestServer]); //useHttpApiRegisteringURI
         //aHttpServer := TSQLHttpServer.Create('8880',[aRestServer],'+',useHttpApiRegisteringURI); //useHttpApiRegisteringURI
        try
          aHttpServer.AccessControlAllowOrigin := '*'; // allow cross-site AJAX queries
          writeln('Background server is running.'#10);
          write('Press [Enter] to close the server.');
          readln;
        finally
          aHttpServer.Free;
        end;
      finally
        aRestServer.Free;
      end;
    finally
      aModel.Free;
    end;
  finally
    aProps.Free;
  end;



  {

  // get the shared data model
  aModel := DataModel;

  VirtualTableExternalRegisterAll(aModel,aProps,[regMapAutoKeywordFields]); //[regMapAutoKeywordFields]

  aRestServer := TSQLRestServerDB.Create(aModel,SQLITE_MEMORY_DATABASE_NAME,false); //TSQLRestServerDB
  aRestServer.CreateMissingTables;

  ORMServer := TNoteServer.Create(ExeVersion.ProgramFilePath+'data','root');
  try
    TSQLLog.Family.EchoToConsole := LOG_VERBOSE;
    HTTPServer := TSQLHttpServer.Create(HTTP_PORT,[ORMServer]);
    try
      sleep(300); // let the HTTP server start (for the console log refresh)
      writeln(#13#10'Background server is running at http://localhost:'+HTTP_PORT+''#13#10+
              #13#10'Press [Enter] to close the server.');
      ConsoleWaitForEnterKey;
      Terminate;
    finally
      HTTPServer.Free;
    end;
  finally
    ORMServer.Free;
  end;

  }


  {
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  readln;

  // stop program loop
  Terminate;
  }
end;

constructor TMyApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMyApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TMyApplication.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TMyApplication;
begin
  Application:=TMyApplication.Create(nil);
  Application.Title:='My Application';
  Application.Run;
  Application.Free;
end.

