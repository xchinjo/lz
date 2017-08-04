program sam001;

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







  // get the shared data model
  aModel := DataModel;

 // VirtualTableExternalRegisterAll(aModel,aProps,[regMapAutoKeywordFields]); //[regMapAutoKeywordFields]

  aRestServer := TSQLRestServerDB.Create(aModel,SQLITE_MEMORY_DATABASE_NAME,false); //TSQLRestServerDB
  aRestServer.CreateMissingTables;

  //ORMServer := TNoteServer.Create(ExeVersion.ProgramFilePath+'data','root');
  try
    TSQLLog.Family.EchoToConsole := LOG_VERBOSE;
    HTTPServer := TSQLHttpServer.Create(HTTP_PORT,[aRestServer]);
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
    aRestServer.Free;
  end;


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

