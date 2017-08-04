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

 aProps := TODBCConnectionProperties.Create('','Driver=MySQL'+
   //aProps := TODBCConnectionProperties.Create('','MySQL'+
         ';Database=SAM;'+
         'Server=rootcode.info;Port=3306;USER=joni;Password=P@ssw0rd123','','');  


 // aProps := TSQLDBZEOSConnectionProperties.Create(TSQLDBZEOSConnectionProperties.URI(
 //         dMySQL,'rootcode.info:3306'),'SAM','joni','1q2w3e4r');


  // get the shared data model
  aModel := DataModel;

  VirtualTableExternalRegisterAll(aModel,aProps); //[regMapAutoKeywordFields]
  //aRestServer := TSQLRestServerDB.Create(aModel,ChangeFileExt(ExeVersion.ProgramFileName,'.db3'),false);
  aRestServer := TSQLRestServerDB.Create(aModel,SQLITE_MEMORY_DATABASE_NAME,false); //TSQLRestServerDB
  
   aModel.Props[TSQLINVM_PROD].ExternalDB.MapField('ID','PRDRUN');

  aRestServer.CreateMissingTables;

  //ORMServer := TNoteServer.Create(ExeVersion.ProgramFilePath+'data','root');
  try
    //TSQLLog.Family.EchoToConsole := LOG_VERBOSE;
    
    with TSQLLog.Family do begin

        Level := LOG_VERBOSE;
        EchoToConsole := LOG_VERBOSE; // log all events to the console
        PerThreadLog := ptIdentifiedInOnFile;
        NoFile:=true;
    end;


     HTTPServer := TSQLHttpServer.Create(HTTP_PORT,[aRestServer]);
  //HTTPServer := TSQLHttpServer.Create('8880',[aRestServer],'+',useHttpApiRegisteringURI); //useHttpApiRegisteringURI    
 try
      HTTPServer.AccessControlAllowOrigin := '*'; // allow cross-site AJAX queries
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

