unit Configuration;

interface

uses
  System.JSON;

type
  TConfiguration = class(TInterfacedObject)
  public
    /// extract the key value from the json object as an integer. In case of failure, the dafualt value
    /// is returned.
    class function GetIntValue(const jo: TJsonObject; const key: String; const DefaultValue: Integer): Integer;

    /// extract the key value from the json object as a string. In case of failure, the dafualt value
    /// is returned.
    class function GetStrValue(const jo: TJsonObject; const key: String; const DefaultValue: String): String;

    /// extract the key value from the json object as a boolean. In case of failure, the dafualt value
    /// is returned.
    class function GetBoolValue(const jo: TJsonObject; const key: String; const DefaultValue: Boolean): Boolean;

    constructor Create();
    destructor Destroy(); override;

  end;

implementation

uses
  System.SysUtils;

{ TConfiguration }

constructor TConfiguration.Create;
begin

end;

destructor TConfiguration.Destroy;
begin

  inherited;
end;

class function TConfiguration.GetBoolValue(const jo: TJsonObject; const key: String;
  const DefaultValue: Boolean): Boolean;
var
  value: TJsonValue;
begin
  value := jo.GetValue(key);
  if (Value <> nil) AND (Value is TJsonBool) then
  begin
    try
      Result := (value as TJSONBool).AsBoolean;
    except
      on E: Exception do
        Result := DefaultValue;
    end;
  end
  else
    Result := DefaultValue;
end;

class function TConfiguration.GetIntValue(const jo: TJsonObject; const key: String;
  const DefaultValue: Integer): Integer;
var
  value: TJsonValue;
begin
  value := jo.GetValue(key);
  if Value <> nil then
  begin
    try
      Result := strtoint(value.Value);
    except
      on E: Exception do
        Result := DefaultValue;
    end;
  end
  else
    Result := DefaultValue;
end;

class function TConfiguration.GetStrValue(const jo: TJsonObject; const key, DefaultValue: String): String;
var
  value: TJsonValue;
begin
  value := jo.GetValue(key);
  if Value <> nil then
  begin
    try
      Result := value.Value;
    except
      on E: Exception do
        Result := DefaultValue;
    end;
  end
  else
    Result := DefaultValue;
end;

end.
