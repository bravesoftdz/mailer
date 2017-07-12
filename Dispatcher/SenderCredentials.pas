unit SenderCredentials;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TVenditoriCredentials = class(TObject)
  strict private
    constructor Create();
  public
    class function From(): String;
    class function Name(): String;
    class function Recipients(): String;
    class function Subject(): String;
    class function Server(): String;
    class function Port(): Integer;
  end;

type
  TONMCredentials = class abstract(TObject)
  public
  var
  const

    From = 'info@offertenuovimandati.com';
    Name = 'Offerte Nuovi Mandati';
    Port = 25;
    Server = 'www.offertenuovimandati.it';
    Subject = 'Offerte Nuovo mandati Rivcezione Dati Agente';
    SmtpHost = 'mailbus.fastweb.it';
    EmailInternal = 'a.shcherbakov@ritoll.it'; //'webform@offertenuovimandati.it';

  end;

implementation

uses
  System.SysUtils;

{ TVenditoriCredentials }

constructor TVenditoriCredentials.Create;
begin
  raise Exception.Create('Class TVenditoriCredentials should not be created. use ');
end;

class function TVenditoriCredentials.From: String;
begin
  Result := 'redazione@venditori.it';
end;

class function TVenditoriCredentials.Name: String;
begin
  Result := 'Venditori .IT';
end;

class function TVenditoriCredentials.Port: Integer;
begin
  Result := 25;
end;

class function TVenditoriCredentials.Recipients: String;
begin
  Result := 'a.shcherbakov@ritoll.it';
  // ,a.impiglia@ritoll.it,d.macori@ritoll.it';
end;

class function TVenditoriCredentials.Server: String;
begin
  Result := 'mailbus.fastweb.it';
end;

class function TVenditoriCredentials.Subject: String;
begin
  Result := 'venditori richiesta';
end;

initialization

end.
