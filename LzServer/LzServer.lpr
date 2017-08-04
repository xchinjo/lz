program LzServer;

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
  SynDBZeos,
  RESTServerClass, MobileClass, RESTModel;

type

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
    //aProps: TODBCConnectionProperties;     //  ln -s /usr/lib64/libodbc.so.2 /usr/lib64/libodbc.so.1

    aProps:TSQLDBZEOSConnectionProperties;
    aModel: TSQLModel;
    aHttpServer: TSQLHttpServer;


{ TMyApplication }

procedure TMyApplication.DoRun;
//var
//  ErrorMsg: String;
begin

   {$IFDEF UNIX}
   // for linux
    aProps := TSQLDBZEOSConnectionProperties.Create('zdbc:firebird-2.5://127.0.0.1:3050//fbdb/sam.fdb?LibLocation=/usr/lib64/libfbclient.so;username=sysdba;password=masterkey','/fbdb/ErpDB.FDB','SYSDBA','masterkey');
   {$ELSE}
    // for win
    //   aProps := TODBCConnectionProperties.Create('','Driver=MySQL ODBC 3.51 Driver'+
   aProps := TODBCConnectionProperties.Create('','Driver=MySQL ODBC 5.3 Unicode Driver'+
   //aProps := TODBCConnectionProperties.Create('','MySQL'+
         ';Database=SAM;'+
         'Server=124.109.2.164;Port=3307;USER=abcsoft;Password=123456','','');
   {$ENDIF}


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
       //aModel.Props[TSQLINVM_PROD].ExternalDB.MapField('ID','PRDRUN');
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

