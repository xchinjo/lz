unit RESTModel;

interface

uses
  SynCommons,
  mORMot;

type
  TPerson = class(TSQLRecord) // TSQLRecord has already ID: integer primary key
  private
    fName: RawUTF8;
  published
    /// ORM will create a NAME VARCHAR(80) column
    property Name: RawUTF8 index 80 read fName write fName;
  end;

  TSQLRecordPeople = class(TSQLRecord)
  private
    fFirstName: RawUTF8;
    fLastName: RawUTF8;
    fYearOfBirth: integer;
    fYearOfDeath: word;
  published
    property FirstName: RawUTF8 read fFirstName write fFirstName;
    property LastName: RawUTF8 read fLastName write fLastName;
    property YearOfBirth: integer read fYearOfBirth write fYearOfBirth;
    property YearOfDeath: word read fYearOfDeath write fYearOfDeath;
  end;


function DataModel: TSQLModel;

const
  SERVER_ROOT = 'root';
  SERVER_PORT = '8880';


implementation

uses MobileClass;



function DataModel: TSQLModel;
begin
  result := TSQLModel.Create([TSQLINVM_PROD],SERVER_ROOT);
  //TPerson.AddFilterOrValidate('Name',TSynValidateText.Create); // ensure exists
end;


end.
